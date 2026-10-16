import Foundation

public enum NativeBridgeError: LocalizedError, Sendable {
    case libraryNotFound(String)
    case symbolNotFound(String)
    case unsupportedArchitecture(String)
    case tunnelUnavailable(String)
    case connectionRefused(Int32)
    case unverifiedPrivileges(String)
    
    public var errorDescription: String? {
        switch self {
        case .libraryNotFound(let name):
            return "Native framework or dylib '\(name)' not bundled or found in dynamic loader paths."
        case .symbolNotFound(let symbol):
            return "Required C ABI symbol '\(symbol)' not found in loaded binary."
        case .unsupportedArchitecture(let arch):
            return "Target architecture '\(arch)' is not supported by native library."
        case .tunnelUnavailable(let reason):
            return "LocalDevVPN loopback tunnel is unavailable: \(reason)"
        case .connectionRefused(let port):
            return "Connection refused on port \(port). AirTraffic daemon is not responding."
        case .unverifiedPrivileges(let reason):
            return "Operation blocked: \(reason)"
        }
    }
}
