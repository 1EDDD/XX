import XCTest
@testable import X

final class PairingValidationTests: XCTestCase {
    
    func testEmptyDataThrowsError() {
        XCTAssertThrowsError(try PairingRecordValidator.validate(data: Data())) { error in
            guard let validationError = error as? PairingValidationError else {
                return XCTFail("Expected PairingValidationError.emptyData")
            }
            XCTAssertEqual(validationError, .emptyData)
        }
    }
    
    func testInvalidPlistFormatThrowsError() {
        let badData = "Not a property list".data(using: .utf8)!
        XCTAssertThrowsError(try PairingRecordValidator.validate(data: badData)) { error in
            guard let validationError = error as? PairingValidationError else {
                return XCTFail("Expected PairingValidationError.invalidPlistFormat")
            }
            XCTAssertEqual(validationError, .invalidPlistFormat)
        }
    }
    
    func testMissingSystemBUIDThrowsError() throws {
        let dict: [String: Any] = [
            "HostID": "D45F1B9C-4992",
            "HostName": "Mac17,7"
        ]
        let data = try PropertyListSerialization.data(fromPropertyList: dict, format: .xml, options: 0)
        XCTAssertThrowsError(try PairingRecordValidator.validate(data: data)) { error in
            guard let validationError = error as? PairingValidationError else {
                return XCTFail("Expected PairingValidationError.missingSystemBUID")
            }
            XCTAssertEqual(validationError, .missingSystemBUID)
        }
    }
    
    func testValidPairingRecordParsesSuccessfully() throws {
        let validDict: [String: Any] = [
            "SystemBUID": "00008110-001A849201948210",
            "HostID": "MAC-TEST-HOST-01",
            "HostName": "DevMac",
            "HostModel": "Mac17,7",
            "WiFiMACAddress": "38:f9:d3:88:91:c2",
            "XPairingHostAltIRK": "0xABCDEF1234567890",
            "DeviceCertificate": Data([0x01, 0x02, 0x03]),
            "HostCertificate": Data([0x04, 0x05, 0x06])
        ]
        let data = try PropertyListSerialization.data(fromPropertyList: validDict, format: .xml, options: 0)
        let record = try PairingRecordValidator.validate(data: data)
        
        XCTAssertEqual(record.systemBUID, "00008110-001A849201948210")
        XCTAssertEqual(record.hostID, "MAC-TEST-HOST-01")
        XCTAssertEqual(record.hostName, "DevMac")
        XCTAssertEqual(record.hostModel, "Mac17,7")
        XCTAssertEqual(record.wifiMACAddress, "38:f9:d3:88:91:c2")
        XCTAssertEqual(record.altIRK, "0xABCDEF1234567890")
        XCTAssertTrue(record.hasDeviceCertificate)
        XCTAssertTrue(record.hasHostCertificate)
    }
}
