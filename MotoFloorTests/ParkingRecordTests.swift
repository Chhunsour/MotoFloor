//
//  ParkingRecordTests.swift
//  MotoFloorTests
//

import XCTest
#if canImport(MotoFloor)
@testable import MotoFloor
#endif

final class ParkingRecordTests: XCTestCase {
    func testRecordInitialization() {
        let now = Date()
        let record = ParkingRecord(floor: .floor2, parkedAt: now)

        XCTAssertEqual(record.floor, .floor2)
        XCTAssertEqual(record.parkedAt, now)
        XCTAssertFalse(record.id.uuidString.isEmpty)
    }

    func testCodableEncodingAndDecoding() throws {
        let record = ParkingRecord(floor: .floor3, parkedAt: Date())
        let data = try JSONEncoder().encode(record)
        let decoded = try JSONDecoder().decode(ParkingRecord.self, from: data)

        XCTAssertEqual(record.id, decoded.id)
        XCTAssertEqual(record.floor, decoded.floor)
        XCTAssertEqual(record.parkedAt.timeIntervalSince1970, decoded.parkedAt.timeIntervalSince1970, accuracy: 0.001)
    }

    func testRelativeDateFormatting() {
        let recordToday = ParkingRecord(floor: .floor1, parkedAt: Date())
        XCTAssertEqual(recordToday.relativeDateString, "Today")

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let recordYesterday = ParkingRecord(floor: .m, parkedAt: yesterday)
        XCTAssertEqual(recordYesterday.relativeDateString, "Yesterday")
    }
}
