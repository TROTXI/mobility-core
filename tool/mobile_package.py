"""Package one app. Store mode is used only by the protected manual workflow.

No store publication or Firebase upload. Signing files exist only in a temporary
directory and are removed on success/failure. No secrets in command output.
"""

import argparse
import base64
from contextlib import contextmanager
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import plistlib
import re
import secrets
import shutil
import subprocess
import tempfile

from mobile_artifacts import APPS, capture, check_version, fingerprint, require

ROOT = Path(__file__).resolve().parent.parent


def secret(name):
    value = os.environ.get(name, "")
    require(bool(value), f"Missing protected setting: {name}.")
    return value


def run(*args, cwd=ROOT, env=None):
    subprocess.run(args, cwd=cwd, env=env, check=True)


def write_secret(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(value)
    path.chmod(0o600)


def build_environment(platform, source):
    env = dict(source)
    for name in ["MOBILE_CONFIG_JSON", "ANDROID_FIREBASE_JSON", "ANDROID_UPLOAD_KEY_BASE64",
                 "IOS_CERTIFICATE_BASE64", "IOS_CERTIFICATE_PASSWORD", "IOS_PROFILE_BASE64"]:
        env.pop(name, None)
    if platform == "ios":
        for name in list(env):
            if name.startswith("TROTXI_UPLOAD_"):
                env.pop(name)
    # Packaging cannot opt into provider uploads through inherited env.
    env["TROTXI_UPLOAD_DIAGNOSTICS"] = "false"
    return env


@contextmanager
def signing(platform, app, directory):
    env = os.environ.copy()
    if platform == "android":
        store = directory / "upload.jks"
        write_secret(store, base64.b64decode(secret("ANDROID_UPLOAD_KEY_BASE64"), validate=True))
        env["TROTXI_UPLOAD_STORE_FILE"] = str(store)
        for name in ["STORE_PASSWORD", "KEY_ALIAS", "KEY_PASSWORD", "CERT_SHA256"]:
            env[f"TROTXI_UPLOAD_{name}"] = secret(f"TROTXI_UPLOAD_{name}")
        fingerprint(env["TROTXI_UPLOAD_CERT_SHA256"])
        yield env, []
        return

    team = secret("TROTXI_APPLE_TEAM_ID")
    require(re.fullmatch(r"[A-Z0-9]{10}", team), "Invalid Apple team ID.")
    profile = directory / "distribution.mobileprovision"
    certificate = directory / "distribution.p12"
    keychain = directory / "release.keychain-db"
    write_secret(profile, base64.b64decode(secret("IOS_PROFILE_BASE64"), validate=True))
    write_secret(certificate, base64.b64decode(secret("IOS_CERTIFICATE_BASE64"), validate=True))
    data = plistlib.loads(capture("security", "cms", "-D", "-i", str(profile)))
    entitlements = data.get("Entitlements", {})
    require(data.get("TeamIdentifier") == [team], "Provisioning team mismatch.")
    require(entitlements.get("application-identifier") == f"{team}.{APPS[app][1]}", "Provisioning app mismatch.")
    require(entitlements.get("get-task-allow") is False and
            entitlements.get("aps-environment") == "production", "Distribution push profile required.")
    require(not data.get("ProvisionedDevices") and not data.get("ProvisionsAllDevices"), "App Store profile required.")
    expiry = data.get("ExpirationDate")
    require(isinstance(expiry, datetime) and expiry.replace(tzinfo=timezone.utc) > datetime.now(timezone.utc),
            "Provisioning profile expired.")
    uuid = data.get("UUID", "")
    require(re.fullmatch(r"[A-Fa-f0-9-]{36}", uuid), "Invalid provisioning UUID.")
    expected_certificate = fingerprint(secret("IOS_CERT_SHA256"))
    require(any(hashlib.sha256(cert).hexdigest() == expected_certificate for cert in data.get("DeveloperCertificates", [])),
            "Profile does not allow the approved distribution certificate.")
    # Xcode 16+ uses this location. Never replace a pre-existing user profile.
    installed_profile = Path.home() / "Library/Developer/Xcode/UserData/Provisioning Profiles" / f"{uuid}.mobileprovision"
    require(not installed_profile.exists(), "Provisioning profile already exists on this runner.")
    password = secrets.token_hex(32)
    original_keychains = capture("security", "list-keychains", "-d", "user").decode()
    keychains = re.findall(r'"([^"]+)"', original_keychains)
    try:
        capture("security", "create-keychain", "-p", password, str(keychain))
        capture("security", "set-keychain-settings", "-lut", "21600", str(keychain))
        capture("security", "unlock-keychain", "-p", password, str(keychain))
        capture("security", "import", str(certificate), "-k", str(keychain), "-P", secret("IOS_CERTIFICATE_PASSWORD"),
                "-T", "/usr/bin/codesign", "-T", "/usr/bin/security")
        capture("security", "set-key-partition-list", "-S", "apple-tool:,apple:,codesign:", "-s", "-k", password, str(keychain))
        capture("security", "list-keychains", "-d", "user", "-s", str(keychain), *keychains)
        pem = capture("security", "find-certificate", "-a", "-p", str(keychain))
        blocks = re.findall(rb"-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----", pem, re.S)
        matches = [block for block in blocks if hashlib.sha256(capture("openssl", "x509", "-outform", "DER", input=block)).hexdigest() == expected_certificate]
        require(len(matches) == 1, "Imported signing certificate mismatch.")
        cert_der = capture("openssl", "x509", "-outform", "DER", input=matches[0])
        identity = hashlib.sha1(cert_der).hexdigest()  # Apple's keychain identity selector, not a security digest.
        write_secret(installed_profile, profile.read_bytes())
        export = directory / "ExportOptions.plist"
        export.write_bytes(plistlib.dumps({
            "method": "app-store-connect", "destination": "export", "signingStyle": "manual",
            "teamID": team, "signingCertificate": identity,
            "provisioningProfiles": {APPS[app][1]: uuid},
            "manageAppVersionAndBuildNumber": False, "uploadSymbols": False,
        }))
        yield env, [f"DEVELOPMENT_TEAM={team}", "CODE_SIGN_STYLE=Manual",
                    f"CODE_SIGN_IDENTITY={identity}", f"PROVISIONING_PROFILE_SPECIFIER={uuid}"]
    finally:
        installed_profile.unlink(missing_ok=True)
        # Hosted ephemeral runners only. Restore search paths even on failure.
        try:
            capture("security", "list-keychains", "-d", "user", "-s", *keychains)
        finally:
            if keychain.exists():
                capture("security", "delete-keychain", str(keychain))


def build(args, directory, env, signing_args):
    env = build_environment(args.platform, env)
    app = ROOT / "apps" / f"trotxi_{args.app}"
    config = app / "config" / ("production.json" if args.mode == "store" else "staging.json")
    values = json.loads(config.read_text())
    require(values["APP_ENVIRONMENT"] == ("production" if args.mode == "store" else "staging"), "Wrong package environment.")
    # Fail closed on the reviewed policy BEFORE native compilation or signing.
    run("dart", str(ROOT / "tool/validate_mobile_build.dart"), str(app), "release", str(config), env=env)
    run("flutter", "pub", "get", "--enforce-lockfile", cwd=app, env=env)
    flags = ["--release", f"--dart-define-from-file={config}", f"--build-number={args.number}", f"--build-name={args.version}"]
    if args.platform == "android":
        if args.mode == "validation":
            env = dict(env, ORG_GRADLE_PROJECT_trotxiUnsignedValidation="true")
        run("flutter", "build", "appbundle", *flags, cwd=app, env=env)
        artifact = app / "build/app/outputs/bundle/release/app-release.aab"
    else:
        version = capture("xcodebuild", "-version").decode()
        require(int(re.search(r"Xcode (\d+)", version)[1]) >= 26, "Xcode 26 or newer is required.")
        if args.mode == "validation":
            run("flutter", "build", "ipa", "--no-codesign", *flags, cwd=app, env=env)
            artifact = app / "build/ios/archive/Runner.xcarchive"
        else:
            run("flutter", "build", "ios", "--config-only", "--no-codesign", *flags, cwd=app, env=env)
            archive = app / "build/ios/archive/Runner.xcarchive"
            run("xcodebuild", "-hideShellScriptEnvironment", "-workspace", "Runner.xcworkspace", "-scheme", "Runner", "-configuration", "Release",
                "-destination", "generic/platform=iOS", "-archivePath", str(archive), *signing_args, "archive", cwd=app / "ios", env=env)
            export = app / "build/ios/ipa"
            run("xcodebuild", "-hideShellScriptEnvironment", "-exportArchive", "-archivePath", str(archive), "-exportPath", str(export),
                "-exportOptionsPlist", str(directory / "ExportOptions.plist"), cwd=app, env=env)
            packages = list(export.glob("*.ipa"))
            require(len(packages) == 1, "Expected one exported IPA.")
            artifact = packages[0]
    output = ROOT / "release-artifacts"
    output.mkdir(exist_ok=True)
    run("python3", str(ROOT / "tool/mobile_artifacts.py"), args.platform, "--app", args.app, "--mode", args.mode,
        "--number", args.number, "--version", args.version, "--config", str(config), "--artifact", str(artifact),
        "--report", str(output / "validation.json"), env=env)
    if artifact.is_dir():
        # Preserve archive symlinks/modes. IPA extraction is only used for inspection.
        run("tar", "-czf", str(output / "Runner.xcarchive.tar.gz"), "-C", str(artifact.parent), artifact.name)
    else:
        shutil.copy2(artifact, output / artifact.name)
    # Symbol/mapping files are retained as artifacts, not uploaded to Firebase.
    for source in [app / "build/app/outputs/mapping/release", app / "build/ios/archive/Runner.xcarchive/dSYMs"]:
        if source.is_dir():
            shutil.copytree(source, output / ("mapping" if args.platform == "android" else "dSYMs"))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("platform", choices=["android", "ios"])
    parser.add_argument("--app", choices=APPS, required=True)
    parser.add_argument("--mode", choices=["validation", "store"], required=True)
    parser.add_argument("--number", required=True)
    parser.add_argument("--version", required=True)
    args = parser.parse_args()
    check_version(args.number, args.version)
    require(not (ROOT / "release-artifacts").exists(), "Use a clean worktree for each packaging run.")
    with tempfile.TemporaryDirectory(prefix="trotxi-signing-", dir=os.environ.get("RUNNER_TEMP")) as temporary:
        directory = Path(temporary)
        if args.mode == "validation":
            build(args, directory, os.environ.copy(), [])
            return
        require(os.environ.get("GITHUB_REF") == "refs/heads/main" and
                os.environ.get("GITHUB_EVENT_NAME") == "workflow_dispatch" and
                os.environ.get("GITHUB_RUN_ATTEMPT") == "1", "Store packages require a new protected manual main run.")
        app = ROOT / "apps" / f"trotxi_{args.app}"
        config = app / "config/production.json"
        provider = app / "config/production/google-services.json"
        require(not config.exists() and not provider.exists(), "Production configuration already exists; refusing to overwrite it.")
        try:
            write_secret(config, secret("MOBILE_CONFIG_JSON").encode())
            write_secret(provider, secret("ANDROID_FIREBASE_JSON").encode())
            # Do this before importing signing identities, not only in build().
            run("dart", str(ROOT / "tool/validate_mobile_build.dart"), str(app), "release", str(config),
                env=build_environment(args.platform, os.environ))
            with signing(args.platform, args.app, directory) as (env, signing_args):
                build(args, directory, env, signing_args)
        finally:
            config.unlink(missing_ok=True)
            provider.unlink(missing_ok=True)


if __name__ == "__main__":
    try:
        main()
    except ValueError as error:
        raise SystemExit(str(error))
    except Exception:
        # CalledProcessError can include passwords in its command representation.
        raise SystemExit("Mobile packaging failed. No store or Firebase upload was attempted.")
