//
//  SetParkingFloorIntent.swift
//  MotoFloor
//

import AppIntents
import Foundation

/// App Intent for setting the motorcycle parking floor from widgets, Siri, Shortcuts, or Control Center.
public struct SetParkingFloorIntent: AppIntent {
    public static var title: LocalizedStringResource = "Set Parking Floor"
    public static var description = IntentDescription("Save your motorcycle parking floor with one tap.")

    public static var isDiscoverable: Bool = true
    public static var openAppWhenRun: Bool = false

    @Parameter(title: "Floor")
    public var floor: ParkingFloor

    public init() {}

    public init(floor: ParkingFloor) {
        self.floor = floor
    }

    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let store = ParkingStore.shared
        store.setFloor(floor)

        return .result(dialog: IntentDialog("Saved Floor \(floor.shortTitle). Have a great day!"))
    }
}
