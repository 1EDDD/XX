import XCTest
@testable import X

final class DeviceStateTests: XCTestCase {
    
    func testOperationStateTransitions() {
        let unconfig = OperationState.notConfigured
        XCTAssertFalse(unconfig.isTerminal)
        XCTAssertEqual(unconfig.statusDescription, "Not Configured")
        
        let ready = OperationState.ready
        XCTAssertFalse(ready.isTerminal)
        XCTAssertEqual(ready.statusDescription, "Ready")
        
        let connecting = OperationState.connecting
        XCTAssertFalse(connecting.isTerminal)
        
        let connected = OperationState.connected
        XCTAssertFalse(connected.isTerminal)
        XCTAssertEqual(connected.statusDescription, "Connected")
        
        let unsupported = OperationState.unsupported(reason: "Kernel Sandbox Enforcement")
        XCTAssertTrue(unsupported.isTerminal)
        XCTAssertTrue(unsupported.statusDescription.contains("Unsupported"))
        
        let failed = OperationState.failed(error: "Network Timeout")
        XCTAssertTrue(failed.isTerminal)
        XCTAssertTrue(failed.statusDescription.contains("Failed"))
        
        let completed = OperationState.completed(summary: "Payload written")
        XCTAssertTrue(completed.isTerminal)
    }
}
