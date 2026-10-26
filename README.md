# MotoFloor 🏍️

<p align="center">
  <sub>Developed by <strong>Seng Chhunsour</strong></sub>
</p>

<p align="center">
  <a href="https://github.com/Chhunsour"><img src="https://img.shields.io/badge/Author-Seng%20Chhunsour-FF5A1F?style=flat-square&logo=github&logoColor=white" alt="Author: Seng Chhunsour" /></a>
  <img src="https://img.shields.io/badge/Platform-iOS%2017%2B-blue?style=flat-square&logo=apple" alt="iOS 17+" />
  <img src="https://img.shields.io/badge/Swift-5.9%2B-orange?style=flat-square&logo=swift" alt="Swift 5.9+" />
  <img src="https://img.shields.io/badge/Widgets-Interactive-purple?style=flat-square" alt="Widgets" />
</p>

> **Save your motorcycle parking floor in one tap and see it instantly later from your iPhone Home Screen or Lock Screen.**

MotoFloor is an ultra-focused, 100% native Apple-platform utility designed to solve a single everyday problem: never forgetting which floor (M, 1, 2, or 3) you parked your motorcycle on in a multi-level structure.

---

## ⭐️ Core Product Principles

- **Park → Tap one floor → Forget about it → Check later**
- The **widget** is the primary product; the full app is secondary.
- **100% offline & private**: Zero accounts, zero tracking, zero networking, zero database dependencies.
- Native Apple design language: System semantic colors, SF Symbols, refined typography, and tactile spring micro-interactions.

---

## 📱 Features

1. **One-Tap Floor Selection**: Tap `M`, `1`, `2`, or `3` to instantly record your floor, capture the exact timestamp, append history, and refresh all widgets. No confirmation dialogs, no navigation delays.
2. **Dominant Floor Display**: Massive typography (~104 pt rounded bold) designed to be recognizable in under one second.
3. **Interactive Home Screen Widgets**:
   - **`systemSmall`**: Interactive 2×2 button grid when empty; high-visibility floor emblem and timestamp when parked.
   - **`systemMedium`**: Side-by-side view with instant 1-tap floor switching directly from your Home Screen.
4. **Lock Screen Accessories**:
   - **`accessoryRectangular`**: Clean glanceable parking status and time.
   - **`accessoryInline`**: Compact `🛵 Floor 2 (8:47 AM)` readout.
   - **`accessoryCircular`**: Circular badge with motorcycle emblem and current level.
5. **WidgetKit Controls (iOS 18+)**:
   - Native Control Center button.
   - Lock Screen Control support.
   - Action Button integration.
6. **Smart Stale Record Handling**:
   - Parking records naturally age after 18 hours (customizable to 12h, 18h, 24h, or Never).
   - Automatically visually indicates a previous session without deleting historical data.
   - Widget automatically transitions to the stale state at the threshold time via timeline scheduling.
7. **Minimal History**:
   - Lightweight, grouped history preserving your latest 30 parking events.
8. **App Shortcuts & Siri**:
   - "Parked on Floor 2 in MotoFloor"
   - "Set parking floor in MotoFloor"
   - "Clear parking in MotoFloor"

---

## 🏛️ Architecture

```
MotoFloor/
├── MotoFloor.xcodeproj/          # Native Xcode project (App, Widgets, Tests)
├── Shared/
│   ├── Models/
│   │   ├── ParkingFloor.swift   # AppEnum model (M, 1, 2, 3)
│   │   └── ParkingRecord.swift  # Timestamped parking event model
│   ├── Storage/
│   │   └── ParkingStore.swift   # Centralized @Observable App Group store
│   ├── Theme/
│   │   └── MotoTheme.swift      # Semantic colors, typography, tactile springs
│   └── Intents/
│       ├── SetParkingFloorIntent.swift  # 1-tap interactive widget intent
│       ├── ClearParkingIntent.swift     # Clear parking intent
│       ├── OpenMotoFloorIntent.swift    # ControlWidget deep-link intent
│       └── MotoFloorShortcuts.swift     # Siri & Shortcuts provider
├── MotoFloor/                    # Main iOS Application
│   ├── App/
│   │   └── MotoFloorApp.swift
│   ├── Views/
│   │   ├── MainParkingView.swift
│   │   ├── FloorSelectorView.swift
│   │   ├── HistoryView.swift
│   │   ├── SettingsView.swift
│   │   └── OnboardingSheetView.swift
│   ├── Components/
│   │   ├── FloorButton.swift
│   │   ├── StatusHeaderView.swift
│   │   ├── FloorBadge.swift
│   │   └── StaleNoticeBanner.swift
│   ├── Utilities/
│   │   └── HapticManager.swift
│   └── Resources/
│       ├── Assets.xcassets/
│       ├── MotoFloor.entitlements
│       └── Info.plist
├── MotoFloorWidgets/             # WidgetKit Extension Target
│   ├── MotoFloorWidgetsBundle.swift
│   ├── Widgets/
│   │   ├── MotoFloorWidget.swift
│   │   └── MotoFloorLockScreenWidget.swift
│   ├── Controls/
│   │   └── MotoFloorControlWidget.swift
│   ├── Views/
│   │   ├── SmallWidgetView.swift
│   │   ├── MediumWidgetView.swift
│   │   └── LockScreenWidgetViews.swift
│   ├── Providers/
│   │   └── ParkingTimelineProvider.swift
│   └── Resources/
│       ├── Assets.xcassets/
│       ├── MotoFloorWidgets.entitlements
│       └── Info.plist
└── MotoFloorTests/               # Unit Test Suite
    ├── ParkingFloorTests.swift
    ├── ParkingRecordTests.swift
    ├── ParkingStoreTests.swift
    ├── StaleRecordTests.swift
    └── StandaloneTestRunner.swift
```

---

## 🛠️ App Group & Entitlements Configuration

Both the **MotoFloor** application target and the **MotoFloorWidgets** extension target are configured with the shared App Group:

```
group.com.chhunsour.motofloor
```

- Entitlements files:
  - `MotoFloor/Resources/MotoFloor.entitlements`
  - `MotoFloorWidgets/Resources/MotoFloorWidgets.entitlements`
- Storage identifier constant:
  - `ParkingStore.appGroupIdentifier = "group.com.chhunsour.motofloor"`

> **Note on Custom Bundle / App Group Identifiers:**
> If you publish to your Apple Developer Account, update the Bundle Identifier (`com.yourdomain.motofloor`) and App Group (`group.com.yourdomain.motofloor`) in the targets' Signing & Capabilities tab in Xcode and update `ParkingStore.appGroupIdentifier` accordingly.

---

## 🧪 Automated Testing

### Standalone CLI Verification
The suite includes an autonomous verification runner that executes tests directly against the Swift toolchain:

```bash
cd /Users/mac/.gemini/antigravity/scratch/MotoFloor
swiftc -sdk $(xcrun --show-sdk-path) \
  Shared/Models/*.swift Shared/Storage/*.swift Shared/Theme/*.swift Shared/Intents/*.swift \
  MotoFloorTests/StandaloneTestRunner.swift \
  -o /tmp/motofloor_test && /tmp/motofloor_test
```

### In Xcode
Open `MotoFloor.xcodeproj` in Xcode and press `Cmd + U` to execute the full unit test suite.

---

## 🚀 Opening in Xcode & CLI License Note

1. To open the project in Xcode:
   ```bash
   open /Users/mac/.gemini/antigravity/scratch/MotoFloor/MotoFloor.xcodeproj
   ```
2. **Xcode Command Line Tools License**:
   If building via the `xcodebuild` command line tool for the first time on a fresh macOS installation, Apple requires accepting the license once in Terminal:
   ```bash
   sudo xcodebuild -license accept
   ```

---

## 👤 Author & Developer

**Developed by Seng Chhunsour**
- **GitHub:** [@Chhunsour](https://github.com/Chhunsour)
- **Repository:** [https://github.com/Chhunsour/MotoFloor](https://github.com/Chhunsour/MotoFloor)

---

## 📄 License

Personal and open-source project. Developed by Seng Chhunsour. All rights reserved.
