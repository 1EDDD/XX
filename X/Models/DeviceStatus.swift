import Foundation

/// Real device pairing record representation.
/// Must never be fabricated with synthetic tokens or placeholder keys.
public struct PairingRecord: Equatable, Sendable {
    public let hostID: String
    public let hostName: String
    public let hostModel: String
    public let systemBUID: String
    public let wifiMACAddress: String?
    public let hasDeviceCertificate: Bool
    public let hasHostCertificate: Bool
    public let altIRK: String?
    public let fileSource: URL?
    
    public init(
        hostID: String,
        hostName: String,
        hostModel: String,
        systemBUID: String,
        wifiMACAddress: String? = nil,
        hasDeviceCertificate: Bool = false,
        hasHostCertificate: Bool = false,
        altIRK: String? = nil,
        fileSource: URL? = nil
    ) {
        self.hostID = hostID
        self.hostName = hostName
        self.hostModel = hostModel
        self.systemBUID = systemBUID
        self.wifiMACAddress = wifiMACAddress
        self.hasDeviceCertificate = hasDeviceCertificate
        self.hasHostCertificate = hasHostCertificate
        self.altIRK = altIRK
        self.fileSource = fileSource
    }
}

public enum PairingValidationError: LocalizedError, Sendable {
    case emptyData
    case invalidPlistFormat
    case missingSystemBUID
    case missingHostID
    case missingCertificates
    case unreadableFile(String)
    
    public var errorDescription: String? {
        switch self {
        case .emptyData:
            return "The pairing file contains no data."
        case .invalidPlistFormat:
            return "The file is not a valid Apple Property List (XML or binary)."
        case .missingSystemBUID:
            return "Missing mandatory 'SystemBUID' (UDID) in pairing dictionary."
        case .missingHostID:
            return "Missing mandatory 'HostID' in pairing dictionary."
        case .missingCertificates:
            return "Pairing file is missing DeviceCertificate or HostCertificate cryptographic payloads."
        case .unreadableFile(let reason):
            return "Cannot read pairing file: \(reason)"
        }
    }
}

/// Parser and validator for legitimate Apple MobileDevicePairing and AirLift pairing records.
public enum PairingRecordValidator {
    public static func validate(data: Data, sourceURL: URL? = nil) throws -> PairingRecord {
        guard !data.isEmpty else {
            throw PairingValidationError.emptyData
        }
        
        var format = PropertyListSerialization.PropertyListFormat.xml
        guard let plist = try? PropertyListSerialization.propertyList(
            from: data,
            options: [],
            format: &format
        ) as? [String: Any] else {
            throw PairingValidationError.invalidPlistFormat
        }
        
        guard let systemBUID = plist["SystemBUID"] as? String, !systemBUID.isEmpty else {
            throw PairingValidationError.missingSystemBUID
        }
        
        let hostID = (plist["HostID"] as? String) ?? ""
        let hostName = (plist["HostName"] as? String) ?? "Unknown Host"
        let hostModel = (plist["HostModel"] as? String) ?? "Unknown Model"
        let wifiMAC = plist["WiFiMACAddress"] as? String
        let altIRK = plist["XPairingHostAltIRK"] as? String
        
        let hasDevCert = plist["DeviceCertificate"] != nil
        let hasHostCert = plist["HostCertificate"] != nil
        
        return PairingRecord(
            hostID: hostID,
            hostName: hostName,
            hostModel: hostModel,
            systemBUID: systemBUID,
            wifiMACAddress: wifiMAC,
            hasDeviceCertificate: hasDevCert,
            hasHostCertificate: hasHostCert,
            altIRK: altIRK,
            fileSource: sourceURL
        )
    }
}

/// Snapshot of device capability and environment.
public struct DeviceCapabilityReport: Sendable {
    public let systemName: String
    public let systemVersion: String
    public let deviceModel: String
    public let isJailbrokenOrExploited: Bool
    public let hasLocalDevVPN: Bool
    public let supportsOnDevicePairing: Bool
    public let supportedSpringBoardPath: String
    
    public init(
        systemName: String = "iOS",
        systemVersion: String = "18.0",
        deviceModel: String = "iPhone",
        isJailbrokenOrExploited: Bool = false,
        hasLocalDevVPN: Bool = false,
        supportsOnDevicePairing: Bool = false,
        supportedSpringBoardPath: String = "/var/Managed Preferences/mobile/com.apple.springboard.plist"
    ) {
        self.systemName = systemName
        self.systemVersion = systemVersion
        self.deviceModel = deviceModel
        self.isJailbrokenOrExploited = isJailbrokenOrExploited
        self.hasLocalDevVPN = hasLocalDevVPN
        self.supportsOnDevicePairing = supportsOnDevicePairing
        self.supportedSpringBoardPath = supportedSpringBoardPath
    }
}
