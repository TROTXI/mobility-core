import json
import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch
import zipfile

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from mobile_artifacts import (APPS, check_android_manifest, check_android_signature,
                              check_ios_entitlements, check_ios_info, check_privacy,
                              check_receipt, check_version, fingerprint)
import reserve_mobile_build
import mobile_package


class ArtifactTests(unittest.TestCase):
    def manifest(self, app="commuter"):
        permissions = '<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>'
        if app == "driver":
            for name in ["ACCESS_FINE_LOCATION", "ACCESS_COARSE_LOCATION", "FOREGROUND_SERVICE_LOCATION", "CAMERA"]:
                permissions += f'<uses-permission android:name="android.permission.{name}"/>'
        return f'''<manifest xmlns:android="http://schemas.android.com/apk/res/android"
          package="{APPS[app][0]}" android:versionCode="12" android:versionName="1.0.0">
          <uses-sdk android:targetSdkVersion="36"/>{permissions}
          <application android:label="{APPS[app][2]}">
          <meta-data android:name="firebase_crashlytics_collection_enabled" android:value="false"/>
          <meta-data android:name="firebase_performance_collection_enabled" android:value="false"/>
          </application></manifest>'''

    def test_both_android_manifests(self):
        for app in APPS:
            check_android_manifest(self.manifest(app), app, "12", "1.0.0")

    def test_android_rejects_wrong_identity_version_sdk_debug_or_collection(self):
        for old, new in [(APPS["commuter"][0], APPS["driver"][0]), ('versionCode="12"', 'versionCode="13"'),
                         ('versionName="1.0.0"', 'versionName="1.1.0"'), ('targetSdkVersion="36"', 'targetSdkVersion="35"'),
                         ('<application ', '<application android:debuggable="true" '),
                         ('android:value="false"', 'android:value="true"'),
                         ('Trotxi Commuter', 'Flutter app')]:
            with self.subTest(new=new), self.assertRaises(ValueError):
                check_android_manifest(self.manifest().replace(old, new), "commuter", "12", "1.0.0")

    def test_android_forbids_location_and_ads(self):
        for permission in ["ACCESS_FINE_LOCATION", "ACCESS_BACKGROUND_LOCATION", "ACCESS_ADSERVICES_TOPICS"]:
            xml = self.manifest().replace('</manifest>', f'<uses-permission android:name="android.permission.{permission}"/></manifest>')
            with self.subTest(permission=permission), self.assertRaises(ValueError):
                check_android_manifest(xml, "commuter", "12", "1.0.0")

    def test_receipt_matches_exact_build_config(self):
        config = {"APP_ENVIRONMENT": "staging", "API_BASE_URL": "https://api.example.invalid",
                  "PUBLIC_SITE_URL": "https://site.example.invalid", "API_SESSION_REALM": "staging-test",
                  "FIREBASE_PROJECT_ID": "test-project"}
        receipt = {"app": "trotxi_commuter", "environment": "staging", "apiOrigin": config["API_BASE_URL"],
                   "publicSiteOrigin": config["PUBLIC_SITE_URL"], "realm": config["API_SESSION_REALM"],
                   "firebaseProject": config["FIREBASE_PROJECT_ID"], "buildNumber": "12", "version": "1.0.0"}
        check_receipt(receipt, "commuter", "validation", "12", "1.0.0", config)
        with self.assertRaises(ValueError):
            check_receipt(receipt, "commuter", "store", "12", "1.0.0", config)
        for field in receipt:
            bad = dict(receipt, **{field: "wrong"})
            with self.subTest(field=field), self.assertRaises(ValueError):
                check_receipt(bad, "commuter", "validation", "12", "1.0.0", config)

    def test_build_number_and_version(self):
        check_version("9999", "1.2.3")
        for number in ["0", "10000", "01", "1.0", "-1", "1\n", "$(bad)"]:
            with self.assertRaises(ValueError):
                check_version(number, "1.0.0")
        for version in ["1", "1.0", "1.0.0+1", "1.0.0-beta"]:
            with self.assertRaises(ValueError):
                check_version("1", version)

    def ios_info(self, app="commuter"):
        info = {"CFBundleIdentifier": APPS[app][1], "CFBundleDisplayName": APPS[app][2],
                "CFBundleVersion": "12", "CFBundleShortVersionString": "1.0.0", "DTXcode": "2600",
                "DTPlatformName": "iphoneos", "NSCameraUsageDescription": "Profile photo",
                "NSPhotoLibraryUsageDescription": "Profile photo", "UIBackgroundModes": ["remote-notification"],
                "FirebaseCrashlyticsCollectionEnabled": False, "firebase_performance_collection_enabled": False}
        if app == "driver":
            info["UIBackgroundModes"].append("location")
            info["NSLocationWhenInUseUsageDescription"] = "Active trip"
            info["NSLocationAlwaysAndWhenInUseUsageDescription"] = "Active trip"
        return info

    def test_ios_device_archive_checks(self):
        for app in APPS:
            check_ios_info(self.ios_info(app), app, "12", "1.0.0")
        for field, value in [("DTXcode", "1640"), ("DTPlatformName", "iphonesimulator"),
                             ("NSCameraUsageDescription", ""), ("FirebaseCrashlyticsCollectionEnabled", True),
                             ("UIBackgroundModes", ["location"]), ("CFBundleVersion", "11")]:
            info = dict(self.ios_info(), **{field: value})
            with self.subTest(field=field), self.assertRaises(ValueError):
                check_ios_info(info, "commuter", "12", "1.0.0")

    def test_distribution_entitlements(self):
        data = {"application-identifier": "ABCDE12345.com.trotxi.trotxiCommuter",
                "com.apple.developer.team-identifier": "ABCDE12345", "get-task-allow": False,
                "aps-environment": "production"}
        check_ios_entitlements(data, "commuter", "ABCDE12345")
        for field, value in [("get-task-allow", True), ("aps-environment", "development"),
                             ("application-identifier", "ABCDE12345.*")]:
            with self.subTest(field=field), self.assertRaises(ValueError):
                check_ios_entitlements(dict(data, **{field: value}), "commuter", "ABCDE12345")

    def test_privacy_from_existing_inventory_and_negative_cases(self):
        root = Path(__file__).resolve().parents[2]
        for app in json.loads((root / "docs/mobile-privacy-manifest-inventory.json").read_text()):
            manifests = {item["path"]: item["declarations"] for item in app["manifests"]}
            check_privacy(manifests)
            for bad in [{}, {**manifests, "bad": {"NSPrivacyTracking": True}},
                        {**manifests, "bad": {"NSPrivacyAccessedAPITypes": [{"NSPrivacyAccessedAPIType": "test"}]}}]:
                with self.assertRaises(ValueError):
                    check_privacy(bad)

    def test_signed_validation_and_unsigned_store_are_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "app.aab"
            with zipfile.ZipFile(path, "w") as archive:
                archive.writestr("base/test", "test")
            check_android_signature(path, "validation")
            with self.assertRaises(ValueError):
                check_android_signature(path, "store")
            with zipfile.ZipFile(path, "a") as archive:
                archive.writestr("META-INF/CERT.SF", "not a real signature")
            with self.assertRaises(ValueError):
                check_android_signature(path, "validation")

    def test_sha256_is_required(self):
        self.assertEqual(fingerprint("AB:" * 31 + "AB"), "ab" * 32)
        for value in ["", "debug", "ab" * 20]:
            with self.assertRaises(ValueError):
                fingerprint(value)


class ReservationTests(unittest.TestCase):
    def test_rejects_reruns_or_non_main_before_network(self):
        with patch.dict(os.environ, {"GITHUB_REF": "refs/heads/work", "GITHUB_EVENT_NAME": "workflow_dispatch", "GITHUB_RUN_ATTEMPT": "1"}), \
             patch("reserve_mobile_build.subprocess.run") as request:
            with self.assertRaises(ValueError):
                reserve_mobile_build.main()
            request.assert_not_called()

    def test_rerun_is_rejected(self):
        with patch.dict(os.environ, {"GITHUB_REF": "refs/heads/main", "GITHUB_EVENT_NAME": "workflow_dispatch", "GITHUB_RUN_ATTEMPT": "2"}), \
             patch("reserve_mobile_build.subprocess.run") as request:
            with self.assertRaises(ValueError):
                reserve_mobile_build.main()
            request.assert_not_called()

    def test_unset_store_floor_fails_closed(self):
        with patch.dict(os.environ, {"GITHUB_REF": "refs/heads/main", "GITHUB_EVENT_NAME": "workflow_dispatch", "GITHUB_RUN_ATTEMPT": "1",
                                     "BUILD_NUMBER": "12", "VERSION_NAME": "1.0.0", "MOBILE_STORE_BUILD_FLOOR": ""}), \
             patch("reserve_mobile_build.subprocess.run") as request:
            with self.assertRaises(ValueError):
                reserve_mobile_build.main()
            request.assert_not_called()

    def test_duplicate_lower_and_new_number(self):
        with tempfile.TemporaryDirectory() as directory:
            env = {"GITHUB_REF": "refs/heads/main", "GITHUB_EVENT_NAME": "workflow_dispatch", "GITHUB_RUN_ATTEMPT": "1",
                   "GITHUB_REPOSITORY": "example/test", "GITHUB_SHA": "a" * 40, "MOBILE_STORE_BUILD_FLOOR": "8",
                   "VERSION_NAME": "1.0.0", "GITHUB_OUTPUT": str(Path(directory) / "out")}
            for number in ["7", "8", "9", "10"]:
                with patch.dict(os.environ, dict(env, BUILD_NUMBER=number)), \
                     patch("reserve_mobile_build.subprocess.run") as request:
                    request.return_value.stdout = b'[{"ref":"refs/tags/mobile-build-9"}]'
                    if number != "10":
                        with self.assertRaises(ValueError):
                            reserve_mobile_build.main()
                        self.assertEqual(request.call_count, 1)
                    else:
                        reserve_mobile_build.main()
                        self.assertEqual(request.call_count, 2)
                        self.assertIn("number=10", Path(env["GITHUB_OUTPUT"]).read_text())


class PackagingTests(unittest.TestCase):
    def test_android_workflows_use_maplibre_required_java_version(self):
        root = Path(__file__).resolve().parents[2]
        for name in ("mobile-artifacts.yml", "mobile-store-release.yml"):
            with self.subTest(workflow=name):
                workflow = (root / ".github/workflows" / name).read_text()
                self.assertIn("uses: actions/setup-java@", workflow)
                self.assertEqual(workflow.count("java-version:"), 1)
                self.assertIn("java-version: '21'", workflow)

    def test_build_processes_do_not_receive_input_blobs_or_ios_passwords(self):
        source = {"MOBILE_CONFIG_JSON": "fixture", "ANDROID_FIREBASE_JSON": "fixture",
                  "ANDROID_UPLOAD_KEY_BASE64": "fixture", "IOS_CERTIFICATE_BASE64": "fixture",
                  "IOS_CERTIFICATE_PASSWORD": "fixture", "IOS_PROFILE_BASE64": "fixture",
                  "TROTXI_UPLOAD_STORE_PASSWORD": "fixture", "TROTXI_UPLOAD_DIAGNOSTICS": "true",
                  "TROTXI_APPLE_TEAM_ID": "ABCDE12345", "PATH": "/bin"}
        ios = mobile_package.build_environment("ios", source)
        self.assertEqual(ios, {"TROTXI_APPLE_TEAM_ID": "ABCDE12345", "PATH": "/bin", "TROTXI_UPLOAD_DIAGNOSTICS": "false"})
        android = mobile_package.build_environment("android", source)
        self.assertEqual(android["TROTXI_UPLOAD_STORE_PASSWORD"], "fixture")
        self.assertEqual(android["TROTXI_UPLOAD_DIAGNOSTICS"], "false")
        self.assertNotIn("ANDROID_UPLOAD_KEY_BASE64", android)
        self.assertNotIn("IOS_CERTIFICATE_PASSWORD", android)

    def test_android_signing_requires_every_protected_input(self):
        with tempfile.TemporaryDirectory() as directory, patch.dict(os.environ, {}, clear=True):
            with self.assertRaisesRegex(ValueError, "Missing protected setting"):
                with mobile_package.signing("android", "commuter", Path(directory)):
                    self.fail("Missing signing inputs were accepted")

    def test_native_wiring_has_no_release_debug_fallback(self):
        root = Path(__file__).resolve().parents[2]
        for app in APPS:
            gradle = (root / f"apps/trotxi_{app}/android/app/build.gradle.kts").read_text()
            self.assertIn('apply(from = "../../../../tool/android-release.gradle")', gradle)
            self.assertNotIn('signingConfigs.getByName("debug")', gradle)
            self.assertNotIn('else "debug"', gradle)
            self.assertIn('MOBILE_BUILD_RECEIPT', gradle)
            self.assertNotIn('assets.srcDir(', gradle)
            self.assertIn('variant.sources.assets?.addGeneratedSourceDirectory(', gradle)
            self.assertIn('ValidateMobileEnvironmentTask::receiptDirectory', gradle)
            self.assertIn('outputs.upToDateWhen { false }', gradle)
            xcode = (root / f"apps/trotxi_{app}/ios/Runner.xcodeproj/project.pbxproj").read_text()
            self.assertEqual(xcode.count("CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;"), 3)
            self.assertEqual(xcode.count("APS_ENVIRONMENT = production;"), 1)
            self.assertEqual(xcode.count("APS_ENVIRONMENT = development;"), 2)
            self.assertIn("validate_ios_build.sh", xcode)


if __name__ == "__main__":
    unittest.main()
