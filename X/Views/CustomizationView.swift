import SwiftUI

public struct CustomizationView: View {
    @ObservedObject private var service = CustomizationService.shared
    @State private var selectedTweakForDetail: TweakDefinition?
    @State private var showingExportSuccess: Bool = false
    @State private var exportedURL: URL?
    
    public init() {}
    
    public var body: some View {
        List {
            Section("Deployment Status") {
                HStack {
                    Text("Phase")
                    Spacer()
                    Text(service.deploymentStatus.label)
                        .font(.caption.bold())
                        .foregroundStyle(.green)
                }
                
                if !service.lastOperationMessage.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Backend Response")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(service.lastOperationMessage)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .padding(.vertical, 2)
                }
            }
            
            ForEach(categorizedTweaks.keys.sorted(), id: \.self) { category in
                Section(category) {
                    ForEach(categorizedTweaks[category] ?? []) { tweak in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack {
                                        Text(tweak.title)
                                            .font(.body)
                                            .foregroundStyle(.white)
                                        
                                        Button {
                                            selectedTweakForDetail = tweak
                                        } label: {
                                            Image(systemName: "info.circle")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    
                                    Text(tweak.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: Binding(
                                    get: { service.isEnabled(tweak) },
                                    set: { service.setTweak(tweak, enabled: $0) }
                                ))
                                .labelsHidden()
                            }
                            
                            HStack {
                                Text(tweak.supportLevel.rawValue)
                                    .font(.system(size: 10, weight: .bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(supportBadgeColor(tweak.supportLevel).opacity(0.2))
                                    .foregroundStyle(supportBadgeColor(tweak.supportLevel))
                                    .clipShape(Capsule())
                                
                                Spacer()
                                
                                Text(tweak.key)
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            
            Section("Actions") {
                Button {
                    _ = service.validateConfiguration()
                } label: {
                    Label("Validate Configuration", systemImage: "checkmark.seal")
                }
                
                Button {
                    Task {
                        do {
                            let url = try await service.exportPayload()
                            self.exportedURL = url
                            self.showingExportSuccess = true
                        } catch {
                            // Handled in service.lastOperationMessage
                        }
                    }
                } label: {
                    Label("Export .plist Document", systemImage: "square.and.arrow.up")
                }
                .disabled(service.isProcessing)
                
                Button {
                    Task {
                        await service.applyPreparedChangesToSystem()
                    }
                } label: {
                    HStack {
                        Label("Apply Prepared Changes", systemImage: "bolt.badge.automatic")
                        Spacer()
                        if service.isProcessing {
                            ProgressView()
                        }
                    }
                }
                .disabled(service.isProcessing)
                
                Button {
                    Task {
                        await service.requestRespring()
                    }
                } label: {
                    Label("Respring Device", systemImage: "arrow.clockwise")
                }
                .disabled(service.isProcessing)
            }
        }
        .navigationTitle("Customization")
        .sheet(item: $selectedTweakForDetail) { tweak in
            TweakDetailSheet(tweak: tweak)
        }
        .alert("Payload Exported", isPresented: $showingExportSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("com.apple.springboard.plist exported to:\n\(exportedURL?.lastPathComponent ?? "Documents")")
        }
    }
    
    private var categorizedTweaks: [String: [TweakDefinition]] {
        Dictionary(grouping: AuditedSpringBoardTweaks.all, by: { $0.category })
    }
    
    private func supportBadgeColor(_ level: TweakSupportLevel) -> Color {
        switch level {
        case .verifiedSupported:
            return .green
        case .configurationOnly:
            return .blue
        case .unverifiedExperimental:
            return .orange
        case .unsupportedObsolete:
            return .red
        }
    }
}

struct TweakDetailSheet: View {
    let tweak: TweakDefinition
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("Tweak Identity") {
                    LabeledContent("Key", value: tweak.key)
                    LabeledContent("Category", value: tweak.category)
                    LabeledContent("Type", value: tweak.expectedType)
                    LabeledContent("Classification", value: tweak.supportLevel.rawValue)
                }
                
                Section("Description") {
                    Text(tweak.description)
                        .font(.body)
                }
                
                Section("Source Evidence & Compatibility") {
                    Text(tweak.sourceEvidence)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(tweak.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
