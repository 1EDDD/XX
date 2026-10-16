import Foundation
import Combine

@MainActor
public final class AppEnvironment: ObservableObject {
    public static let shared = AppEnvironment()
    
    public let deviceStatus = DeviceStatusService.shared
    public let pairing = PairingService.shared
    public let customization = CustomizationService.shared
    public let plist = PlistService.shared
    public let diagnostics = DiagnosticsService.shared
    
    public init() {
        diagnostics.log("AppEnvironment configured for Swift 6 runtime.", subsystem: "App", level: .info)
        deviceStatus.refresh()
    }
}
