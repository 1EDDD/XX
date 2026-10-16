import Foundation

/// Represents the explicit, honest state of any backend or device operation.
/// As per Project X system rules, no operation may be simulated or falsely marked as completed.
public enum OperationState: Equatable, Sendable {
    case notConfigured
    case ready
    case connecting
    case connected
    case unsupported(reason: String)
    case failed(error: String)
    case completed(summary: String)
    
    public var isTerminal: Bool {
        switch self {
        case .completed, .failed, .unsupported:
            return true
        default:
            return false
        }
    }
    
    public var statusDescription: String {
        switch self {
        case .notConfigured:
            return "Not Configured"
        case .ready:
            return "Ready"
        case .connecting:
            return "Connecting…"
        case .connected:
            return "Connected"
        case .unsupported(let reason):
            return "Unsupported: \(reason)"
        case .failed(let error):
            return "Failed: \(error)"
        case .completed(let summary):
            return summary
        }
    }
}

/// Represents the granular verification status of an applied configuration payload.
public enum PayloadDeploymentStatus: Equatable, Sendable {
    case idle
    case stagedLocally
    case configurationValidated(itemCount: Int)
    case payloadExported(destination: URL)
    case authorizationRequested
    case operationAcknowledged
    case verified
    case blockedPrivilegeEscalationRequired(details: String)
    
    public var label: String {
        switch self {
        case .idle:
            return "Idle"
        case .stagedLocally:
            return "Staged Locally (In-Memory)"
        case .configurationValidated(let count):
            return "Validated (\(count) keys)"
        case .payloadExported(let url):
            return "Exported to \(url.lastPathComponent)"
        case .authorizationRequested:
            return "Awaiting Authorization"
        case .operationAcknowledged:
            return "Operation Acknowledged"
        case .verified:
            return "Independently Verified"
        case .blockedPrivilegeEscalationRequired(let details):
            return "Privileged Write Blocked: \(details)"
        }
    }
}
