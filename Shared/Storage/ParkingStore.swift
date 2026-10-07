//
//  ParkingStore.swift
//  MotoFloor
//

import Foundation
import Observation
#if canImport(WidgetKit)
import WidgetKit
#endif

/// Centralized shared store for MotoFloor state, shared between the main app and widget extensions.
@Observable
public final class ParkingStore: @unchecked Sendable {
    // MARK: - Constants

    /// App Group identifier used for shared container storage.
    public static let appGroupIdentifier = "group.com.chhunsour.motofloor"

    public static let currentFloorKey = "motofloor.current_floor"
    public static let parkedAtKey = "motofloor.parked_at"
    public static let historyKey = "motofloor.history"
    public static let staleThresholdHoursKey = "motofloor.stale_threshold_hours"
    public static let hapticsEnabledKey = "motofloor.haptics_enabled"
    public static let hasSeenOnboardingKey = "motofloor.has_seen_onboarding"

    public static let maxHistoryCount = 30
    public static let defaultStaleHours = 18

    // MARK: - Singleton

    public static let shared = ParkingStore()

    // MARK: - Observable State

    public private(set) var currentParkingFloor: ParkingFloor?
    public private(set) var parkedAt: Date?
    public private(set) var parkingHistory: [ParkingRecord] = []
    public var staleThresholdHours: Int {
        didSet {
            saveStoredValue(staleThresholdHours, forKey: Self.staleThresholdHoursKey)
            reloadWidgets()
        }
    }
    public var hapticsEnabled: Bool {
        didSet {
            saveStoredValue(hapticsEnabled, forKey: Self.hapticsEnabledKey)
        }
    }
    public var hasSeenOnboarding: Bool {
        didSet {
            saveStoredValue(hasSeenOnboarding, forKey: Self.hasSeenOnboardingKey)
        }
    }

    // MARK: - Internal Storage Reference

    private let defaults: UserDefaults
    private let isCustomStorage: Bool

    // MARK: - Storage Helpers (App Group with Sandbox Fallback for Production, Isolated for Tests)

    private func getStoredString(forKey key: String) -> String? {
        if let val = defaults.string(forKey: key) {
            return val
        }
        if isCustomStorage { return nil }
        return UserDefaults.standard.string(forKey: key)
    }

    private func getStoredObject(forKey key: String) -> Any? {
        if let val = defaults.object(forKey: key) {
            return val
        }
        if isCustomStorage { return nil }
        return UserDefaults.standard.object(forKey: key)
    }

    private func getStoredData(forKey key: String) -> Data? {
        if let val = defaults.data(forKey: key) {
            return val
        }
        if isCustomStorage { return nil }
        return UserDefaults.standard.data(forKey: key)
    }

    private func getStoredBool(forKey key: String) -> Bool {
        if defaults.object(forKey: key) != nil {
            return defaults.bool(forKey: key)
        }
        if isCustomStorage { return false }
        return UserDefaults.standard.bool(forKey: key)
    }

    private func getStoredInt(forKey key: String, default defaultVal: Int) -> Int {
        if defaults.object(forKey: key) != nil {
            return defaults.integer(forKey: key)
        }
        if !isCustomStorage && UserDefaults.standard.object(forKey: key) != nil {
            return UserDefaults.standard.integer(forKey: key)
        }
        return defaultVal
    }

    private func saveStoredValue(_ value: Any?, forKey key: String) {
        if isCustomStorage {
            if let value = value {
                defaults.set(value, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
            return
        }

        if let value = value {
            defaults.set(value, forKey: key)
            if defaults != UserDefaults.standard {
                UserDefaults.standard.set(value, forKey: key)
            }
        } else {
            defaults.removeObject(forKey: key)
            if defaults != UserDefaults.standard {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }

    // MARK: - Initializer

    public init(userDefaults: UserDefaults? = nil) {
        self.isCustomStorage = (userDefaults != nil)
        let resolvedDefaults: UserDefaults
        if let custom = userDefaults {
            resolvedDefaults = custom
        } else if let suite = UserDefaults(suiteName: Self.appGroupIdentifier) {
            resolvedDefaults = suite
        } else {
            // Graceful fallback during development / testing if App Groups are unprovisioned
            resolvedDefaults = UserDefaults.standard
        }
        self.defaults = resolvedDefaults

        // Read stored floor
        let rawFloor = resolvedDefaults.string(forKey: Self.currentFloorKey) ?? (!isCustomStorage ? UserDefaults.standard.string(forKey: Self.currentFloorKey) : nil)
        if let raw = rawFloor, let floor = ParkingFloor(rawValue: raw) {
            self.currentParkingFloor = floor
        } else {
            self.currentParkingFloor = nil
        }

        // Read parked timestamp
        let storedDate = resolvedDefaults.object(forKey: Self.parkedAtKey) ?? (!isCustomStorage ? UserDefaults.standard.object(forKey: Self.parkedAtKey) : nil)
        if let date = storedDate as? Date {
            self.parkedAt = date
        } else {
            self.parkedAt = nil
        }

        // Read stale hours setting
        if resolvedDefaults.object(forKey: Self.staleThresholdHoursKey) != nil {
            self.staleThresholdHours = resolvedDefaults.integer(forKey: Self.staleThresholdHoursKey)
        } else if !isCustomStorage && UserDefaults.standard.object(forKey: Self.staleThresholdHoursKey) != nil {
            self.staleThresholdHours = UserDefaults.standard.integer(forKey: Self.staleThresholdHoursKey)
        } else {
            self.staleThresholdHours = Self.defaultStaleHours
        }

        // Read haptics setting (defaults to true)
        if resolvedDefaults.object(forKey: Self.hapticsEnabledKey) != nil {
            self.hapticsEnabled = resolvedDefaults.bool(forKey: Self.hapticsEnabledKey)
        } else if !isCustomStorage && UserDefaults.standard.object(forKey: Self.hapticsEnabledKey) != nil {
            self.hapticsEnabled = UserDefaults.standard.bool(forKey: Self.hapticsEnabledKey)
        } else {
            self.hapticsEnabled = true
        }

        // Read onboarding state
        if resolvedDefaults.object(forKey: Self.hasSeenOnboardingKey) != nil {
            self.hasSeenOnboarding = resolvedDefaults.bool(forKey: Self.hasSeenOnboardingKey)
        } else if !isCustomStorage {
            self.hasSeenOnboarding = UserDefaults.standard.bool(forKey: Self.hasSeenOnboardingKey)
        } else {
            self.hasSeenOnboarding = false
        }

        // Read history
        let historyData = resolvedDefaults.data(forKey: Self.historyKey) ?? (!isCustomStorage ? UserDefaults.standard.data(forKey: Self.historyKey) : nil)
        if let data = historyData,
           let records = try? JSONDecoder().decode([ParkingRecord].self, from: data) {
            self.parkingHistory = records
        } else {
            self.parkingHistory = []
        }
    }

    // MARK: - Actions

    /// Sets the current parking floor, records the timestamp, prepends to history, and refreshes widgets.
    public func setFloor(_ floor: ParkingFloor, at date: Date = Date()) {
        currentParkingFloor = floor
        parkedAt = date

        saveStoredValue(floor.rawValue, forKey: Self.currentFloorKey)
        saveStoredValue(date, forKey: Self.parkedAtKey)

        // Append to history, avoiding identical consecutive spam within 60 seconds
        let newRecord = ParkingRecord(floor: floor, parkedAt: date)
        var updated = parkingHistory
        if let first = updated.first, first.floor == floor, abs(first.parkedAt.timeIntervalSince(date)) < 60 {
            // Updated existing timestamp for identical fast re-tap
            updated[0] = newRecord
        } else {
            updated.insert(newRecord, at: 0)
        }

        if updated.count > Self.maxHistoryCount {
            updated = Array(updated.prefix(Self.maxHistoryCount))
        }

        parkingHistory = updated
        saveHistory()

        reloadWidgets()
    }

    /// Clears the active parking floor and timestamp (keeps parking history intact).
    public func clearParking() {
        currentParkingFloor = nil
        parkedAt = nil

        saveStoredValue(nil, forKey: Self.currentFloorKey)
        saveStoredValue(nil, forKey: Self.parkedAtKey)

        reloadWidgets()
    }

    /// Clears all past parking records.
    public func clearHistory() {
        parkingHistory = []
        saveStoredValue(nil, forKey: Self.historyKey)
    }

    /// Re-reads values from the backing UserDefaults (useful when widget or intent updates out-of-process).
    public func reloadFromStorage() {
        if let rawFloor = getStoredString(forKey: Self.currentFloorKey),
           let floor = ParkingFloor(rawValue: rawFloor) {
            self.currentParkingFloor = floor
        } else {
            self.currentParkingFloor = nil
        }

        if let date = getStoredObject(forKey: Self.parkedAtKey) as? Date {
            self.parkedAt = date
        } else {
            self.parkedAt = nil
        }

        self.staleThresholdHours = getStoredInt(forKey: Self.staleThresholdHoursKey, default: Self.defaultStaleHours)

        if getStoredObject(forKey: Self.hapticsEnabledKey) != nil {
            self.hapticsEnabled = getStoredBool(forKey: Self.hapticsEnabledKey)
        } else {
            self.hapticsEnabled = true
        }

        self.hasSeenOnboarding = getStoredBool(forKey: Self.hasSeenOnboardingKey)

        if let data = getStoredData(forKey: Self.historyKey),
           let records = try? JSONDecoder().decode([ParkingRecord].self, from: data) {
            self.parkingHistory = records
        }
    }

    // MARK: - Stale Parking Logic

    /// Checks if the recorded parking is older than the configured threshold.
    /// A threshold of 0 represents "Never stale".
    public func isCurrentParkingStale(referenceDate: Date = Date()) -> Bool {
        guard let parkedAt = parkedAt else { return false }
        guard staleThresholdHours > 0 else { return false }
        let thresholdSeconds = TimeInterval(staleThresholdHours * 3600)
        return referenceDate.timeIntervalSince(parkedAt) >= thresholdSeconds
    }

    /// Returns a human-friendly string for stale display (e.g., "Yesterday · 8:47 AM" or "Oct 4 · 9:15 AM").
    public func staleFormattedDescription(referenceDate: Date = Date()) -> String {
        guard let parkedAt = parkedAt else { return "" }
        let calendar = Calendar.current

        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        timeFormatter.dateStyle = .none
        let timePart = timeFormatter.string(from: parkedAt)

        if calendar.isDateInToday(parkedAt) {
            return "Earlier today · \(timePart)"
        } else if calendar.isDateInYesterday(parkedAt) {
            return "Yesterday · \(timePart)"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d"
            let datePart = dateFormatter.string(from: parkedAt)
            return "\(datePart) · \(timePart)"
        }
    }

    /// Natural language representation of the parked timestamp (e.g. "Today · 8:47 AM" or "Yesterday · 8:47 AM").
    public var naturalParkedDescription: String {
        guard let parkedAt = parkedAt else { return "" }
        let calendar = Calendar.current
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        timeFormatter.dateStyle = .none
        let timePart = timeFormatter.string(from: parkedAt)

        if calendar.isDateInToday(parkedAt) {
            return "Today · \(timePart)"
        } else if calendar.isDateInYesterday(parkedAt) {
            return "Yesterday · \(timePart)"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d"
            return "\(dateFormatter.string(from: parkedAt)) · \(timePart)"
        }
    }

    /// Human-friendly representation of the parked timestamp (e.g. "8:47 AM").
    public var formattedParkedTime: String {
        guard let parkedAt = parkedAt else { return "" }
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        timeFormatter.dateStyle = .none
        return timeFormatter.string(from: parkedAt)
    }

    // MARK: - Private Helpers

    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(parkingHistory) {
            saveStoredValue(encoded, forKey: Self.historyKey)
        }
    }

    public func reloadWidgets() {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #if os(iOS)
        if #available(iOS 18.0, *) {
            ControlCenter.shared.reloadAllControls()
        }
        #endif
        #endif
    }
}
