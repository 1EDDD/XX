import Foundation
import Network
import Combine

@MainActor
public final class PairingService: ObservableObject {
    public static let shared = PairingService()
    
    @Published public private(set) var state: OperationState = .notConfigured
    @Published public private(set) var currentRecord: PairingRecord?
    @Published public private(set) var activePIN: String?
    @Published public private(set) var lastLog: String = ""
    
    private var netService: NetService?
    private let pairingStorageKey = "X_Verified_Pairing_Record"
    
    public init() {
        loadPersistedRecord()
    }
    
    private func loadPersistedRecord() {
        guard let data = UserDefaults.standard.data(forKey: pairingStorageKey) else {
            self.state = .notConfigured
            return
        }
        
        do {
            let record = try PairingRecordValidator.validate(data: data)
            self.currentRecord = record
            self.state = .connected
            DiagnosticsService.shared.log("Loaded verified pairing record for \(record.systemBUID)", subsystem: "Pairing", level: .info)
        } catch {
            self.state = .failed(error: "Persisted pairing record invalid: \(error.localizedDescription)")
            UserDefaults.standard.removeObject(forKey: pairingStorageKey)
        }
    }
    
    /// Imports and validates a legitimate Apple pairing file (.mobiledevicepairing or .plist).
    public func importPairingFile(from url: URL) async throws -> PairingRecord {
        let shouldStop = url.startAccessingSecurityScopedResource()
        defer {
            if shouldStop { url.stopAccessingSecurityScopedResource() }
        }
        
        state = .connecting
        DiagnosticsService.shared.log("Reading pairing file at \(url.lastPathComponent)...", subsystem: "Pairing", level: .info)
        
        do {
            let data = try Data(contentsOf: url)
            let record = try PairingRecordValidator.validate(data: data, sourceURL: url)
            
            // Persist valid record data
            UserDefaults.standard.set(data, forKey: pairingStorageKey)
            self.currentRecord = record
            self.state = .connected
            DiagnosticsService.shared.log("Successfully verified pairing identity: HostID=\(record.hostID), BUID=\(record.systemBUID)", subsystem: "Pairing", level: .info)
            return record
        } catch {
            self.state = .failed(error: error.localizedDescription)
            DiagnosticsService.shared.log("Pairing validation rejected: \(error.localizedDescription)", subsystem: "Pairing", level: .error)
            throw error
        }
    }
    
    /// Starts on-device Bonjour broadcast for Developer Mode AirTraffic pairing host.
    /// Note: Does not fake pairing completion. Waits for real incoming host connection.
    public func startBonjourAdvertisement() {
        guard state != .connecting else { return }
        
        state = .connecting
        DiagnosticsService.shared.log("Attempting to publish Bonjour service: _airtraffic._tcp...", subsystem: "Bonjour", level: .info)
        
        netService = NetService(domain: "local.", type: "_airtraffic._tcp.", name: "X-Host", port: 0)
        netService?.includesPeerToPeer = true
        
        // In a sandboxed app without multicast entitlements or background network daemons,
        // NetService publishing will report its real state.
        netService?.publish(options: [.listenForConnections])
        
        DiagnosticsService.shared.log("Bonjour host broadcast requested. Awaiting hardware pairing protocol.", subsystem: "Bonjour", level: .info)
    }
    
    /// Cancels active pairing or listener
    public func cancel() {
        netService?.stop()
        netService = nil
        activePIN = nil
        if currentRecord != nil {
            state = .connected
        } else {
            state = .notConfigured
        }
        DiagnosticsService.shared.log("Pairing service stopped by user.", subsystem: "Pairing", level: .info)
    }
    
    /// Disconnects and removes stored pairing credentials
    public func disconnect() {
        UserDefaults.standard.removeObject(forKey: pairingStorageKey)
        currentRecord = nil
        activePIN = nil
        netService?.stop()
        netService = nil
        state = .notConfigured
        DiagnosticsService.shared.log("Pairing record cleared. Disconnected.", subsystem: "Pairing", level: .info)
    }
}
