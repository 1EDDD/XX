import Foundation

/// Audit classification level as mandated by Project X system rules.
public enum TweakSupportLevel: String, CaseIterable, Sendable {
    case verifiedSupported = "Verified Supported"
    case configurationOnly = "Configuration Only"
    case unverifiedExperimental = "Unverified Experimental"
    case unsupportedObsolete = "Unsupported / Obsolete"
    
    public var badgeColorName: String {
        switch self {
        case .verifiedSupported:
            return "green"
        case .configurationOnly:
            return "blue"
        case .unverifiedExperimental:
            return "orange"
        case .unsupportedObsolete:
            return "red"
        }
    }
}

public struct TweakDefinition: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let key: String
    public let category: String
    public let description: String
    public let supportLevel: TweakSupportLevel
    public let sourceEvidence: String
    public let expectedType: String
    public let defaultValue: Bool
    
    public init(
        id: String,
        title: String,
        key: String,
        category: String,
        description: String,
        supportLevel: TweakSupportLevel,
        sourceEvidence: String,
        expectedType: String = "Boolean",
        defaultValue: Bool = false
    ) {
        self.id = id
        self.title = title
        self.key = key
        self.category = category
        self.description = description
        self.supportLevel = supportLevel
        self.sourceEvidence = sourceEvidence
        self.expectedType = expectedType
        self.defaultValue = defaultValue
    }
}

public enum AuditedSpringBoardTweaks {
    public static let all: [TweakDefinition] = [
        TweakDefinition(
            id: "lowBattery",
            title: "Disable Low Battery Alerts",
            key: "SBHideLowPowerAlerts",
            category: "Alerts",
            description: "Suppresses modal low battery alert dialogues when battery drops below 20% or 10%.",
            supportLevel: .configurationOnly,
            sourceEvidence: "com.apple.springboard preference key present in iOS 14-26 SpringBoard binaries."
        ),
        TweakDefinition(
            id: "acPower",
            title: "Hide AC Power on Lock Screen",
            key: "SBHideACPower",
            category: "Lock Screen",
            description: "Hides the prominent battery percentage and lightning glyph when plugged in on the lock screen.",
            supportLevel: .configurationOnly,
            sourceEvidence: "SpringBoard LockScreenUI preference key; confirmed active in managed environments."
        ),
        TweakDefinition(
            id: "respringLock",
            title: "Disable Lock After Respring",
            key: "SBDontLockAfterCrash",
            category: "System Lifecycle",
            description: "Prevents device from automatically returning to lock state following a SpringBoard crash or soft-restart.",
            supportLevel: .unverifiedExperimental,
            sourceEvidence: "Internal debug flag present in Apple internal engineering builds; behavior varies on retail iOS."
        ),
        TweakDefinition(
            id: "chargingDim",
            title: "Disable Screen Dimming While Charging",
            key: "SBDontDimOrLockOnAC",
            category: "Power Management",
            description: "Inhibits automatic display dimming and screen lock timeout while connected to AC power.",
            supportLevel: .configurationOnly,
            sourceEvidence: "Known Apple kiosk/display unit configuration key for SpringBoard power management."
        ),
        TweakDefinition(
            id: "dynamicIslandSnapshots",
            title: "Dynamic Island in Screenshots",
            key: "SBAlwaysShowSystemApertureInSnapshots",
            category: "Appearance",
            description: "Forces inclusion of the Dynamic Island cutout and active Live Activity pill in captured screenshots.",
            supportLevel: .verifiedSupported,
            sourceEvidence: "Supported Apple System Aperture configuration key for developer screen capture."
        ),
        TweakDefinition(
            id: "authenticationLine",
            title: "Authentication Line",
            key: "SBShowAuthenticationEngineeringUI",
            category: "Engineering UI",
            description: "Renders internal biometric progress line beneath the status bar during Face ID / Touch ID evaluation.",
            supportLevel: .unverifiedExperimental,
            sourceEvidence: "Internal Apple BiometricKit / SpringBoard UI flag; disabled by default on retail kernels."
        ),
        TweakDefinition(
            id: "breadcrumb",
            title: "Disable Breadcrumbs",
            key: "SBNeverBreadcrumb",
            category: "Status Bar",
            description: "Disables the top-left return arrow navigation pill when switching between applications.",
            supportLevel: .configurationOnly,
            sourceEvidence: "Standard SpringBoard preference key; parsed during status bar layout construction."
        ),
        TweakDefinition(
            id: "supervision",
            title: "Show Supervision Text",
            key: "SBShowSupervisionTextOnLockScreen",
            category: "Lock Screen",
            description: "Forces display of enterprise management notification on lock screen regardless of enrollment status.",
            supportLevel: .verifiedSupported,
            sourceEvidence: "Standard Apple MDM managed preference dictionary key recognized by SpringBoard."
        )
    ]
}
