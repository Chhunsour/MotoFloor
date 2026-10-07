//
//  SettingsView.swift
//  MotoFloor
//

import SwiftUI

/// Simple, focused settings sheet for MotoFloor preferences.
public struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var store: ParkingStore

    @State private var showingClearConfirmation = false

    public init(store: ParkingStore) {
        self.store = store
    }

    private let staleOptions: [(title: String, hours: Int)] = [
        ("12 Hours", 12),
        ("18 Hours (Default)", 18),
        ("24 Hours", 24),
        ("Never", 0)
    ]

    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Mark Stale After", selection: $store.staleThresholdHours) {
                        ForEach(staleOptions, id: \.hours) { option in
                            Text(option.title).tag(option.hours)
                        }
                    }
                    .pickerStyle(.menu)

                    Toggle("Haptic Feedback", isOn: $store.hapticsEnabled)
                        .tint(MotoTheme.accentOrange)
                } header: {
                    Text("Preferences")
                } footer: {
                    Text("After this duration, your parking record will display as a previous session so you never confuse yesterday's floor for today's.")
                }

                if store.currentParkingFloor != nil {
                    Section {
                        Button(role: .destructive) {
                            showingClearConfirmation = true
                        } label: {
                            HStack {
                                Spacer()
                                Text("Clear Current Parking")
                                    .fontWeight(.medium)
                                Spacer()
                            }
                        }
                    } footer: {
                        Text("Clears your current floor. Previous history records are preserved.")
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (Native)")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Storage")
                        Spacer()
                        Text("100% Offline & Private")
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("MotoFloor")
                            .font(.subheadline.bold())
                        Text("Designed to do one job perfectly: remember your motorcycle parking floor in one tap from your iPhone Home Screen or Lock Screen.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .confirmationDialog(
                "Clear Current Parking?",
                isPresented: $showingClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear Parking", role: .destructive) {
                    HapticManager.shared.parkingCleared()
                    store.clearParking()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to clear your current parking floor?")
            }
        }
    }
}

#Preview {
    SettingsView(store: ParkingStore.shared)
}
