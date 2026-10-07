//
//  LockScreenWidgetViews.swift
//  MotoFloorWidgets
//
//

import SwiftUI
import WidgetKit
import AppIntents

/// Refined Lock Screen accessory views (accessoryRectangular, accessoryInline, accessoryCircular).
public struct LockScreenWidgetViews: View {
    @Environment(\.widgetFamily) private var family
    public let entry: ParkingEntry

    public init(entry: ParkingEntry) {
        self.entry = entry
    }

    public var body: some View {
        Group {
            switch family {
            case .accessoryInline:
                inlineView
            case .accessoryCircular:
                circularView
            default:
                rectangularView
            }
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }

    // MARK: - Inline Accessory (Above the Lock Screen Clock)

    private var inlineView: some View {
        Group {
            if let floor = entry.floor {
                Text("🛵 Floor \(floor.shortTitle) · \(entry.timeString)")
            } else {
                Text("🛵 MotoFloor: Not parked")
            }
        }
    }

    // MARK: - Rectangular Accessory (Below the Lock Screen Clock)

    private var rectangularView: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Header
            HStack(spacing: 4) {
                Image(systemName: "motorcycle.fill")
                    .font(.system(size: 9, weight: .semibold))
                Text("MOTOFLOOR")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.4)
            }
            .foregroundStyle(.secondary)

            if let floor = entry.floor {
                Text("Floor \(floor.shortTitle)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Text(entry.timestampDescription)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            } else {
                Text("Where did you park?")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text("Tap to record floor")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Circular Accessory (Below the Lock Screen Clock)

    private var circularView: some View {
        ZStack {
            AccessoryWidgetBackground()

            if let floor = entry.floor {
                VStack(spacing: 1) {
                    Image(systemName: "motorcycle.fill")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)

                    Text(floor.shortTitle)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                }
            } else {
                VStack(spacing: 1) {
                    Image(systemName: "motorcycle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.primary)

                    Text("PARK")
                        .font(.system(size: 8, weight: .bold, design: .rounded))
                        .tracking(1.2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Circular - Parked", as: .accessoryCircular) {
    MotoFloorLockScreenWidget()
} timeline: {
    ParkingEntry(date: Date(), floor: .floor2, parkedAt: Date(), isStale: false, staleNotice: "")
    ParkingEntry(date: Date(), floor: nil, parkedAt: nil, isStale: false, staleNotice: "")
}

#Preview("Rectangular - Parked", as: .accessoryRectangular) {
    MotoFloorLockScreenWidget()
} timeline: {
    ParkingEntry(date: Date(), floor: .floor2, parkedAt: Date(), isStale: false, staleNotice: "")
    ParkingEntry(date: Date(), floor: nil, parkedAt: nil, isStale: false, staleNotice: "")
}

#Preview("Inline - Parked", as: .accessoryInline) {
    MotoFloorLockScreenWidget()
} timeline: {
    ParkingEntry(date: Date(), floor: .floor2, parkedAt: Date(), isStale: false, staleNotice: "")
}
