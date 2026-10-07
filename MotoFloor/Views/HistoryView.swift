//
//  HistoryView.swift
//  MotoFloor
//
//

import SwiftUI

/// Understated native history list displaying past parking sessions.
public struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var store: ParkingStore

    @State private var showingClearConfirmation = false

    public init(store: ParkingStore) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            Group {
                if store.parkingHistory.isEmpty {
                    emptyHistoryView
                } else {
                    historyList
                }
            }
            .navigationTitle("Parking History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !store.parkingHistory.isEmpty {
                        Button(role: .destructive) {
                            showingClearConfirmation = true
                        } label: {
                            Text("Clear")
                                .foregroundStyle(.red)
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .confirmationDialog(
                "Clear Parking History?",
                isPresented: $showingClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear All History", role: .destructive) {
                    HapticManager.shared.parkingCleared()
                    store.clearHistory()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will remove all past parking records. Your current parking floor will not be affected.")
            }
        }
    }

    private var emptyHistoryView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(Color.secondary)

            Text("No Parking History")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.primary)

            Text("Your recent parking sessions will appear here automatically.")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MotoTheme.surfaceMaterial)
    }

    private var historyList: some View {
        List {
            ForEach(groupedHistory(), id: \.dateKey) { group in
                Section {
                    ForEach(group.records) { record in
                        HStack(alignment: .center) {
                            // Clean floor numeral
                            HStack(spacing: 10) {
                                Text(record.floor.shortTitle)
                                    .font(.system(size: 26, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.primary)
                                    .frame(width: 32, alignment: .leading)

                                Text(record.floor.levelSubtitle)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                            }

                            Spacer()

                            Text(record.timeString)
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.secondary)
                        }
                        .padding(.vertical, 6)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(record.floor.localizedTitle), \(group.dateTitle) at \(record.timeString)")
                    }
                } header: {
                    Text(group.dateTitle.uppercased())
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .tracking(1.4)
                        .foregroundStyle(Color.secondary)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Grouping Helper

    private struct DateGroup {
        let dateKey: String
        let dateTitle: String
        let records: [ParkingRecord]
    }

    private func groupedHistory() -> [DateGroup] {
        let calendar = Calendar.current
        var groups: [DateGroup] = []
        let dict = Dictionary(grouping: store.parkingHistory) { record -> Date in
            calendar.startOfDay(for: record.parkedAt)
        }

        let sortedKeys = dict.keys.sorted(by: >)
        for key in sortedKeys {
            guard let items = dict[key] else { continue }
            let title: String
            if calendar.isDateInToday(key) {
                title = "Today"
            } else if calendar.isDateInYesterday(key) {
                title = "Yesterday"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE, MMM d"
                title = formatter.string(from: key)
            }
            groups.append(DateGroup(dateKey: key.description, dateTitle: title, records: items))
        }

        return groups
    }
}

#Preview {
    HistoryView(store: ParkingStore.shared)
}
