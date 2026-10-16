import Foundation
import Combine

@MainActor
public final class PlistService: ObservableObject {
    public static let shared = PlistService()
    
    @Published public private(set) var currentDocument: PlistDocument = PlistDocument()
    @Published public private(set) var lastSerializedXml: String = ""
    @Published public private(set) var lastErrorMessage: String?
    
    private let preferencesFileName = "com.apple.springboard.plist"
    
    public init() {
        refreshPayload(values: [:])
    }
    
    /// Refreshes the active Property List Document from staged tweak values.
    public func refreshPayload(values: [String: Bool]) {
        var dict: [String: Any] = [:]
        for (key, val) in values {
            dict[key] = val
        }
        
        let doc = PlistDocument(dictionary: dict)
        self.currentDocument = doc
        self.lastSerializedXml = doc.xmlString()
        self.lastErrorMessage = nil
    }
    
    /// Creates a verified binary property list representation.
    public func createBinaryPayload() throws -> Data {
        do {
            return try currentDocument.binaryData()
        } catch {
            self.lastErrorMessage = "Binary plist serialization failed: \(error.localizedDescription)"
            throw error
        }
    }
    
    /// Creates a verified XML property list representation.
    public func createXmlPayload() throws -> Data {
        do {
            return try currentDocument.xmlData()
        } catch {
            self.lastErrorMessage = "XML plist serialization failed: \(error.localizedDescription)"
            throw error
        }
    }
    
    /// Imports a user-selected property list file and validates its contents.
    public func importPlist(from url: URL) throws -> [String: Any] {
        let shouldStopAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if shouldStopAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        let data = try Data(contentsOf: url)
        var format = PropertyListSerialization.PropertyListFormat.xml
        let plistObj = try PropertyListSerialization.propertyList(
            from: data,
            options: [],
            format: &format
        )
        
        guard let dict = plistObj as? [String: Any] else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        self.currentDocument = PlistDocument(dictionary: dict)
        self.lastSerializedXml = self.currentDocument.xmlString()
        return dict
    }
    
    /// Exports the current document to the application's Documents directory.
    public func exportToDocuments() throws -> URL {
        guard let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw CocoaError(.fileWriteNoPermission)
        }
        
        let targetURL = docs.appendingPathComponent(preferencesFileName)
        let data = try createXmlPayload()
        try data.write(to: targetURL, options: .atomic)
        DiagnosticsService.shared.log("Exported valid XML plist to \(targetURL.path)", subsystem: "Plist", level: .info)
        return targetURL
    }
}
