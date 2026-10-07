//
//  HapticManager.swift
//  MotoFloor
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// Manages tactile haptic feedback throughout MotoFloor.
public final class HapticManager: @unchecked Sendable {
    public static let shared = HapticManager()

    #if os(iOS)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationFeedback = UINotificationFeedbackGenerator()
    #endif

    private init() {
        #if os(iOS)
        selectionFeedback.prepare()
        impactMedium.prepare()
        #endif
    }

    /// Haptic played when selecting or switching a parking floor.
    public func floorSelected() {
        guard ParkingStore.shared.hapticsEnabled else { return }
        #if os(iOS)
        impactMedium.prepare()
        impactMedium.impactOccurred(intensity: 0.85)
        #elseif os(macOS)
        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
        #endif
    }

    /// Haptic played when toggling or stepping options.
    public func selectionChanged() {
        guard ParkingStore.shared.hapticsEnabled else { return }
        #if os(iOS)
        selectionFeedback.prepare()
        selectionFeedback.selectionChanged()
        #elseif os(macOS)
        NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
        #endif
    }

    /// Haptic played on clearing parking or destructive actions.
    public func parkingCleared() {
        guard ParkingStore.shared.hapticsEnabled else { return }
        #if os(iOS)
        notificationFeedback.prepare()
        notificationFeedback.notificationOccurred(.warning)
        #elseif os(macOS)
        NSHapticFeedbackManager.defaultPerformer.perform(.levelChange, performanceTime: .now)
        #endif
    }

    /// Haptic played for successful milestone actions (e.g. onboarding done).
    public func success() {
        guard ParkingStore.shared.hapticsEnabled else { return }
        #if os(iOS)
        notificationFeedback.prepare()
        notificationFeedback.notificationOccurred(.success)
        #elseif os(macOS)
        NSHapticFeedbackManager.defaultPerformer.perform(.levelChange, performanceTime: .now)
        #endif
    }
}
