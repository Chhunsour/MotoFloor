//
//  FloorSelectorView.swift
//  MotoFloor
//
//

import SwiftUI

/// Cohesive, tactile floor selector styled like a physical parking garage level selector.
/// Renders M, 1, 2, 3 in a unified pill-segmented bar with matchedGeometryEffect animation.
public struct FloorSelectorView: View {
    public let selectedFloor: ParkingFloor?
    public let onSelect: (ParkingFloor) -> Void
    @Namespace private var internalNamespace

    public init(
        selectedFloor: ParkingFloor?,
        onSelect: @escaping (ParkingFloor) -> Void
    ) {
        self.selectedFloor = selectedFloor
        self.onSelect = onSelect
    }

    public var body: some View {
        HStack(spacing: 6) {
            ForEach(ParkingFloor.allCases) { floor in
                FloorSelectorItem(
                    floor: floor,
                    isSelected: selectedFloor == floor,
                    namespace: internalNamespace,
                    onTap: {
                        onSelect(floor)
                    }
                )
            }
        }
        .padding(6)
        .frame(height: 72)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(MotoTheme.surfaceMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
    }
}

/// Individual floor item within the unified selector.
private struct FloorSelectorItem: View {
    let floor: ParkingFloor
    let isSelected: Bool
    let namespace: Namespace.ID
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            HapticManager.shared.floorSelected()
            onTap()
        }) {
            ZStack {
                if isSelected {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(MotoTheme.accentOrange)
                        .matchedGeometryEffect(id: "selector_highlight", in: namespace)
                        .shadow(color: MotoTheme.accentOrangeGlow, radius: 8, x: 0, y: 3)
                }

                VStack(spacing: 1) {
                    Text(floor.shortTitle)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(isSelected ? Color.white : Color.primary)

                    if floor == .m {
                        Text("MEZZ")
                            .font(.system(size: 8, weight: .bold, design: .rounded))
                            .tracking(0.6)
                            .foregroundStyle(isSelected ? Color.white.opacity(0.85) : Color.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(FloorPillButtonStyle(isPressed: $isPressed))
        .accessibilityLabel(floor.accessibilityLabel)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// Subtle tactile spring button style for the selector pills.
private struct FloorPillButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(MotoTheme.tactileSpring, value: configuration.isPressed)
    }
}

#Preview("Floor Selector - None Selected") {
    FloorSelectorView(selectedFloor: nil) { _ in }
        .padding()
}

#Preview("Floor Selector - Floor 2 Selected") {
    FloorSelectorView(selectedFloor: .floor2) { _ in }
        .padding()
}
