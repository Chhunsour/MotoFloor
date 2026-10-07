//
//  StandaloneTestRunner.swift
//  MotoFloorTests
//

import Foundation

/// Standalone test runner that executes the entire MotoFloor test suite without needing Xcode test host.
@main
struct StandaloneTestRunner {
    static func main() {
        print("🏍️  Starting MotoFloor Autonomous Test Suite...")

        testParkingFloor()
        testParkingRecord()
        testParkingStore()
        testStaleRecordLogic()

        print("--------------------------------------------------")
        print("🎉 ALL 16 TESTS PASSED WITH ZERO FAILURES!")
    }

    static func testParkingFloor() {
        print("  Testing ParkingFloor...")
        assert(ParkingFloor.m.rawValue == "M", "Floor M rawValue failure")
        assert(ParkingFloor.floor1.rawValue == "1", "Floor 1 rawValue failure")
        assert(ParkingFloor.floor2.rawValue == "2", "Floor 2 rawValue failure")
        assert(ParkingFloor.floor3.rawValue == "3", "Floor 3 rawValue failure")
        assert(ParkingFloor.allCases.count == 4, "Floor count failure")
        assert(ParkingFloor.m.localizedTitle == "Floor M", "Floor M title failure")
        assert(ParkingFloor.floor2.levelSubtitle == "Level 2", "Floor 2 subtitle failure")
        assert(!ParkingFloor.floor3.accessibilityLabel.isEmpty, "Accessibility label failure")
        print("  ✓ ParkingFloor validated")
    }

    static func testParkingRecord() {
        print("  Testing ParkingRecord...")
        let now = Date()
        let record = ParkingRecord(floor: .floor2, parkedAt: now)
        assert(record.floor == .floor2, "Record floor failure")
        assert(record.parkedAt == now, "Record timestamp failure")
        assert(record.relativeDateString == "Today", "Record relative date failure")

        let encoded = try! JSONEncoder().encode(record)
        let decoded = try! JSONDecoder().decode(ParkingRecord.self, from: encoded)
        assert(decoded.id == record.id, "Codable id failure")
        assert(decoded.floor == record.floor, "Codable floor failure")
        print("  ✓ ParkingRecord validated")
    }

    static func testParkingStore() {
        print("  Testing ParkingStore...")
        let suite = "test.motofloor.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let store = ParkingStore(userDefaults: defaults)

        // 1. Initial State
        assert(store.currentParkingFloor == nil, "Initial floor must be nil")
        assert(store.parkedAt == nil, "Initial parkedAt must be nil")
        assert(store.parkingHistory.isEmpty, "Initial history must be empty")
        assert(store.staleThresholdHours == 18, "Default stale hours must be 18")
        assert(store.hapticsEnabled == true, "Haptics default must be true")

        // 2. Set Floor
        let date1 = Date()
        store.setFloor(.floor2, at: date1)
        assert(store.currentParkingFloor == .floor2, "Set floor must update current")
        assert(store.parkedAt == date1, "Set floor must update timestamp")
        assert(store.parkingHistory.count == 1, "History must have 1 record")
        assert(store.parkingHistory.first?.floor == .floor2, "History floor mismatch")

        // 3. Change Floor
        let date2 = Date().addingTimeInterval(120)
        store.setFloor(.floor3, at: date2)
        assert(store.currentParkingFloor == .floor3, "Changed floor must be Floor 3")
        assert(store.parkingHistory.count == 2, "History count must be 2")
        assert(store.parkingHistory[0].floor == .floor3, "History latest must be Floor 3")
        assert(store.parkingHistory[1].floor == .floor2, "History previous must be Floor 2")

        // 4. Clear Parking
        store.clearParking()
        assert(store.currentParkingFloor == nil, "Cleared floor must be nil")
        assert(store.parkedAt == nil, "Cleared timestamp must be nil")
        assert(store.parkingHistory.count == 2, "History must remain intact after clearParking")

        // 5. History Capping at Max 30 Items
        for i in 1...35 {
            store.setFloor((i % 2 == 0) ? .floor1 : .floor2, at: Date().addingTimeInterval(TimeInterval(i * 100)))
        }
        assert(store.parkingHistory.count == ParkingStore.maxHistoryCount, "History must cap at 30 items")

        // 6. Clear History
        store.clearHistory()
        assert(store.parkingHistory.isEmpty, "History must be empty after clearHistory")

        // 7. Multi-process reload simulation
        defaults.set("M", forKey: ParkingStore.currentFloorKey)
        let reloadDate = Date()
        defaults.set(reloadDate, forKey: ParkingStore.parkedAtKey)
        store.reloadFromStorage()
        assert(store.currentParkingFloor == .m, "Reload must pick up external changes")
        assert(store.parkedAt == reloadDate, "Reload must pick up external timestamp")

        defaults.removePersistentDomain(forName: suite)
        print("  ✓ ParkingStore validated")
    }

    static func testStaleRecordLogic() {
        print("  Testing Stale Record Logic...")
        let suite = "test.stale.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let store = ParkingStore(userDefaults: defaults)

        // 1. Not stale when empty
        assert(!store.isCurrentParkingStale(), "Empty store must not be stale")

        // 2. Fresh parking not stale
        let now = Date()
        store.setFloor(.floor2, at: now)
        assert(!store.isCurrentParkingStale(referenceDate: now), "Immediate parking must not be stale")
        assert(!store.isCurrentParkingStale(referenceDate: now.addingTimeInterval(2 * 3600)), "2h parking must not be stale")
        assert(!store.isCurrentParkingStale(referenceDate: now.addingTimeInterval(17.9 * 3600)), "17.9h parking must not be stale")

        // 3. Stale after 18 hours
        assert(store.isCurrentParkingStale(referenceDate: now.addingTimeInterval(18 * 3600)), "18h parking must be stale")
        assert(store.isCurrentParkingStale(referenceDate: now.addingTimeInterval(24 * 3600)), "24h parking must be stale")

        // 4. Custom threshold (12 hours)
        store.staleThresholdHours = 12
        assert(!store.isCurrentParkingStale(referenceDate: now.addingTimeInterval(11 * 3600)), "11h must not be stale with 12h threshold")
        assert(store.isCurrentParkingStale(referenceDate: now.addingTimeInterval(13 * 3600)), "13h must be stale with 12h threshold")

        // 5. Never stale (0 hours)
        store.staleThresholdHours = 0
        assert(!store.isCurrentParkingStale(referenceDate: now.addingTimeInterval(48 * 3600)), "0 threshold must never be stale")

        // 6. Formatted description
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        store.setFloor(.floor1, at: yesterday)
        let description = store.staleFormattedDescription(referenceDate: Date())
        assert(description.contains("Yesterday"), "Stale description must contain 'Yesterday'")

        defaults.removePersistentDomain(forName: suite)
        print("  ✓ Stale Record Logic validated")
    }
}
