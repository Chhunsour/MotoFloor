//
//  StaleRecordTests.swift
//  MotoFloorTests
//

import XCTest
#if canImport(MotoFloor)
@testable import MotoFloor
#endif

final class StaleRecordTests: XCTestCase {
    var userDefaults: UserDefaults!
    var suiteName: String!
    var store: ParkingStore!

    override func setUp() {
        super.setUp()
        suiteName = "test.stale.\(UUID().uuidString)"
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

    func testNotStaleWhenEmpty() {
        XCTAssertFalse(store.isCurrentParkingStale())
    }

    func testFreshParkingIsNotStale() {
        let now = Date()
        store.setFloor(.floor2, at: now)

        // Check immediately
        XCTAssertFalse(store.isCurrentParkingStale(referenceDate: now))

        // Check 2 hours later
        let twoHoursLater = now.addingTimeInterval(2 * 3600)
        XCTAssertFalse(store.isCurrentParkingStale(referenceDate: twoHoursLater))

        // Check 17 hours and 59 minutes later (still under 18h default threshold)
        let almostStale = now.addingTimeInterval(17.9 * 3600)
        XCTAssertFalse(store.isCurrentParkingStale(referenceDate: almostStale))
    }

    func testParkingBecomesStaleAfter18Hours() {
        let parkedTime = Date()
        store.setFloor(.floor2, at: parkedTime)

        // Exactly 18 hours later
        let exactlyStale = parkedTime.addingTimeInterval(18 * 3600)
        XCTAssertTrue(store.isCurrentParkingStale(referenceDate: exactlyStale))

        // 24 hours later
        let nextDay = parkedTime.addingTimeInterval(24 * 3600)
        XCTAssertTrue(store.isCurrentParkingStale(referenceDate: nextDay))
    }

    func testCustomStaleThreshold() {
        let parkedTime = Date()
        store.setFloor(.m, at: parkedTime)
        store.staleThresholdHours = 12

        // 11 hours later
        let elevenHoursLater = parkedTime.addingTimeInterval(11 * 3600)
        XCTAssertFalse(store.isCurrentParkingStale(referenceDate: elevenHoursLater))

        // 13 hours later
        let thirteenHoursLater = parkedTime.addingTimeInterval(13 * 3600)
        XCTAssertTrue(store.isCurrentParkingStale(referenceDate: thirteenHoursLater))
    }

    func testNeverStaleThreshold() {
        let parkedTime = Date()
        store.setFloor(.floor3, at: parkedTime)
        store.staleThresholdHours = 0 // 0 = Never

        // 48 hours later
        let twoDaysLater = parkedTime.addingTimeInterval(48 * 3600)
        XCTAssertFalse(store.isCurrentParkingStale(referenceDate: twoDaysLater))
    }

    func testStaleFormattedDescription() {
        let calendar = Calendar.current
        let parkedYesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        store.setFloor(.floor1, at: parkedYesterday)

        let description = store.staleFormattedDescription(referenceDate: Date())
        XCTAssertTrue(description.contains("Yesterday"), "Description was: \(description)")
    }
}
