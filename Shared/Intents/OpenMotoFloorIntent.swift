//
//  OpenMotoFloorIntent.swift
//  MotoFloor
//

import AppIntents

/// App Intent to open the MotoFloor floor selector directly.
public struct OpenMotoFloorIntent: AppIntent {
    public static var title: LocalizedStringResource = "Open MotoFloor"
    public static var description = IntentDescription("Opens the MotoFloor app directly to set or view your parking floor.")
    public static var openAppWhenRun: Bool = true

    public init() {}

    public func perform() async throws -> some IntentResult {
        return .result()
    }
}
