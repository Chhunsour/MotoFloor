//
//  MotoFloorWidget.swift
//  MotoFloorWidgets
//

import WidgetKit
import SwiftUI

/// Main Home Screen widget supporting systemSmall and systemMedium.
public struct MotoFloorWidget: Widget {
    public static let kind: String = "com.chhunsour.motofloor.widget"

    public init() {}

    public var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: Self.kind,
            provider: ParkingTimelineProvider()
        ) { entry in
            MotoFloorWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("MotoFloor")
        .description("Quickly view and save your motorcycle parking floor.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

/// Router view dispatching to SmallWidgetView or MediumWidgetView.
struct MotoFloorWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: ParkingEntry

    var body: some View {
        switch family {
        case .systemMedium:
            MediumWidgetView(entry: entry)
                .widgetURL(URL(string: "motofloor://open"))
        default:
            SmallWidgetView(entry: entry)
                .widgetURL(URL(string: "motofloor://open"))
        }
    }
}
