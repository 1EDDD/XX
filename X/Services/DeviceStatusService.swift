import Foundation
import UIKit
import Combine

@MainActor
public final class DeviceStatusService: ObservableObject {
    public static let shared = DeviceStatusService()
    
    @Published public private(set) var report: DeviceCapabilityReport
    @Published public private(set) var targetPathStatus: String = "Checking..."
    @Published public private(set) var isPrivilegedWritePossible: Bool = false
    
    public init() {
        let currentDevice = UIDevice.current
        let systemVersion = currentDevice.systemVersion
        let model = currentDevice.model
        
        // Target path where SpringBoard Managed Preferences are ingested by iOS
        let targetPath = "/var/Managed Preferences/mobile/com.apple.springboard.plist"
        
        let writePossible = FileManager.default.isWritableFile(atPath: "/var/Managed Preferences/mobile/")
        
        self.report = DeviceCapabilityReport(
            systemName: currentDevice.systemName,
            systemVersion: systemVersion,
            deviceModel: model,
            isJailbrokenOrExploited: false,
            hasLocalDevVPN: false,
            supportsOnDevicePairing: true,
            supportedSpringBoardPath: targetPath
        )
        self.isPrivilegedWritePossible = writePossible
        self.targetPathStatus = writePossible ? "Writable" : "Sandboxed (Protected by iOS System Integrity)"
    }
    
    public func refresh() {
        let writePossible = FileManager.default.isWritableFile(atPath: "/var/Managed Preferences/mobile/")
        self.isPrivilegedWritePossible = writePossible
        self.targetPathStatus = writePossible ? "Writable" : "Sandboxed (Protected by iOS System Integrity)"
        
        DiagnosticsService.shared.log(
            "Device environment refreshed: iOS \(UIDevice.current.systemVersion), Sandbox Write: \(writePossible ? "Granted" : "Restricted")",
            subsystem: "Device",
            level: .info
        )
    }
}
