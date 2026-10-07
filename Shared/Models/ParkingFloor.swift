//
//  ParkingFloor.swift
//  MotoFloor
//

import Foundation
import AppIntents

/// Represents one of the four multi-floor motorcycle parking levels.
public enum ParkingFloor: String, CaseIterable, Identifiable, Codable, Sendable, Hashable, AppEnum {
    case m = "M"
    case floor1 = "1"
    case floor2 = "2"
    case floor3 = "3"

    public var id: String { rawValue }

    // MARK: - AppEnum Conformance

    public static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Parking Floor")

    public static var caseDisplayRepresentations: [ParkingFloor: DisplayRepresentation] = [
        .m: DisplayRepresentation(title: "Floor M", subtitle: "Mezzanine level"),
        .floor1: DisplayRepresentation(title: "Floor 1", subtitle: "Level 1"),
        .floor2: DisplayRepresentation(title: "Floor 2", subtitle: "Level 2"),
        .floor3: DisplayRepresentation(title: "Floor 3", subtitle: "Level 3")
    ]

    // MARK: - Presentation Helpers

    /// Short label displayed inside floor buttons and widgets (e.g. "M", "1", "2", "3").
    public var shortTitle: String {
        rawValue
    }

    /// Descriptive title for speech and accessibility (e.g. "Floor M", "Floor 1").
    public var localizedTitle: String {
        switch self {
        case .m:
            return "Floor M"
        case .floor1:
            return "Floor 1"
        case .floor2:
            return "Floor 2"
        case .floor3:
            return "Floor 3"
        }
    }

    /// Detailed description for VoiceOver.
    public var accessibilityLabel: String {
        switch self {
        case .m:
            return "Mezzanine level, Floor M"
        case .floor1:
            return "Parking floor 1"
        case .floor2:
            return "Parking floor 2"
        case .floor3:
            return "Parking floor 3"
        }
    }

    /// Subtitle description (e.g. "Mezzanine", "Level 1").
    public var levelSubtitle: String {
        switch self {
        case .m:
            return "Mezzanine"
        case .floor1:
            return "Level 1"
        case .floor2:
            return "Level 2"
        case .floor3:
            return "Level 3"
        }
    }

    /// SF Symbol name representing this floor level.
    public var systemImageName: String {
        switch self {
        case .m:
            return "m.square.fill"
        case .floor1:
            return "1.square.fill"
        case .floor2:
            return "2.square.fill"
        case .floor3:
            return "3.square.fill"
        }
    }
}
