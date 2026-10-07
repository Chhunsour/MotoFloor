//
//  MotoFloorShortcuts.swift
//  MotoFloor
//

import AppIntents

/// Provides Siri and Shortcuts integration for MotoFloor.
public struct MotoFloorShortcuts: AppShortcutsProvider {
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SetParkingFloorIntent(),
            phrases: [
                "Parked on \(\.$floor) in \(.applicationName)",
                "Save parking floor in \(.applicationName)",
                "Set motorcycle parking in \(.applicationName)"
            ],
            shortTitle: "Set Parking Floor",
            systemImageName: "motorcycle"
        )
        AppShortcut(
            intent: ClearParkingIntent(),
            phrases: [
                "Clear parking in \(.applicationName)",
                "Leave parking in \(.applicationName)"
            ],
            shortTitle: "Clear Parking",
            systemImageName: "xmark.circle"
        )
    }

    public static var shortcutTileColor: ShortcutTileColor = .orange
}
