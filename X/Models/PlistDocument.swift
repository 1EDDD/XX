import Foundation
import SwiftUI
import UniformTypeIdentifiers

/// Native document model for reading, writing, importing, and exporting genuine Apple Property Lists.
public struct PlistDocument: FileDocument, Sendable {
    public static var readableContentTypes: [UTType] {
        [.propertyList, .xmlPropertyList]
    }
    
    public var dictionary: [String: Any]
    
    public init(dictionary: [String: Any] = [:]) {
        self.dictionary = dictionary
    }
    
    public init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        var format = PropertyListSerialization.PropertyListFormat.xml
        let plist = try PropertyListSerialization.propertyList(
            from: data,
            options: [],
            format: &format
        )
        
        guard let dict = plist as? [String: Any] else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        self.dictionary = dict
    }
    
    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try PropertyListSerialization.data(
            fromPropertyList: dictionary,
            format: .xml,
            options: 0
        )
        return FileWrapper(regularFileWithContents: data)
    }
    
    /// Generates verified XML Property List Data using official Foundation serialization.
    public func xmlData() throws -> Data {
        try PropertyListSerialization.data(
            fromPropertyList: dictionary,
            format: .xml,
            options: 0
        )
    }
    
    /// Generates verified Binary Property List (bplist00) Data using official Foundation serialization.
    public func binaryData() throws -> Data {
        try PropertyListSerialization.data(
            fromPropertyList: dictionary,
            format: .binary,
            options: 0
        )
    }
    
    /// Human readable XML string representation.
    public func xmlString() -> String {
        guard let data = try? xmlData(),
              let string = String(data: data, encoding: .utf8) else {
            return "<!-- Unable to serialize property list to XML -->"
        }
        return string
    }
}
