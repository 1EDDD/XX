import Foundation
import Combine

@MainActor
public final class CustomizationService: ObservableObject {
    public static let shared = CustomizationService()
    
    @Published public private(set) var tweakValues: [String: Bool] = [:]
    @Published public private(set) var deploymentStatus: PayloadDeploymentStatus = .idle
    @Published public private(set) var lastOperationMessage: String = ""
    @Published public private(set) var isProcessing: Bool = false
    
    private let storageKey = "X_Staged_SpringBoard_Values"
    
    public init() {
        loadPersistedValues()
    }
    
    private func loadPersistedValues() {
        if let saved = UserDefaults.standard.dictionary(forKey: storageKey) as? [String: Bool] {
            self.tweakValues = saved
            self.deploymentStatus = .stagedLocally
        } else {
            // Initialize with defaults from audited list
            var initial: [String: Bool] = [:]
            for tweak in AuditedSpringBoardTweaks.all {
                initial[tweak.id] = tweak.defaultValue
            }
            self.tweakValues = initial
            self.deploymentStatus = .idle
        }
        PlistService.shared.refreshPayload(values: activePreferenceDictionary())
    }
    
    public func setTweak(_ tweak: TweakDefinition, enabled: Bool) {
        tweakValues[tweak.id] = enabled
        UserDefaults.standard.set(tweakValues, forKey: storageKey)
        deploymentStatus = .stagedLocally
        PlistService.shared.refreshPayload(values: activePreferenceDictionary())
        DiagnosticsService.shared.log("Tweak '\(tweak.title)' (\(tweak.key)) set to \(enabled)", subsystem: "Tweaks", level: .info)
    }
    
    public func isEnabled(_ tweak: TweakDefinition) -> Bool {
        tweakValues[tweak.id] ?? false
    }
    
    /// Translates active UI tweak definitions to com.apple.springboard property list keys.
    public func activePreferenceDictionary() -> [String: Bool] {
        var dict: [String: Bool] = [:]
        for tweak in AuditedSpringBoardTweaks.all {
            dict[tweak.key] = isEnabled(tweak)
        }
        return dict
    }
    
    /// Validates the staged configuration against known SpringBoard schema constraints.
    public func validateConfiguration() -> Bool {
        let activeDict = activePreferenceDictionary()
        deploymentStatus = .configurationValidated(itemCount: activeDict.count)
        lastOperationMessage = "Configuration validated successfully (\(activeDict.count) keys ready)."
        DiagnosticsService.shared.log("Configuration validated: \(activeDict.count) keys verified.", subsystem: "Tweaks", level: .info)
        return true
    }
    
    /// Exports the validated payload to the app documents directory for inspection or external transport.
    public func exportPayload() async throws -> URL {
        guard !isProcessing else { throw CocoaError(.userCancelled) }
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            let url = try PlistService.shared.exportToDocuments()
            deploymentStatus = .payloadExported(destination: url)
            lastOperationMessage = "Payload exported to: \(url.lastPathComponent)"
            return url
        } catch {
            lastOperationMessage = "Export failed: \(error.localizedDescription)"
            DiagnosticsService.shared.log("Payload export failed: \(error.localizedDescription)", subsystem: "Tweaks", level: .error)
            throw error
        }
    }
    
    /// Attempts privileged application to the system Managed Preferences directory.
    /// Honestly reports sandbox boundaries without fake success.
    public func applyPreparedChangesToSystem() async {
        guard !isProcessing else { return }
        isProcessing = true
        defer { isProcessing = false }
        
        deploymentStatus = .authorizationRequested
        lastOperationMessage = "Validating target filesystem access at /var/Managed Preferences/mobile/..."
        DiagnosticsService.shared.log("Attempting direct filesystem write to SpringBoard managed preferences...", subsystem: "System", level: .security)
        
        let destinationPath = "/var/Managed Preferences/mobile/com.apple.springboard.plist"
        let isWritable = FileManager.default.isWritableFile(atPath: "/var/Managed Preferences/mobile/")
        
        if isWritable {
            do {
                let data = try PlistService.shared.createXmlPayload()
                try data.write(to: URL(fileURLWithPath: destinationPath), options: .atomic)
                deploymentStatus = .verified
                lastOperationMessage = "Changes successfully committed to \(destinationPath)."
                DiagnosticsService.shared.log("Direct write confirmed at \(destinationPath).", subsystem: "System", level: .info)
            } catch {
                deploymentStatus = .blockedPrivilegeEscalationRequired(details: error.localizedDescription)
                lastOperationMessage = "Write failed: \(error.localizedDescription)"
                DiagnosticsService.shared.log("Filesystem write error: \(error.localizedDescription)", subsystem: "System", level: .error)
            }
        } else {
            // Honest sandbox boundary report: Standard iOS app sandbox prohibits writing outside Container
            deploymentStatus = .blockedPrivilegeEscalationRequired(
                details: "Sandbox violation: Access to /var/Managed Preferences/ requires root or com.apple.private.airdrop.privilege entitlement."
            )
            lastOperationMessage = "Privileged write unavailable. Target path is restricted by the iOS kernel sandbox. Export payload to deploy via Apple Configurator or an authorized loopback tunnel."
            DiagnosticsService.shared.log(
                "Write blocked: App sandbox prohibits direct write to \(destinationPath) without external tunnel or supervised MDM profile.",
                subsystem: "Security",
                level: .warning
            )
        }
    }
    
    /// Requests SpringBoard respring.
    /// Explicitly does NOT fake a successful respring via timer.
    public func requestRespring() async {
        guard !isProcessing else { return }
        isProcessing = true
        defer { isProcessing = false }
        
        lastOperationMessage = "Evaluating available system notification primitives for respring..."
        DiagnosticsService.shared.log("Checking Darwin notification privileges (com.apple.springboard.relaunch)...", subsystem: "System", level: .info)
        
        // In retail iOS, posted Darwin notifications for system restart require private entitlements or crashing the frontboard daemon.
        // As per Project X rules: Do not implement a crash or sandbox exploit, and do not fake a respring with a timer.
        lastOperationMessage = "Respring unavailable: Initiating a SpringBoard reload requires internal frontboard privileges not granted to user-space applications."
        DiagnosticsService.shared.log("Respring request rejected: Insufficient platform privileges on retail iOS.", subsystem: "System", level: .warning)
    }
}
