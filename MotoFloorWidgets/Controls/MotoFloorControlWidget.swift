//
//  MotoFloorControlWidget.swift
//  MotoFloorWidgets
//

import WidgetKit
import SwiftUI
import AppIntents

/// iOS 18+ ControlWidget for Control Center, Lock Screen Control button, and Action Button.
@available(iOS 18.0, *)
public struct MotoFloorControlWidget: ControlWidget {
    public static let kind: String = "com.chhunsour.motofloor.control"

    public init() {}

    public var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind) {
            ControlWidgetButton(action: OpenMotoFloorIntent()) {
                Label("MotoFloor", systemImage: "motorcycle")
            }
        }
        .displayName("MotoFloor")
        .description("Quickly access MotoFloor to record or view your parking floor.")
    }
}
