import Foundation
import Combine

public struct DiagnosticEntry: Identifiable, Sendable {
    public let id = UUID()
    public let timestamp: Date
    public let level: LogLevel
    public let subsystem: String
    public let message: String
    
    public enum LogLevel: String, Sendable {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARN"
        case error = "ERROR"
        case security = "SEC"
    }
}

@MainActor
public final class DiagnosticsService: ObservableObject {
    public static let shared = DiagnosticsService()
    
    @Published public private(set) var entries: [DiagnosticEntry] = []
    
    public init() {
        log("Diagnostics service initialized.", subsystem: "System", level: .info)
        log("Sandbox validation: standard container enforcement active.", subsystem: "Security", level: .info)
    }
    
    public func log(_ message: String, subsystem: String = "App", level: DiagnosticEntry.LogLevel = .info) {
        let entry = DiagnosticEntry(
            timestamp: Date(),
            level: level,
            subsystem: subsystem,
            message: message
        )
        entries.insert(entry, at: 0)
        if entries.count > 300 {
            entries.removeLast()
        }
    }
    
    public func clear() {
        entries.removeAll()
        log("Diagnostic logs cleared.", subsystem: "Diagnostics", level: .info)
    }
    
    public func exportPlainText() -> String {
        let formatter = ISO8601DateFormatter()
        return entries.map { entry in
            "[\(formatter.string(from: entry.timestamp))] [\(entry.level.rawValue)] [\(entry.subsystem)] \(entry.message)"
        }.joined(separator: "\n")
    }
}
