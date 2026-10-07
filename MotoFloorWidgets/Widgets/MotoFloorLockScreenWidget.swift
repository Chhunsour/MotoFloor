//
//  MotoFloorLockScreenWidget.swift
//  MotoFloorWidgets
//

import WidgetKit
import SwiftUI

/// Lock Screen accessory widget supporting inline, circular, and rectangular accessories.
public struct MotoFloorLockScreenWidget: Widget {
    public static let kind: String = "com.chhunsour.motofloor.lockscreen-widget"

    public init() {}

    public var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: Self.kind,
            provider: ParkingTimelineProvider()
        ) { entry in
            LockScreenWidgetViews(entry: entry)
                .widgetURL(URL(string: "motofloor://open"))
        }
        .configurationDisplayName("MotoFloor Lock Screen")
        .description("Glance at your motorcycle parking floor instantly from the Lock Screen.")
        .supportedFamilies([
            .accessoryRectangular,
            .accessoryInline,
            .accessoryCircular
        ])
    }
}
