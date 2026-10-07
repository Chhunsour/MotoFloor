//
//  ParkingStoreTests.swift
//  MotoFloorTests
//

import XCTest
#if canImport(MotoFloor)
@testable import MotoFloor
#endif

final class ParkingStoreTests: XCTestCase {
    var userDefaults: UserDefaults!
    var suiteName: String!
    var store: ParkingStore!

    override func setUp() {
        super.setUp()
        suiteName = "test.motofloor.\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)
        store = ParkingStore(userDefaults: userDefaults)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: suiteName)
        userDefaults = nil
        store = nil
        super.tearDown()
    }

    func testInitialStateIsEmpty() {
        XCTAssertNil(store.currentParkingFloor)
        XCTAssertNil(store.parkedAt)
        XCTAssertTrue(store.parkingHistory.isEmpty)
        XCTAssertEqual(store.staleThresholdHours, ParkingStore.defaultStaleHours)
        XCTAssertTrue(store.hapticsEnabled)
    }

    func testSetFloorSavesFloorAndTimestamp() {
        let testDate = Date()
        store.setFloor(.floor2, at: testDate)

        XCTAssertEqual(store.currentParkingFloor, .floor2)
        XCTAssertEqual(store.parkedAt, testDate)
        XCTAssertEqual(store.parkingHistory.count, 1)
        XCTAssertEqual(store.parkingHistory.first?.floor, .floor2)
        XCTAssertEqual(store.parkingHistory.first?.parkedAt, testDate)

        // Verify underlying UserDefaults directly
        let raw = userDefaults.string(forKey: ParkingStore.currentFloorKey)
        XCTAssertEqual(raw, "2")
        let storedDate = userDefaults.object(forKey: ParkingStore.parkedAtKey) as? Date
        XCTAssertEqual(storedDate, testDate)
    }

    func testChangeFloorUpdatesCurrentAndAppendsHistory() {
        let time1 = Date().addingTimeInterval(-120)
        let time2 = Date()

        store.setFloor(.floor1, at: time1)
        XCTAssertEqual(store.currentParkingFloor, .floor1)

        store.setFloor(.floor3, at: time2)
        XCTAssertEqual(store.currentParkingFloor, .floor3)
        XCTAssertEqual(store.parkedAt, time2)

        XCTAssertEqual(store.parkingHistory.count, 2)
        XCTAssertEqual(store.parkingHistory[0].floor, .floor3)
        XCTAssertEqual(store.parkingHistory[1].floor, .floor1)
    }

    func testClearParkingRemovesCurrentFloorAndPreservesHistory() {
        let testDate = Date()
        store.setFloor(.floor2, at: testDate)
        XCTAssertNotNil(store.currentParkingFloor)

        store.clearParking()

        XCTAssertNil(store.currentParkingFloor)
        XCTAssertNil(store.parkedAt)
        XCTAssertNil(userDefaults.string(forKey: ParkingStore.currentFloorKey))
        XCTAssertNil(userDefaults.object(forKey: ParkingStore.parkedAtKey))

        // History must be preserved
        XCTAssertEqual(store.parkingHistory.count, 1)
        XCTAssertEqual(store.parkingHistory.first?.floor, .floor2)
    }

    func testHistoryCappingAtMax30Items() {
        for i in 1...35 {
            let floor: ParkingFloor = (i % 2 == 0) ? .floor1 : .floor2
            let date = Date().addingTimeInterval(TimeInterval(i * 100))
            store.setFloor(floor, at: date)
        }

        XCTAssertEqual(store.parkingHistory.count, ParkingStore.maxHistoryCount)
    }

    func testClearHistoryRemovesHistoryOnly() {
        store.setFloor(.floor2)
        XCTAssertFalse(store.parkingHistory.isEmpty)

        store.clearHistory()

        XCTAssertTrue(store.parkingHistory.isEmpty)
        XCTAssertEqual(store.currentParkingFloor, .floor2) // Current floor still active
    }

    func testReloadFromStorageSyncsChanges() {
        store.setFloor(.m)

        // Simulate external process writing to UserDefaults (like widget intent)
        userDefaults.set("3", forKey: ParkingStore.currentFloorKey)
        let newDate = Date()
        userDefaults.set(newDate, forKey: ParkingStore.parkedAtKey)

        store.reloadFromStorage()

        XCTAssertEqual(store.currentParkingFloor, .floor3)
        XCTAssertEqual(store.parkedAt, newDate)
    }
}
