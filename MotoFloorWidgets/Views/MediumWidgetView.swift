//
//  MediumWidgetView.swift
//  MotoFloorWidgets
//
//

import SwiftUI
import WidgetKit
import AppIntents

/// Medium Home Screen widget (systemMedium): Big, simple, tactile parking controls.
public struct MediumWidgetView: View {
    public let entry: ParkingEntry

    public init(entry: ParkingEntry) {
        self.entry = entry
    }

    public var body: some View {
        Group {
            if let floor = entry.floor {
                parkedMediumView(floor: floor)
            } else {
                emptyMediumView
            }
        }
        .containerBackground(for: .widget) {
            Color(uiColor: .secondarySystemBackground)
        }
    }

    // MARK: - State A: Parked State

    private func parkedMediumView(floor: ParkingFloor) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Subtle Branding Header
            HStack(spacing: 4) {
                Image(systemName: "motorcycle.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(MotoTheme.accentOrange)

                Text("MotoFloor")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.secondary)

                Spacer()
            }

            Spacer(minLength: 4)

            // Center Row: Saved Floor on Left, Big & Simple Floor Buttons on Right
            HStack(alignment: .center, spacing: 0) {
                // Left: Saved Floor Hero
                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(floor.shortTitle)
                            .font(.system(size: 54, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.primary)
                            .lineLimit(1)

                        Text("FLOOR")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .tracking(2.5)
                            .foregroundStyle(MotoTheme.accentOrange)
                    }

                    Text(entry.timestampDescription)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.secondary)
                }

                Spacer(minLength: 16)

                // Right: Big, Simple, Tactile Buttons
                HStack(spacing: 7) {
                    ForEach(ParkingFloor.allCases) { item in
                        let isSelected = item == floor
                        Button(intent: SetParkingFloorIntent(floor: item)) {
                            Text(item.shortTitle)
                                .font(.system(size: 21, weight: .bold, design: .rounded))
                                .foregroundStyle(isSelected ? Color.white : Color.primary)
                                .frame(width: 44, height: 52)
                                .background(
                                    isSelected
                                        ? MotoTheme.accentOrange
                                        : Color.primary.opacity(0.08)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Park on floor \(item.shortTitle)")
                    }
                }
            }

            Spacer(minLength: 2)
        }
    }

    // MARK: - State B: Empty State

    private var emptyMediumView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Subtle Branding Header
            HStack(spacing: 4) {
                Image(systemName: "motorcycle.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(MotoTheme.accentOrange)

                Text("MotoFloor")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.secondary)

                Spacer()
            }

            Spacer(minLength: 4)

            // Direct Prompt
            Text("Where did you park?")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.primary)

            Spacer(minLength: 8)

            // Big, Simple Floor Buttons: M  1  2  3
            HStack(spacing: 8) {
                ForEach(ParkingFloor.allCases) { floor in
                    Button(intent: SetParkingFloorIntent(floor: floor)) {
                        Text(floor.shortTitle)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.primary.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Park on floor \(floor.shortTitle)")
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Medium - Parked", as: .systemMedium) {
    MotoFloorWidget()
} timeline: {
    ParkingEntry(date: Date(), floor: .floor2, parkedAt: Date(), isStale: false, staleNotice: "")
    ParkingEntry(date: Date(), floor: nil, parkedAt: nil, isStale: false, staleNotice: "")
}
