//
//  MotoFloorWidgetsBundle.swift
//  MotoFloorWidgets
//

import WidgetKit
import SwiftUI

/// Main bundle exposing Home Screen widgets, Lock Screen widgets, and ControlCenter controls.
@main
struct MotoFloorWidgetsBundle: WidgetBundle {
    var body: some Widget {
        MotoFloorWidget()
        MotoFloorLockScreenWidget()
        if #available(iOS 18.0, *) {
            MotoFloorControlWidget()
        }
    }
}
