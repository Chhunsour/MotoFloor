//
//  ParkingFloorTests.swift
//  MotoFloorTests
//

import XCTest
#if canImport(MotoFloor)
@testable import MotoFloor
#endif

final class ParkingFloorTests: XCTestCase {
    func testFloorRawValues() {
        XCTAssertEqual(ParkingFloor.m.rawValue, "M")
        XCTAssertEqual(ParkingFloor.floor1.rawValue, "1")
        XCTAssertEqual(ParkingFloor.floor2.rawValue, "2")
        XCTAssertEqual(ParkingFloor.floor3.rawValue, "3")
    }

    func testFloorCaseCount() {
        XCTAssertEqual(ParkingFloor.allCases.count, 4)
        XCTAssertEqual(ParkingFloor.allCases, [.m, .floor1, .floor2, .floor3])
    }

    func testFloorIdentifiers() {
        for floor in ParkingFloor.allCases {
            XCTAssertEqual(floor.id, floor.rawValue)
            XCTAssertEqual(floor.shortTitle, floor.rawValue)
        }
    }

    func testFloorTitlesAndDescriptions() {
        XCTAssertEqual(ParkingFloor.m.localizedTitle, "Floor M")
        XCTAssertEqual(ParkingFloor.floor1.localizedTitle, "Floor 1")
        XCTAssertEqual(ParkingFloor.floor2.localizedTitle, "Floor 2")
        XCTAssertEqual(ParkingFloor.floor3.localizedTitle, "Floor 3")

        XCTAssertEqual(ParkingFloor.m.levelSubtitle, "Mezzanine")
        XCTAssertEqual(ParkingFloor.floor1.levelSubtitle, "Level 1")
    }

    func testAccessibilityLabels() {
        for floor in ParkingFloor.allCases {
            XCTAssertFalse(floor.accessibilityLabel.isEmpty)
        }
    }
}
