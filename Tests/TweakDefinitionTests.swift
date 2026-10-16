import XCTest
@testable import X

final class TweakDefinitionTests: XCTestCase {
    
    func testAllTweaksHaveUniqueIdentifiersAndKeys() {
        let tweaks = AuditedSpringBoardTweaks.all
        XCTAssertGreaterThan(tweaks.count, 0, "There must be at least one audited tweak defined.")
        
        var seenIDs = Set<String>()
        var seenKeys = Set<String>()
        
        for tweak in tweaks {
            XCTAssertFalse(seenIDs.contains(tweak.id), "Duplicate tweak id found: \(tweak.id)")
            seenIDs.insert(tweak.id)
            
            XCTAssertFalse(seenKeys.contains(tweak.key), "Duplicate tweak key found: \(tweak.key)")
            seenKeys.insert(tweak.key)
            
            XCTAssertTrue(tweak.key.hasPrefix("SB"), "SpringBoard preference keys must start with SB: \(tweak.key)")
            XCTAssertFalse(tweak.title.isEmpty, "Tweak title must not be empty.")
            XCTAssertFalse(tweak.sourceEvidence.isEmpty, "Source evidence must be recorded for every tweak.")
        }
    }
    
    func testSupportLevelsAreDocumented() {
        for tweak in AuditedSpringBoardTweaks.all {
            switch tweak.supportLevel {
            case .verifiedSupported:
                XCTAssertFalse(tweak.sourceEvidence.isEmpty)
            case .configurationOnly:
                XCTAssertFalse(tweak.sourceEvidence.isEmpty)
            case .unverifiedExperimental:
                XCTAssertFalse(tweak.sourceEvidence.isEmpty)
            case .unsupportedObsolete:
                XCTAssertFalse(tweak.sourceEvidence.isEmpty)
            }
        }
    }
}
