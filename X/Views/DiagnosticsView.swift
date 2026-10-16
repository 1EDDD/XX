import SwiftUI

public struct DiagnosticsView: View {
    @ObservedObject private var diagnosticsService = DiagnosticsService.shared
    @State private var filterLevel: DiagnosticEntry.LogLevel? = nil
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Filter bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filterButton(title: "All", level: nil)
                    filterButton(title: "Errors", level: .error)
                    filterButton(title: "Warnings", level: .warning)
                    filterButton(title: "Security", level: .security)
                    filterButton(title: "Info", level: .info)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(Color(uiColor: .secondarySystemBackground))
            
            Divider()
            
            // Log entries list
            List {
                ForEach(filteredEntries) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(entry.level.rawValue)
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(badgeColor(for: entry.level).opacity(0.2))
                                .foregroundStyle(badgeColor(for: entry.level))
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                            
                            Text(entry.subsystem)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            Text(entry.timestamp.formatted(date: .omitted, time: .standard))
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                        
                        Text(entry.message)
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(.white)
                            .textSelection(.enabled)
                    }
                    .padding(.vertical, 2)
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Diagnostics")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ShareLink(
                        item: diagnosticsService.exportPlainText(),
                        subject: Text("Project X Diagnostics"),
                        message: Text("Diagnostic logs exported from Project X.")
                    ) {
                        Label("Export Logs", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(role: .destructive) {
                        diagnosticsService.clear()
                    } label: {
                        Label("Clear Logs", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
    
    private var filteredEntries: [DiagnosticEntry] {
        if let filter = filterLevel {
            return diagnosticsService.entries.filter { $0.level == filter }
        }
        return diagnosticsService.entries
    }
    
    @ViewBuilder
    private func filterButton(title: String, level: DiagnosticEntry.LogLevel?) -> some View {
        Button {
            filterLevel = level
        } label: {
            Text(title)
                .font(.caption2.bold())
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(filterLevel == level ? Color.white : Color.white.opacity(0.1))
                .foregroundStyle(filterLevel == level ? Color.black : Color.white)
                .clipShape(Capsule())
        }
    }
    
    private func badgeColor(for level: DiagnosticEntry.LogLevel) -> Color {
        switch level {
        case .debug:
            return .secondary
        case .info:
            return .blue
        case .warning:
            return .orange
        case .error:
            return .red
        case .security:
            return .purple
        }
    }
}
