//
//  ParkingTimelineProvider.swift
//  MotoFloorWidgets
//

import WidgetKit
import SwiftUI

/// Timeline entry representing the motorcycle parking state at a point in time.
public struct ParkingEntry: TimelineEntry {
    public let date: Date
    public let floor: ParkingFloor?
    public let parkedAt: Date?
    public let isStale: Bool
    public let staleNotice: String

    public init(
        date: Date,
        floor: ParkingFloor?,
        parkedAt: Date?,
        isStale: Bool,
        staleNotice: String
    ) {
        self.date = date
        self.floor = floor
        self.parkedAt = parkedAt
        self.isStale = isStale
        self.staleNotice = staleNotice
    }

    public var timeString: String {
        guard let parkedAt = parkedAt else { return "" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: parkedAt)
    }

    /// Natural language representation (e.g. "Today · 1:09 PM", "Yesterday · 6:30 PM").
    public var timestampDescription: String {
        guard let parkedAt = parkedAt else { return "" }
        let calendar = Calendar.current
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        timeFormatter.dateStyle = .none
        let time = timeFormatter.string(from: parkedAt)

        if calendar.isDateInToday(parkedAt) {
            return "Today · \(time)"
        } else if calendar.isDateInYesterday(parkedAt) {
            return "Yesterday · \(time)"
        } else {
            let df = DateFormatter()
            df.dateFormat = "MMM d"
            return "\(df.string(from: parkedAt)) · \(time)"
        }
    }

    public static var placeholder: ParkingEntry {
        ParkingEntry(
            date: Date(),
            floor: .floor2,
            parkedAt: Date(),
            isStale: false,
            staleNotice: ""
        )
    }

    public static var empty: ParkingEntry {
        ParkingEntry(
            date: Date(),
            floor: nil,
            parkedAt: nil,
            isStale: false,
            staleNotice: ""
        )
    }
}

/// Supplies timeline entries for MotoFloor widgets based on shared storage.
public struct ParkingTimelineProvider: TimelineProvider {
    public init() {}

    public func placeholder(in context: Context) -> ParkingEntry {
        .placeholder
    }

    public func getSnapshot(in context: Context, completion: @escaping (ParkingEntry) -> Void) {
        let store = ParkingStore.shared
        store.reloadFromStorage()

        if context.isPreview {
            completion(.placeholder)
            return
        }

        let entry = currentEntry(for: Date(), store: store)
        completion(entry)
    }

    public func getTimeline(in context: Context, completion: @escaping (Timeline<ParkingEntry>) -> Void) {
        let store = ParkingStore.shared
        store.reloadFromStorage()

        let now = Date()
        var entries: [ParkingEntry] = []

        let current = currentEntry(for: now, store: store)
        entries.append(current)

        var reloadDate = now.addingTimeInterval(3600) // Default 1 hour

        // If currently parked and not yet stale, schedule future entry for the exact moment it becomes stale
        if let parkedAt = store.parkedAt, store.staleThresholdHours > 0, !store.isCurrentParkingStale(referenceDate: now) {
            let staleDate = parkedAt.addingTimeInterval(TimeInterval(store.staleThresholdHours * 3600))
            if staleDate > now {
                let futureStaleEntry = currentEntry(for: staleDate, store: store)
                entries.append(futureStaleEntry)
                reloadDate = staleDate.addingTimeInterval(60)
            }
        }

        let timeline = Timeline(entries: entries, policy: .after(reloadDate))
        completion(timeline)
    }

    // MARK: - Helper

    private func currentEntry(for date: Date, store: ParkingStore) -> ParkingEntry {
        let floor = store.currentParkingFloor
        let parkedAt = store.parkedAt
        let isStale = store.isCurrentParkingStale(referenceDate: date)
        let staleNotice = isStale ? store.staleFormattedDescription(referenceDate: date) : ""

        return ParkingEntry(
            date: date,
            floor: floor,
            parkedAt: parkedAt,
            isStale: isStale,
            staleNotice: staleNotice
        )
    }
}
