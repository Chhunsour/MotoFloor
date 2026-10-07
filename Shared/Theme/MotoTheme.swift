//
//  MotoTheme.swift
//  MotoFloor
//

import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// Design system tokens for MotoFloor.
public enum MotoTheme {
    /// Sophisticated warm orange accent inspired by premium automotive dials and Apple action colors.
    public static let accentOrange = Color(red: 0.98, green: 0.44, blue: 0.12)
    public static let accentOrangeMuted = Color(red: 0.98, green: 0.44, blue: 0.12).opacity(0.18)
    public static let accentOrangeGlow = Color(red: 0.98, green: 0.44, blue: 0.12).opacity(0.22)
    public static let accentOrangeSubtle = Color(red: 0.98, green: 0.44, blue: 0.12).opacity(0.08)

    /// Neutral surface colors supporting Light and Dark modes.
    #if os(iOS)
    public static let backgroundCanvas = Color(uiColor: .systemBackground)
    public static let surfaceMaterial = Color(uiColor: .secondarySystemBackground)
    public static let elevatedSurface = Color(uiColor: .tertiarySystemBackground)
    #else
    public static let backgroundCanvas = Color(nsColor: .windowBackgroundColor)
    public static let surfaceMaterial = Color(nsColor: .controlBackgroundColor)
    public static let elevatedSurface = Color(nsColor: .underPageBackgroundColor)
    #endif

    /// Spring animations tailored for the parking pass experience.
    public static let passSpring = Animation.spring(response: 0.35, dampingFraction: 0.85)
    public static let tactileSpring = Animation.spring(response: 0.25, dampingFraction: 0.72)
}

