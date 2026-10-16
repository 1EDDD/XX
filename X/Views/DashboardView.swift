import SwiftUI

public struct DashboardView: View {
    @ObservedObject private var deviceService = DeviceStatusService.shared
    @ObservedObject private var pairingService = PairingService.shared
    @ObservedObject private var customizationService = CustomizationService.shared
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // System Overview Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "iphone.gen3")
                                .font(.title2)
                                .foregroundStyle(.white)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(deviceService.report.deviceModel)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Text("iOS \(deviceService.report.systemVersion)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(deviceService.isPrivilegedWritePossible ? "Writable" : "Sandboxed")
                                .font(.caption2.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(deviceService.isPrivilegedWritePossible ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
                                .foregroundStyle(deviceService.isPrivilegedWritePossible ? .green : .blue)
                                .clipShape(Capsule())
                        }
                        
                        Divider().background(Color.white.opacity(0.1))
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Target Preferences Path")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(deviceService.report.supportedSpringBoardPath)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.8))
                                .textSelection(.enabled)
                        }
                    }
                    .padding(16)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Pairing Status Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "link")
                                .font(.title3)
                                .foregroundStyle(pairingService.currentRecord != nil ? .green : .secondary)
                            Text("Device Pairing Status")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Spacer()
                            Text(pairingService.state.statusDescription)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        if let record = pairingService.currentRecord {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("UDID:")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                    Text(record.systemBUID)
                                        .font(.system(.caption2, design: .monospaced))
                                        .foregroundStyle(.white)
                                        .lineLimit(1)
                                }
                                HStack {
                                    Text("Host:")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                    Text("\(record.hostName) (\(record.hostModel))")
                                        .font(.caption2)
                                        .foregroundStyle(.white)
                                }
                            }
                        } else {
                            Text("No pairing record imported. On-device managed preferences modification requires pairing credentials or supervised MDM.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        NavigationLink(destination: DevicePairingView()) {
                            Text(pairingService.currentRecord == nil ? "Configure Pairing" : "Manage Pairing Record")
                                .font(.caption.bold())
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.1))
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(16)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Quick Stats & Deployment Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                                .font(.title3)
                                .foregroundStyle(.white)
                            Text("Staged SpringBoard Tweaks")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Spacer()
                            Text(customizationService.deploymentStatus.label)
                                .font(.caption2)
                                .foregroundStyle(.green)
                        }
                        
                        let enabledCount = customizationService.tweakValues.values.filter { $0 }.count
                        Text("\(enabledCount) tweaks currently enabled in staged payload.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 12) {
                            NavigationLink(destination: CustomizationView()) {
                                Text("Edit Tweaks")
                                    .font(.caption.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.white)
                                    .foregroundStyle(.black)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            
                            NavigationLink(destination: PlistInspectorView()) {
                                Text("View .plist")
                                    .font(.caption.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.white.opacity(0.1))
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(16)
            }
            .navigationTitle("Project X")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: DiagnosticsView()) {
                        Image(systemName: "waveform.path.ecg")
                    }
                }
            }
        }
    }
}
