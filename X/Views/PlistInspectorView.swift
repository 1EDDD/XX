import SwiftUI
import UniformTypeIdentifiers

public struct PlistInspectorView: View {
    @ObservedObject private var plistService = PlistService.shared
    @State private var showingExporter: Bool = false
    @State private var showingImporter: Bool = false
    @State private var exportDocument: PlistDocument?
    @State private var importErrorMessage: String?
    @State private var showingErrorAlert: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header stats
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Target Path")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("/var/Managed Preferences/mobile/com.apple.springboard.plist")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.white)
                }
                Spacer()
                
                let count = plistService.currentDocument.dictionary.count
                Text("\(count) keys")
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Capsule())
            }
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
            
            // XML Document Editor / Viewer
            ScrollView {
                Text(plistService.lastSerializedXml)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .textSelection(.enabled)
            }
            .background(Color(uiColor: .systemBackground))
            
            Divider()
            
            // Toolbar actions
            HStack(spacing: 12) {
                Button {
                    showingImporter = true
                } label: {
                    Label("Import…", systemImage: "square.and.arrow.down")
                        .font(.caption.bold())
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                ShareLink(
                    item: plistService.lastSerializedXml,
                    subject: Text("com.apple.springboard.plist"),
                    message: Text("Exported SpringBoard managed preferences property list from Project X.")
                ) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.caption.bold())
                }
                .buttonStyle(.bordered)
                
                Button {
                    exportDocument = plistService.currentDocument
                    showingExporter = true
                } label: {
                    Label("Save File…", systemImage: "folder.badge.plus")
                        .font(.caption.bold())
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
        }
        .navigationTitle("Plist Inspector")
        .fileExporter(
            isPresented: $showingExporter,
            document: exportDocument,
            contentType: .propertyList,
            defaultFilename: "com.apple.springboard.plist"
        ) { result in
            switch result {
            case .success(let url):
                DiagnosticsService.shared.log("User saved plist file to \(url.lastPathComponent)", subsystem: "Plist", level: .info)
            case .failure(let error):
                DiagnosticsService.shared.log("File export cancelled or failed: \(error.localizedDescription)", subsystem: "Plist", level: .warning)
            }
        }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.propertyList],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                do {
                    _ = try plistService.importPlist(from: url)
                    DiagnosticsService.shared.log("Imported plist from \(url.lastPathComponent)", subsystem: "Plist", level: .info)
                } catch {
                    self.importErrorMessage = error.localizedDescription
                    self.showingErrorAlert = true
                }
            case .failure(let error):
                self.importErrorMessage = error.localizedDescription
                self.showingErrorAlert = true
            }
        }
        .alert("Import Error", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(importErrorMessage ?? "Failed to read property list.")
        }
    }
}
