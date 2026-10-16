import XCTest
@testable import X

final class PlistSerializationTests: XCTestCase {
    
    func testXmlPropertyListRoundtrip() throws {
        let sampleDict: [String: Any] = [
            "SBHideLowPowerAlerts": true,
            "SBAlwaysShowSystemApertureInSnapshots": false,
            "TestNumber": 42,
            "TestString": "com.apple.springboard"
        ]
        
        let document = PlistDocument(dictionary: sampleDict)
        let xmlData = try document.xmlData()
        XCTAssertFalse(xmlData.isEmpty, "Generated XML data must not be empty.")
        
        var format = PropertyListSerialization.PropertyListFormat.xml
        let deserialized = try PropertyListSerialization.propertyList(
            from: xmlData,
            options: [],
            format: &format
        ) as? [String: Any]
        
        XCTAssertNotNil(deserialized, "Deserialized object must be a dictionary.")
        XCTAssertEqual(deserialized?["SBHideLowPowerAlerts"] as? Bool, true)
        XCTAssertEqual(deserialized?["SBAlwaysShowSystemApertureInSnapshots"] as? Bool, false)
        XCTAssertEqual(deserialized?["TestNumber"] as? Int, 42)
        XCTAssertEqual(deserialized?["TestString"] as? String, "com.apple.springboard")
    }
    
    func testBinaryPropertyListRoundtrip() throws {
        let sampleDict: [String: Any] = [
            "SBHideACPower": true,
            "SBNeverBreadcrumb": true
        ]
        
        let document = PlistDocument(dictionary: sampleDict)
        let binaryData = try document.binaryData()
        XCTAssertFalse(binaryData.isEmpty, "Generated binary plist data must not be empty.")
        
        // Check bplist00 magic header
        let header = String(data: binaryData.prefix(8), encoding: .ascii)
        XCTAssertEqual(header, "bplist00", "Binary plist must start with 'bplist00' magic bytes.")
        
        var format = PropertyListSerialization.PropertyListFormat.binary
        let deserialized = try PropertyListSerialization.propertyList(
            from: binaryData,
            options: [],
            format: &format
        ) as? [String: Any]
        
        XCTAssertNotNil(deserialized)
        XCTAssertEqual(deserialized?["SBHideACPower"] as? Bool, true)
        XCTAssertEqual(deserialized?["SBNeverBreadcrumb"] as? Bool, true)
    }
}
