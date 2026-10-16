# Project X — Native iOS SpringBoard Customization Toolkit

A native iOS application built with **Swift 6** and **SwiftUI** for on-device management and payload generation of supported SpringBoard preferences and Developer Mode pairing integration.

---

## 1. Architecture Overview

Project X is structured as a native modular Swift 6 / SwiftUI application targeting iOS 18.0 through iOS 27.x.

```
X/
├── App/
│   ├── XApp.swift                 # SwiftUI Application Entry Point & Adaptive Navigation
│   └── AppEnvironment.swift       # Shared App Coordinator & State Container
├── Models/
│   ├── DeviceStatus.swift         # Device Platform, Capability & PairingRecord Models
│   ├── TweakDefinition.swift      # Audited SpringBoard Tweaks with Support Classifications
│   ├── OperationResult.swift      # Explicit Honest States (notConfigured, ready, connecting, etc.)
│   └── PlistDocument.swift        # Native Document conforming to FileDocument using Foundation
├── Views/
│   ├── DashboardView.swift        # System Overview, Sandbox Status & Quick Actions
│   ├── DevicePairingView.swift    # Pairing File Import & Bonjour Advertisement
│   ├── CustomizationView.swift    # Audited Tweak Toggles, Validation & Staged Deployment
│   ├── PlistInspectorView.swift   # XML & Binary Plist Inspector with native File Exporter/Share
│   ├── DiagnosticsView.swift      # Live Diagnostic & Security Event Console
│   └── SettingsView.swift         # Sandbox Boundaries, Compatibility Matrix & Disconnect
├── Services/
│   ├── DeviceStatusService.swift  # Truthful Sandbox & Target Path Detection
│   ├── PairingService.swift       # Pairing Record Validator & Bonjour Lifecycle
│   ├── CustomizationService.swift # Preference Staging & Sandbox Boundary Enforcement
│   ├── PlistService.swift         # Foundation PropertyListSerialization Engine
│   └── DiagnosticsService.swift   # Real Diagnostic Logging Engine
├── Native/
│   ├── NativeBridge.swift         # Dynamic Safe C ABI / External FFI Boundary
│   └── NativeBridgeErrors.swift   # Strongly-Typed FFI & Native Platform Errors
└── Resources/
    ├── Assets.xcassets/           # AppIcon & Color Catalogs
    ├── Info.plist                 # Bundle Configuration & Bonjour Service Declarations
    └── X.entitlements             # Multicast Network Entitlement
```

---

## 2. Honest Feature Matrix

Per Project X engineering rules, no feature claims success through simulation, fake timers, synthetic certificates, or placeholder pairing records.

| Feature | Classification | Implementation Status | Notes / Limitations |
|---|---|---|---|
| **SwiftUI Navigation & Adaptive UI** | Implemented & Tested | Complete | Dual layout for iPhone (`TabView`) and iPad (`NavigationSplitView`). |
| **XML Plist Generation** | Implemented & Tested | Complete | Foundation `PropertyListSerialization` output targeting `/var/Managed Preferences/mobile/com.apple.springboard.plist`. |
| **Binary Plist (bplist00) Generation** | Implemented & Tested | Complete | Generates genuine binary plists with verified `bplist00` magic header. |
| **Pairing Record Validation** | Implemented & Tested | Complete | Validates `SystemBUID`, `HostID`, `HostModel`, and certificates from `.mobiledevicepairing` or `.plist`. |
| **Diagnostic Logging & Export** | Implemented & Tested | Complete | Captures system, security, and operation logs with plain-text export. |
| **Document Import & Export** | Implemented & Tested | Complete | Uses native SwiftUI `.fileExporter`, `.fileImporter`, and `ShareLink`. |
| **SpringBoard Preference Staging** | Configuration Only | Complete | Saves staged preferences to local container; generates exportable configuration. |
| **Direct Filesystem Application** | Blocked / Sandbox Restricted | Handled Transparently | Standard retail iOS sandbox forbids direct writes to `/var/Managed Preferences/` without root or privileged helper. |
| **System Respring** | Blocked / Privilege Restricted | Handled Transparently | Triggering SpringBoard reload requires private frontboard entitlements; rejects fake timer simulations. |
| **Bonjour Service Advertisement** | Implemented | Untested on Hardware | Broadcasts `_airtraffic._tcp` on local network; requires external client to handshake. |

---

## 3. Audited SpringBoard Tweaks Breakdown

| Tweak ID | Title | SpringBoard Key | Support Classification | Source Evidence |
|---|---|---|---|---|
| `dynamicIslandSnapshots` | Dynamic Island in Screenshots | `SBAlwaysShowSystemApertureInSnapshots` | **Verified Supported** | Official Apple System Aperture configuration key for developer screen capture. |
| `supervision` | Show Supervision Text | `SBShowSupervisionTextOnLockScreen` | **Verified Supported** | Standard Apple MDM managed preference dictionary key recognized by SpringBoard. |
| `lowBattery` | Disable Low Battery Alerts | `SBHideLowPowerAlerts` | **Configuration Only** | com.apple.springboard preference key present in iOS 14-26 SpringBoard binaries. |
| `acPower` | Hide AC Power on Lock Screen | `SBHideACPower` | **Configuration Only** | SpringBoard LockScreenUI preference key; confirmed active in managed environments. |
| `chargingDim` | Disable Screen Dimming While Charging | `SBDontDimOrLockOnAC` | **Configuration Only** | Apple kiosk/display unit configuration key for SpringBoard power management. |
| `breadcrumb` | Disable Breadcrumbs | `SBNeverBreadcrumb` | **Configuration Only** | Standard SpringBoard preference key parsed during status bar layout construction. |
| `respringLock` | Disable Lock After Respring | `SBDontLockAfterCrash` | **Unverified Experimental** | Internal debug flag present in Apple engineering builds; behavior varies on retail iOS. |
| `authenticationLine` | Authentication Line | `SBShowAuthenticationEngineeringUI` | **Unverified Experimental** | Internal BiometricKit / SpringBoard UI flag; disabled by default on retail kernels. |

---

## 4. Building the Application

### Prerequisites for macOS
- macOS 14.0 or newer (macOS 15 recommended)
- Xcode 16.0 or newer with iOS 18.0+ SDK
- XcodeGen: `brew install xcodegen`

### Build Commands
```bash
# 1. Verify prerequisites
./verify-prereqs.sh

# 2. Run schema and validation tests
./run-tests.sh

# 3. Generate Xcode project
xcodegen generate

# 4. Build application & package unsigned IPA
./build-ios.sh
```

### Continuous Integration (GitHub Actions)
The repository includes `.github/workflows/build-and-test.yml` configured on the official `macos-15` runner. Each commit automatically generates the Xcode project, executes unit tests, and packages the unsigned IPA artifact (`build/X.ipa`).

---

## 5. Sideloading & Installation Instructions

An unsigned IPA cannot be directly installed onto an iOS device without code signing. Use one of the following methods:

1. **SideStore / AltStore**:
   - Open SideStore or AltStore on your device.
   - Select `X.ipa` and sign with your personal Apple ID.
2. **TrollStore** (iOS 14.0 – 17.0):
   - Install directly without certificate expiration or sandbox restrictions.
3. **Xcode / Apple Configurator**:
   - Open `X.xcodeproj`.
   - Select your personal development team under *Signing & Capabilities*.
   - Run directly on a connected device in Developer Mode.

---

## 6. Known iOS Version Limitations

- **iOS 18.0 – 26.x**: Managed preference injection via AirTraffic / pairing records is functional when paired.
- **iOS 27.0 – 27.2 beta 2**: On-device RPPairing protocol supported.
- **iOS 27.2 beta 3+**: Apple sealed the ATAirlock sandbox boundary. Standard applications cannot directly overwrite SpringBoard preferences; profiles must be ingested via supervised MDM enrollment or Apple Configurator.

---

## 7. License & Attribution

- Reference architecture and RPPairing protocol research derived from [Mak5er/AirCard-iOS](https://github.com/Mak5er/AirCard-iOS) and [jayohide/aircard-ios](https://github.com/jayohide/aircard-ios). MIT License.
