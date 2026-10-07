//
//  OnboardingSheetView.swift
//  MotoFloor
//

import SwiftUI

/// Minimal, single-screen introduction on first app launch.
public struct OnboardingSheetView: View {
    @Environment(\.dismiss) private var dismiss
    public let onGetStarted: () -> Void

    public init(onGetStarted: @escaping () -> Void) {
        self.onGetStarted = onGetStarted
    }

    public var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon Emblem
            ZStack {
                Circle()
                    .fill(MotoTheme.accentOrangeSubtle)
                    .frame(width: 108, height: 108)

                Image(systemName: "motorcycle")
                    .font(.system(size: 52, weight: .semibold))
                    .foregroundStyle(MotoTheme.accentOrange)
            }

            // Headline
            VStack(spacing: 12) {
                Text("MotoFloor")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.primary)

                Text("Never forget your parking floor again.")
                    .font(.system(size: 19, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
            }

            // Value Points
            VStack(alignment: .leading, spacing: 18) {
                FeatureRow(
                    icon: "hand.tap.fill",
                    title: "One-Tap Saving",
                    description: "Select M, 1, 2, or 3 with one tap after parking."
                )

                FeatureRow(
                    icon: "apps.iphone",
                    title: "Instant Widget Access",
                    description: "Glance at your floor directly from your Lock Screen or Home Screen."
                )

                FeatureRow(
                    icon: "lock.shield.fill",
                    title: "100% Offline & Private",
                    description: "No accounts, no tracking, no external network requests."
                )
            }
            .padding(.horizontal, 16)

            Spacer()

            // Action Button
            Button(action: {
                HapticManager.shared.success()
                onGetStarted()
                dismiss()
            }) {
                Text("Get Started")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(MotoTheme.accentOrange)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: MotoTheme.accentOrangeGlow, radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .padding()
        .background(MotoTheme.backgroundCanvas)
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(MotoTheme.accentOrange)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.primary)

                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.secondary)
            }
        }
    }
}

#Preview {
    OnboardingSheetView(onGetStarted: {})
}
