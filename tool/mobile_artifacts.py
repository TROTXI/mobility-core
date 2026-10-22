"""Inspect built artifacts, not source manifests. Standard library only.

The native pre-build gate embeds a receipt from the exact Flutter definitions.
This complements configuration validation; it is not a binary security audit or
Apple's aggregate privacy report. Never print credentials/provider exceptions.
"""

import argparse
import hashlib
import json
import os
from pathlib import Path
import plistlib
import re
import subprocess
import tempfile
import xml.etree.ElementTree as ET
import zipfile


ANDROID = "{http://schemas.android.com/apk/res/android}"
APPS = {
    "commuter": ("com.trotxi.trotxi_commuter", "com.trotxi.trotxiCommuter", "Trotxi Commuter"),
    "driver": ("com.trotxi.trotxi_driver", "com.trotxi.trotxiDriver", "Trotxi Driver"),
}


def require(condition, message):
    if not condition:
        raise ValueError(message)


def capture(*args, input=None):
    return subprocess.run(args, input=input, stdout=subprocess.PIPE,
                          stderr=subprocess.PIPE, check=True).stdout


def check_version(number, version):
    # Single-component CFBundleVersion is kept within Apple's four-digit limit.
    require(re.fullmatch(r"[1-9][0-9]{0,3}", str(number)), "Build number must be 1..9999.")
    require(re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+", version), "Version must be major.minor.patch.")


def check_receipt(receipt, app, mode, number, version, config):
    expected = {
        "app": f"trotxi_{app}",
        "environment": "production" if mode == "store" else "staging",
        "apiOrigin": config["API_BASE_URL"],
        "publicSiteOrigin": config["PUBLIC_SITE_URL"],
        "realm": config["API_SESSION_REALM"],
        "firebaseProject": config["FIREBASE_PROJECT_ID"],
        "buildNumber": str(number),
        "version": version,
    }
    require(receipt == expected, "Artifact environment/version receipt does not match this build.")
    require(config["APP_ENVIRONMENT"] == expected["environment"], "Wrong build environment.")


def check_android_manifest(xml, app, number, version):
    root = ET.fromstring(xml)
    require(root.get("package") == APPS[app][0], "Wrong Android package.")
    require(root.get(ANDROID + "versionCode") == str(number), "Wrong Android build number.")
    require(root.get(ANDROID + "versionName") == version, "Wrong Android version.")
    sdk = root.find("uses-sdk")
    require(sdk is not None and int(sdk.get(ANDROID + "targetSdkVersion", "0")) >= 36,
            "Android target API must be at least 36.")
    application = root.find("application")
    require(application is not None, "Missing application manifest.")
    require(application.get(ANDROID + "debuggable", "false") == "false", "Debuggable release.")
    require(application.get(ANDROID + "usesCleartextTraffic", "false") == "false", "Cleartext traffic enabled.")
    require(application.get(ANDROID + "label") == APPS[app][2], "Wrong launcher name.")
    permissions = {entry.get(ANDROID + "name") for entry in root if entry.tag.startswith("uses-permission")}
    require(not any("AD_ID" in p or "ACCESS_ADSERVICES" in p for p in permissions if p),
            "Advertising permission in release.")
    require("android.permission.POST_NOTIFICATIONS" in permissions, "Push permission missing.")
    if app == "commuter":
        require(not any("LOCATION" in p for p in permissions if p), "Commuter requests device location.")
    else:
        require({"android.permission.ACCESS_FINE_LOCATION", "android.permission.ACCESS_COARSE_LOCATION",
                 "android.permission.FOREGROUND_SERVICE_LOCATION", "android.permission.CAMERA"} <= permissions,
                "Driver location/camera permissions missing.")
    metadata = {entry.get(ANDROID + "name"): entry.get(ANDROID + "value")
                for entry in application.findall("meta-data")}
    for key in ["firebase_crashlytics_collection_enabled", "firebase_performance_collection_enabled"]:
        require(metadata.get(key) == "false", "Automatic diagnostics collection enabled.")
    return sorted(permissions)


def fingerprint(value):
    result = value.replace(":", "").lower()
    require(re.fullmatch("[0-9a-f]{64}", result), "Approved certificate SHA-256 is required.")
    return result


def check_android_signature(artifact, mode):
    with zipfile.ZipFile(artifact) as archive:
        signatures = [name for name in archive.namelist()
                      if re.fullmatch(r"META-INF/[^/]+\.(SF|RSA|DSA|EC)", name, re.I)]
    if mode == "validation":
        require(not signatures, "Validation AAB must be unsigned.")
        return None
    require(signatures, "Store AAB has no signature.")
    require(sum(name.upper().endswith(".SF") for name in signatures) == 1 and
            sum(name.upper().endswith((".RSA", ".DSA", ".EC")) for name in signatures) == 1,
            "Store AAB must have exactly one approved signer.")
    verified = capture("jarsigner", "-J-Duser.language=en", "-verify", str(artifact)).decode()
    require("jar verified." in verified and "unsigned entries" not in verified,
            "AAB signature is invalid or contains unsigned entries.")
    certificate = capture("keytool", "-J-Duser.language=en", "-printcert", "-rfc", "-jarfile", str(artifact))
    der = capture("openssl", "x509", "-outform", "DER", input=certificate)
    subject = capture("openssl", "x509", "-noout", "-subject", input=certificate).decode().lower()
    actual = hashlib.sha256(der).hexdigest()
    require("android debug" not in subject, "Debug-signed AAB.")
    require(actual == fingerprint(os.environ.get("TROTXI_UPLOAD_CERT_SHA256", "")), "Wrong AAB signing certificate.")
    return actual


def check_ios_info(info, app, number, version):
    require(info.get("CFBundleIdentifier") == APPS[app][1], "Wrong iOS bundle ID.")
    require(info.get("CFBundleDisplayName") == APPS[app][2], "Wrong iOS app name.")
    require(info.get("CFBundleVersion") == str(number), "Wrong iOS build number.")
    require(info.get("CFBundleShortVersionString") == version, "Wrong iOS version.")
    require(int(info.get("DTXcode", "0")) >= 2600, "Archive needs Xcode 26 or newer.")
    require(info.get("DTPlatformName") == "iphoneos", "Simulator is not a device archive.")
    require(not info.get("NSAppTransportSecurity", {}).get("NSAllowsArbitraryLoads", False), "Unrestricted iOS networking.")
    require(not info.get("NSUserTrackingUsageDescription"), "Unexpected tracking prompt.")
    for key in ["NSCameraUsageDescription", "NSPhotoLibraryUsageDescription"]:
        require(bool(info.get(key, "").strip()), "Missing iOS permission explanation.")
    require("remote-notification" in info.get("UIBackgroundModes", []), "Background push mode missing.")
    if app == "driver":
        require("location" in info.get("UIBackgroundModes", []), "Driver background location missing.")
        for key in ["NSLocationWhenInUseUsageDescription", "NSLocationAlwaysAndWhenInUseUsageDescription"]:
            require(bool(info.get(key, "").strip()), "Missing driver location explanation.")
    else:
        require("location" not in info.get("UIBackgroundModes", []) and
                not any(key.startswith("NSLocation") for key in info), "Commuter location capability.")
    require(info.get("FirebaseCrashlyticsCollectionEnabled") is False, "Automatic crash uploads enabled.")
    require(info.get("firebase_performance_collection_enabled") is False, "Automatic performance collection enabled.")


def check_privacy(manifests):
    # Critical linked provider manifests, not an arbitrary pinned file count.
    for sdk in ["firebasecore", "firebasemessaging", "firebasecrashlytics",
                "flutter.framework", "maplibre.framework", "flutter_secure_storage"]:
        require(any(sdk in path.lower() for path in manifests), f"Missing {sdk} privacy manifest.")
    for contents in manifests.values():
        require(contents.get("NSPrivacyTracking", False) is False, "Tracking declared in a release manifest.")
        require(not contents.get("NSPrivacyTrackingDomains", []), "Tracking domains declared.")
        for entry in contents.get("NSPrivacyAccessedAPITypes", []):
            require(bool(entry.get("NSPrivacyAccessedAPIType")) and
                    bool(entry.get("NSPrivacyAccessedAPITypeReasons")), "Required-reason API lacks reasons.")
    return manifests


def check_ios_entitlements(entitlements, app, team):
    require(bool(re.fullmatch(r"[A-Z0-9]{10}", team)), "Apple team ID required.")
    require(entitlements.get("application-identifier") == f"{team}.{APPS[app][1]}", "Wrong signed app identity.")
    require(entitlements.get("com.apple.developer.team-identifier") == team, "Wrong signing team.")
    require(entitlements.get("get-task-allow") is False, "Development/debugging entitlement present.")
    require(entitlements.get("aps-environment") == "production", "Store push entitlement is not production.")


def inspect_ios(directory, args, config):
    info = plistlib.loads((directory / "Info.plist").read_bytes())
    check_ios_info(info, args.app, args.number, args.version)
    receipt = json.loads((directory / "trotxi_build.json").read_text())
    check_receipt(receipt, args.app, args.mode, args.number, args.version, config)
    manifests = {str(path.relative_to(directory)): plistlib.loads(path.read_bytes())
                 for path in directory.rglob("PrivacyInfo.xcprivacy")}
    check_privacy(manifests)
    if args.mode == "store":
        capture("codesign", "--verify", "--deep", "--strict", str(directory))
        entitlements = plistlib.loads(capture("codesign", "-d", "--entitlements", ":-", str(directory)))
        check_ios_entitlements(entitlements, args.app, os.environ.get("TROTXI_APPLE_TEAM_ID", ""))
        with tempfile.TemporaryDirectory() as temporary:
            prefix = str(Path(temporary) / "certificate")
            capture("codesign", "-d", "--extract-certificates", prefix, str(directory))
            actual = hashlib.sha256(Path(prefix + "0").read_bytes()).hexdigest()
            require(actual == fingerprint(os.environ.get("IOS_CERT_SHA256", "")), "Wrong IPA signing certificate.")
    else:
        require(not (directory / "_CodeSignature").exists(), "Validation archive must not be signed.")
    return {"receipt": receipt, "privacyManifests": manifests}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("platform", choices=["android", "ios"])
    parser.add_argument("--app", choices=APPS, required=True)
    parser.add_argument("--mode", choices=["validation", "store"], required=True)
    parser.add_argument("--number", required=True)
    parser.add_argument("--version", required=True)
    parser.add_argument("--config", type=Path, required=True)
    parser.add_argument("--artifact", type=Path, required=True)
    parser.add_argument("--report", type=Path, required=True)
    args = parser.parse_args()
    check_version(args.number, args.version)
    config = json.loads(args.config.read_text())
    if args.platform == "android":
        xml = capture("java", "-jar", os.environ["BUNDLETOOL_JAR"], "dump", "manifest",
                      f"--bundle={args.artifact}", "--module=base")
        permissions = check_android_manifest(xml, args.app, args.number, args.version)
        with zipfile.ZipFile(args.artifact) as archive:
            receipt = json.loads(archive.read("base/assets/trotxi_build.json"))
        check_receipt(receipt, args.app, args.mode, args.number, args.version, config)
        report = {"receipt": receipt, "permissions": permissions,
                  "certificateSha256": check_android_signature(args.artifact, args.mode)}
    elif args.artifact.suffix == ".ipa":
        with tempfile.TemporaryDirectory() as temporary:
            with zipfile.ZipFile(args.artifact) as archive:
                require(all(not Path(n).is_absolute() and ".." not in Path(n).parts for n in archive.namelist()),
                        "Unsafe archive entry.")
            # Unlike ZipFile.extractall, ditto preserves framework symlinks and
            # executable modes needed for accurate codesign verification.
            capture("ditto", "-x", "-k", str(args.artifact), temporary)
            bundles = list((Path(temporary) / "Payload").glob("*.app"))
            require(len(bundles) == 1, "Expected one iOS application.")
            report = inspect_ios(bundles[0], args, config)
    else:
        report = inspect_ios(args.artifact / "Products/Applications/Runner.app", args, config)
    if args.artifact.is_file():
        with args.artifact.open("rb") as artifact_file:
            report["sha256"] = hashlib.file_digest(artifact_file, "sha256").hexdigest()
    report["mode"] = args.mode
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report, indent=2) + "\n")
    print(f"Validated {args.app} {args.platform} {args.mode} artifact.")


if __name__ == "__main__":
    try:
        main()
    except ValueError as error:
        raise SystemExit(str(error))
    except Exception:
        raise SystemExit("Artifact inspection failed. Check the build/configuration and tool availability.")
