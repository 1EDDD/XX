import SwiftUI

public struct SettingsView: View {
    @ObservedObject private var deviceService = DeviceStatusService.shared
    @State private var showingResetConfirmation: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            List {
                Section("System Information") {
                    LabeledContent("Application", value: "Project X")
                    LabeledContent("Version", value: "0.1.0 (Build 1)")
                    LabeledContent("Language & Runtime", value: "Swift 6 / SwiftUI")
                    LabeledContent("Target OS", value: "iOS 18.0 - 27.x")
                    LabeledContent("Device Platform", value: "\(deviceService.report.deviceModel) (iOS \(deviceService.report.systemVersion))")
                }
                
                Section("Sandbox & Security Architecture") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("iOS Integrity Enforcement")
                            .font(.subheadline.bold())
                        Text("Retail iOS devices enforce strict container isolation. Writing directly to '/var/Managed Preferences/' is restricted to root, privileged daemons, or authorized MDM profiles.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("AirTraffic / AirCard Integration")
                            .font(.subheadline.bold())
                        Text("Compatible with AirCard-iOS pairing records. Uses mutual TLS-PSK pairing on port 58783. Compatible with iOS 18 through iOS 27.2 beta 2. iOS 27.2 beta 3+ enforces sealed sandbox restrictions.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Attribution & References") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AirCard-iOS")
                            .font(.subheadline.bold())
                        Text("Reference architecture by Mak5er and jayohide. MIT License.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)
                }
                
                Section {
                    Button(role: .destructive) {
                        showingResetConfirmation = true
                    } label: {
                        Label("Reset Staged Tweaks to Default", systemImage: "arrow.counterclockwise")
                    }
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog("Reset all staged tweak preferences to default?", isPresented: $showingResetConfirmation, titleVisibility: .visible) {
                Button("Reset Defaults", role: .destructive) {
                    UserDefaults.standard.removeObject(forKey: "X_Staged_SpringBoard_Values")
                    CustomizationService.shared.validateConfiguration()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}
