//
//  SmallWidgetView.swift
//  MotoFloorWidgets
//
//

import SwiftUI
import WidgetKit
import AppIntents

/// Small Home Screen widget (systemSmall): Glanceable Digital Parking Pass.
public struct SmallWidgetView: View {
    public let entry: ParkingEntry

    public init(entry: ParkingEntry) {
        self.entry = entry
    }

    public var body: some View {
        Group {
            if let floor = entry.floor {
                parkedView(floor: floor)
            } else {
                emptyView
            }
        }
        .containerBackground(for: .widget) {
            Color(uiColor: .secondarySystemBackground)
        }
    }

    // MARK: - State A: Parked State

    private func parkedView(floor: ParkingFloor) -> some View {
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

            Spacer(minLength: 2)

            // Hero: Enormous Floor Numeral with subtle warm glow
            ZStack {
                RadialGradient(
                    gradient: Gradient(colors: [
                        MotoTheme.accentOrange.opacity(0.12),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 50
                )
                .frame(width: 100, height: 100)

                VStack(alignment: .center, spacing: 1) {
                    Text(floor.shortTitle)
                        .font(.system(size: 78, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text("FLOOR")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(2.5)
                        .foregroundStyle(MotoTheme.accentOrange)
                }
            }
            .frame(maxWidth: .infinity)

            Spacer(minLength: 6)

            // Natural Language Timestamp
            Text(entry.timestampDescription)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Color.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    // MARK: - State B: Empty State

    private var emptyView: some View {
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

            Spacer(minLength: 0)

            // Prompt
            Text("Where did\nyou park?")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(Color.primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            // Big, Simple Floor Buttons: M  1  2  3
            HStack(spacing: 6) {
                ForEach(ParkingFloor.allCases) { floor in
                    Button(intent: SetParkingFloorIntent(floor: floor)) {
                        Text(floor.shortTitle)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.primary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.primary.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Park on floor \(floor.shortTitle)")
                }
            }
            .frame(height: 38)
        }
    }
}

// MARK: - Previews

#Preview("Small - Parked", as: .systemSmall) {
    MotoFloorWidget()
} timeline: {
    ParkingEntry(date: Date(), floor: .floor2, parkedAt: Date(), isStale: false, staleNotice: "")
    ParkingEntry(date: Date(), floor: nil, parkedAt: nil, isStale: false, staleNotice: "")
}
