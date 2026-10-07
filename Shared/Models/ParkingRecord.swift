//
//  ParkingRecord.swift
//  MotoFloor
//

import Foundation

/// Represents a historical or current motorcycle parking event.
public struct ParkingRecord: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let floor: ParkingFloor
    public let parkedAt: Date

    public init(id: UUID = UUID(), floor: ParkingFloor, parkedAt: Date = Date()) {
        self.id = id
        self.floor = floor
        self.parkedAt = parkedAt
    }

    /// Formatted time representation (e.g. "8:47 AM").
    public var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: parkedAt)
    }

    /// Relative representation (e.g. "Today", "Yesterday", "Monday, Oct 6").
    public var relativeDateString: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(parkedAt) {
            return "Today"
        } else if calendar.isDateInYesterday(parkedAt) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: parkedAt)
        }
    }
}
