import SwiftUI

public struct DevicePairingView: View {
    @ObservedObject private var pairingService = PairingService.shared
    @State private var isImporting: Bool = false
    @State private var errorMessage: String?
    @State private var showingErrorAlert: Bool = false
    
    public init() {}
    
    public var body: some View {
        List {
            Section("Current Pairing State") {
                HStack {
                    Text("Status")
                    Spacer()
                    Text(pairingService.state.statusDescription)
                        .foregroundStyle(pairingService.currentRecord != nil ? .green : .secondary)
                }
                
                if let record = pairingService.currentRecord {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Device UDID")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(record.systemBUID)
                            .font(.system(.caption, design: .monospaced))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Host Identifier")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(record.hostID)
                            .font(.system(.caption, design: .monospaced))
                    }
                    
                    HStack {
                        Text("Host Name")
                        Spacer()
                        Text(record.hostName)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Host Model")
                        Spacer()
                        Text(record.hostModel)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Certificates Verified")
                        Spacer()
                        Image(systemName: record.hasDeviceCertificate && record.hasHostCertificate ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                            .foregroundStyle(record.hasDeviceCertificate && record.hasHostCertificate ? .green : .orange)
                    }
                }
            }
            
            Section("Import Pairing Record") {
                Text("Select an existing .mobiledevicepairing or .plist file created by SideStore, LiveContainer, or Xcode pairing.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Button {
                    isImporting = true
                } label: {
                    Label("Import Pairing File…", systemImage: "square.and.arrow.down")
                }
            }
            
            Section("On-Device Bonjour Pairing Host") {
                Text("Broadcasts _airtraffic._tcp on local network. Requires an external client to initiate the pairing handshake.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if pairingService.state == .connecting {
                    Button(role: .destructive) {
                        pairingService.cancel()
                    } label: {
                        Label("Stop Broadcast", systemImage: "stop.circle")
                    }
                } else {
                    Button {
                        pairingService.startBonjourAdvertisement()
                    } label: {
                        Label("Start Broadcast", systemImage: "antenna.radiowaves.left.and.right")
                    }
                }
            }
            
            if pairingService.currentRecord != nil {
                Section {
                    Button(role: .destructive) {
                        pairingService.disconnect()
                    } label: {
                        Label("Remove Stored Pairing", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle("Device Pairing")
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.propertyList, .data],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let selectedURL = urls.first else { return }
                Task {
                    do {
                        _ = try await pairingService.importPairingFile(from: selectedURL)
                    } catch {
                        self.errorMessage = error.localizedDescription
                        self.showingErrorAlert = true
                    }
                }
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.showingErrorAlert = true
            }
        }
        .alert("Pairing Error", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "Unknown error importing pairing file.")
        }
    }
}
