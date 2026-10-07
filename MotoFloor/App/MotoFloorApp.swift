//
//  MotoFloorApp.swift
//  MotoFloor
//

import SwiftUI

@main
struct MotoFloorApp: App {
    @State private var store = ParkingStore.shared

    init() {
        if CommandLine.arguments.contains("--clear-parking") {
            ParkingStore.shared.clearParking()
        } else if CommandLine.arguments.contains("--floor-2") {
            ParkingStore.shared.setFloor(.floor2)
        } else if CommandLine.arguments.contains("--floor-m") {
            ParkingStore.shared.setFloor(.m)
        } else if CommandLine.arguments.contains("--floor-1") {
            ParkingStore.shared.setFloor(.floor1)
        } else if CommandLine.arguments.contains("--floor-3") {
            ParkingStore.shared.setFloor(.floor3)
        }
    }

    var body: some Scene {
        WindowGroup {
            MainParkingView(store: store)
                .onOpenURL { url in
                    handleIncomingURL(url)
                }
        }
    }

    private func handleIncomingURL(_ url: URL) {
        // Handle widget deep link scheme motofloor://floor/{floor} or motofloor://clear
        guard url.scheme == "motofloor" else { return }
        if url.host == "clear" {
            store.clearParking()
        } else if url.host == "floor", let floorRaw = url.pathComponents.dropFirst().first,
           let floor = ParkingFloor(rawValue: floorRaw) {
            store.setFloor(floor)
        }
    }
}
