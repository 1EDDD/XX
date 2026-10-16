#!/usr/bin/env python3
import plistlib
import sys
import os
import io

def run_tests():
    print("==================================================")
    print("    Project X: Native Plist & Schema Test Suite   ")
    print("==================================================")
    
    passed = 0
    failed = 0
    
    def test(name, fn):
        nonlocal passed, failed
        try:
            fn()
            print(f"  ✅ PASS: {name}")
            passed += 1
        except Exception as e:
            print(f"  ❌ FAIL: {name} -> {e}")
            failed += 1

    # 1. Test SpringBoard Keys
    def test_springboard_keys():
        expected_keys = [
            "SBHideLowPowerAlerts",
            "SBHideACPower",
            "SBDontLockAfterCrash",
            "SBDontDimOrLockOnAC",
            "SBAlwaysShowSystemApertureInSnapshots",
            "SBShowAuthenticationEngineeringUI",
            "SBNeverBreadcrumb",
            "SBShowSupervisionTextOnLockScreen"
        ]
        
        # Verify keys in TweakDefinition.swift
        with open("X/Models/TweakDefinition.swift", "r") as f:
            content = f.read()
            for key in expected_keys:
                assert key in content, f"Key {key} not found in TweakDefinition.swift"
                assert key.startswith("SB"), f"Key {key} does not follow SpringBoard prefix convention"

    test("SpringBoard Preference Keys Audit", test_springboard_keys)

    # 2. Test XML Property List Generation & Roundtrip
    def test_xml_plist():
        payload = {
            "SBHideLowPowerAlerts": True,
            "SBAlwaysShowSystemApertureInSnapshots": False,
            "SBHideACPower": True,
            "SBNeverBreadcrumb": True
        }
        xml_bytes = plistlib.dumps(payload, fmt=plistlib.FMT_XML)
        assert b"<!DOCTYPE plist PUBLIC" in xml_bytes
        assert b"<key>SBHideLowPowerAlerts</key>" in xml_bytes
        assert b"<true/>" in xml_bytes
        
        loaded = plistlib.loads(xml_bytes)
        assert loaded == payload
    
    test("XML Property List (com.apple.springboard.plist) Serialization", test_xml_plist)

    # 3. Test Binary Property List (bplist00) Generation & Magic Bytes
    def test_binary_plist():
        payload = {
            "SBDontLockAfterCrash": True,
            "SBDontDimOrLockOnAC": True
        }
        bplist_bytes = plistlib.dumps(payload, fmt=plistlib.FMT_BINARY)
        assert bplist_bytes[:8] == b"bplist00", f"Invalid magic bytes: {bplist_bytes[:8]}"
        
        loaded = plistlib.loads(bplist_bytes)
        assert loaded == payload
        
    test("Binary Property List (bplist00) Verification", test_binary_plist)

    # 4. Test Pairing Record Schema Validation
    def test_pairing_record():
        valid_pairing = {
            "SystemBUID": "00008110-001A849201948210",
            "HostID": "MAC-TEST-HOST-01",
            "HostName": "X",
            "HostModel": "Mac17,7",
            "WiFiMACAddress": "38:f9:d3:88:91:c2",
            "XPairingHostAltIRK": "0xABCDEF1234567890",
            "DeviceCertificate": b"\x01\x02\x03",
            "HostCertificate": b"\x04\x05\x06"
        }
        data = plistlib.dumps(valid_pairing, fmt=plistlib.FMT_XML)
        parsed = plistlib.loads(data)
        assert parsed["SystemBUID"] == "00008110-001A849201948210"
        assert parsed["HostModel"] == "Mac17,7"
        assert "DeviceCertificate" in parsed
    
    test("Pairing Record Schema (airlift_pairing.plist) Validation", test_pairing_record)

    # 5. Verify XcodeGen project.yml
    def test_project_yml():
        assert os.path.exists("project.yml")
        with open("project.yml", "r") as f:
            content = f.read()
            assert "name: X" in content
            assert "XTests:" in content
            assert "SWIFT_VERSION: \"6.0\"" in content
            assert "IPHONEOS_DEPLOYMENT_TARGET: \"18.0\"" in content
            assert "com.projectx.toolkit" in content

    test("XcodeGen project.yml Specification", test_project_yml)

    # 6. Verify Info.plist & Entitlements
    def test_info_plist_and_entitlements():
        assert os.path.exists("X/Resources/Info.plist")
        with open("X/Resources/Info.plist", "rb") as f:
            info = plistlib.load(f)
            assert info["CFBundleDisplayName"] == "X"
            assert "_airtraffic._tcp" in info["NSBonjourServices"]
            
        assert os.path.exists("X/Resources/X.entitlements")
        with open("X/Resources/X.entitlements", "rb") as f:
            ent = plistlib.load(f)
            assert ent.get("com.apple.developer.networking.multicast") is True

    test("Info.plist and X.entitlements Verification", test_info_plist_and_entitlements)

    print("--------------------------------------------------")
    print(f"Results: {passed} passed, {failed} failed.")
    print("--------------------------------------------------")
    
    if failed > 0:
        sys.exit(1)

if __name__ == "__main__":
    run_tests()
