//
//  ClearParkingIntent.swift
//  MotoFloor
//

import AppIntents
import Foundation

/// App Intent for clearing the active motorcycle parking floor.
public struct ClearParkingIntent: AppIntent {
    public static var title: LocalizedStringResource = "Clear Parking"
    public static var description = IntentDescription("Clear your current motorcycle parking floor.")

    public static var isDiscoverable: Bool = true
    public static var openAppWhenRun: Bool = false

    public init() {}

    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let store = ParkingStore.shared
        store.clearParking()

        return .result(dialog: IntentDialog("Parking floor cleared."))
    }
}
