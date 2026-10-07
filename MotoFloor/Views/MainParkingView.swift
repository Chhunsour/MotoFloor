//
//  MainParkingView.swift
//  MotoFloor
//
//

import SwiftUI

/// Redesigned MotoFloor main screen: "A Digital Motorcycle Parking Pass".
/// The entire screen is the pass itself. Zero card clutter. Pure typographic clarity.
public struct MainParkingView: View {
    @Bindable var store: ParkingStore

    @State private var showingHistorySheet = false
    @State private var showingSettingsSheet = false
    @State private var showingOnboardingSheet = false

    public init(store: ParkingStore = .shared) {
        self.store = store
    }

    private var isParked: Bool {
        store.currentParkingFloor != nil
    }

    private var isStale: Bool {
        store.isCurrentParkingStale()
    }

    public var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                let availableHeight = proxy.size.height
                let floorFontSize: CGFloat = availableHeight < 700 ? 124 : (availableHeight < 850 ? 152 : 168)

                ZStack {
                    // Atmospheric pass background
                    backgroundCanvas

                    VStack(spacing: 0) {
                        // Top Header Row
                        topHeaderBar
                            .padding(.top, 8)
                            .padding(.horizontal, 24)

                        Spacer(minLength: 16)

                        // HERO AREA: Parked Pass or Empty Prompt
                        ZStack {
                            // Faint architectural garage level lines
                            garageBackdrop(activeFloor: isStale ? nil : store.currentParkingFloor)

                            if let floor = store.currentParkingFloor {
                                parkedHeroPass(floor: floor, fontSize: floorFontSize)
                                    .transition(.asymmetric(
                                        insertion: .scale(scale: 0.94).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                            } else {
                                emptyHeroPrompt
                                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: .infinity)

                        Spacer(minLength: 24)

                        // THE HERO FLOOR SELECTOR
                        // Unified physical-garage selector. Always visible and reachable with one hand.
                        FloorSelectorView(
                            selectedFloor: isStale ? nil : store.currentParkingFloor,
                            onSelect: { floor in
                                withAnimation(MotoTheme.passSpring) {
                                    store.setFloor(floor)
                                }
                            }
                        )
                        .padding(.horizontal, 24)
                        .padding(.bottom, max(proxy.safeAreaInsets.bottom, 24))
                    }
                    .animation(MotoTheme.passSpring, value: store.currentParkingFloor)
                    .animation(MotoTheme.passSpring, value: isStale)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingHistorySheet) {
                HistoryView(store: store)
            }
            .sheet(isPresented: $showingSettingsSheet) {
                SettingsView(store: store)
            }
            .sheet(isPresented: $showingOnboardingSheet) {
                OnboardingSheetView(onGetStarted: {
                    store.hasSeenOnboarding = true
                    showingOnboardingSheet = false
                })
            }
            .onChange(of: store.currentParkingFloor) { _, newFloor in
                if newFloor != nil {
                    store.hasSeenOnboarding = true
                    showingOnboardingSheet = false
                }
            }
            .onAppear {
                store.reloadFromStorage()
            }
        }
    }

    // MARK: - Top Header Bar

    private var topHeaderBar: some View {
        HStack(alignment: .center) {
            // MotoFloor Brand
            HStack(spacing: 8) {
                Image(systemName: "motorcycle.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(MotoTheme.accentOrange)

                Text("MotoFloor")
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.primary)
            }

            Spacer()

            // Ellipsis Menu
            Menu {
                if store.currentParkingFloor != nil {
                    Button(role: .destructive) {
                        HapticManager.shared.parkingCleared()
                        withAnimation(MotoTheme.passSpring) {
                            store.clearParking()
                        }
                    } label: {
                        Label("Clear Parking", systemImage: "xmark.circle")
                    }

                    Divider()
                }

                Button {
                    showingHistorySheet = true
                } label: {
                    Label("Parking History", systemImage: "clock.arrow.circlepath")
                }

                Button {
                    showingSettingsSheet = true
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.primary)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(MotoTheme.surfaceMaterial)
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                    )
            }
            .accessibilityLabel("Options")
        }
    }

    // MARK: - Atmospheric Canvas Background

    private var backgroundCanvas: some View {
        ZStack {
            MotoTheme.backgroundCanvas
                .ignoresSafeArea()

            // Subtle warm atmospheric glow positioned behind the active parking pass
            if isParked && !isStale {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                MotoTheme.accentOrange.opacity(0.12),
                                MotoTheme.accentOrange.opacity(0.03),
                                .clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 220
                        )
                    )
                    .frame(width: 420, height: 420)
                    .blur(radius: 50)
                    .offset(y: -40)
            }
        }
    }

    // MARK: - Parked Pass Hero State

    private func parkedHeroPass(floor: ParkingFloor, fontSize: CGFloat) -> some View {
        VStack(spacing: 8) {
            // Subtle eyebrow label
            HStack(spacing: 6) {
                if isStale {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                    Text("PREVIOUS SESSION")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .tracking(2.4)
                        .foregroundStyle(Color.secondary)
                } else {
                    Image(systemName: "motorcycle.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(MotoTheme.accentOrange)
                    Text("PARKED ON")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .tracking(2.4)
                        .foregroundStyle(Color.secondary)
                }
            }
            .padding(.bottom, 4)

            // THE DOMINANT FLOOR NUMERAL
            Text(floor.shortTitle)
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .foregroundStyle(isStale ? Color.secondary : Color.primary)
                .contentTransition(.numericText())
                .frame(minWidth: 160)

            // Sub-headline: FLOOR
            Text(isStale ? "LAST PARKED" : "FLOOR")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .tracking(5.0)
                .foregroundStyle(isStale ? Color.secondary : MotoTheme.accentOrange)

            // Natural language timestamp
            Text(isStale ? store.staleFormattedDescription() : store.naturalParkedDescription)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Color.secondary)
                .padding(.top, 4)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            isStale
                ? "Previous parking floor \(floor.shortTitle), \(store.staleFormattedDescription())"
                : "Parked on floor \(floor.shortTitle), \(store.naturalParkedDescription)"
        )
    }

    // MARK: - Empty State Hero Prompt

    private var emptyHeroPrompt: some View {
        VStack(spacing: 20) {
            // Refined emblem
            ZStack {
                Circle()
                    .fill(MotoTheme.surfaceMaterial)
                    .frame(width: 88, height: 88)
                    .overlay(
                        Circle()
                            .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                    )

                Image(systemName: "motorcycle")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(MotoTheme.accentOrange)
            }

            VStack(spacing: 8) {
                Text("Where did you park?")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.primary)

                Text("Choose your floor")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.secondary)
            }
        }
    }

    // MARK: - Minimal Garage Deck Lines

    /// Architectural representation of multi-level garage decks (Level 3, Level 2, Level 1, Level M).
    /// Soft horizontal lines with center fade so they don't visually interfere with the big floor numeral.
    private func garageBackdrop(activeFloor: ParkingFloor?) -> some View {
        VStack(spacing: 48) {
            garageDeckLine(floor: .floor3, activeFloor: activeFloor)
            garageDeckLine(floor: .floor2, activeFloor: activeFloor)
            garageDeckLine(floor: .floor1, activeFloor: activeFloor)
            garageDeckLine(floor: .m, activeFloor: activeFloor)
        }
        .padding(.horizontal, 32)
        .opacity(0.6)
    }

    private func garageDeckLine(floor: ParkingFloor, activeFloor: ParkingFloor?) -> some View {
        let isActive = floor == activeFloor
        return HStack(spacing: 12) {
            // Left subtle line
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            isActive ? MotoTheme.accentOrange.opacity(0.3) : Color.primary.opacity(0.08),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: isActive ? 1.5 : 1)

            Spacer()

            // Right subtle line + level mark
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .clear,
                            isActive ? MotoTheme.accentOrange.opacity(0.3) : Color.primary.opacity(0.08)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: isActive ? 1.5 : 1)

            Text(floor.shortTitle)
                .font(.system(size: 10, weight: isActive ? .bold : .medium, design: .rounded))
                .foregroundStyle(isActive ? MotoTheme.accentOrange : Color.secondary.opacity(0.35))
                .frame(width: 14)
        }
    }
}

#Preview("Main Parking View - Floor 2") {
    let defaults = UserDefaults()
    let store = ParkingStore(userDefaults: defaults)
    store.setFloor(.floor2)
    return MainParkingView(store: store)
}

#Preview("Main Parking View - Empty State") {
    MainParkingView(store: ParkingStore(userDefaults: UserDefaults()))
}

#Preview("Main Parking View - Dark Mode") {
    let defaults = UserDefaults()
    let store = ParkingStore(userDefaults: defaults)
    store.setFloor(.floor2)
    return MainParkingView(store: store)
        .preferredColorScheme(.dark)
}
