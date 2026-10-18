import java.io.FileInputStream
import java.util.Base64
import java.util.Properties

// The upload key lives outside the repository. Without it a release build
// still works and is signed with the debug key, which is what keeps
// `flutter run --release` and CI usable on a machine that holds no secret.
// Play refuses a debug-signed upload, so the real key is only needed by
// whoever is actually publishing.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val signable = keystorePropertiesFile.exists()
if (signable) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // Deliberately no Performance plugin: no automatic HTTP instrumentation.
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Run the same environment validation as startup before native or Flutter
// compilation. An ordinary flutter build cannot bypass this gate.
val mobileDefines = providers.gradleProperty("dart-defines").orElse("").get()
val mobileValues = mobileDefines.split(",").filter { it.isNotEmpty() }.associate {
    val pair = String(Base64.getDecoder().decode(it), Charsets.UTF_8)
    pair.substringBefore("=") to pair.substringAfter("=", "")
}
val mobileEnvironment = mobileValues["APP_ENVIRONMENT"].orEmpty()
val providerEnvironment = if (mobileEnvironment == "local") "staging" else mobileEnvironment
require(providerEnvironment in listOf("staging", "production")) {
    "Select APP_ENVIRONMENT with --dart-define-from-file=config/staging.json."
}
val mobileAppDirectory = project.file("../..")
val mobileFirebaseFile = project.file("../../config/$providerEnvironment/google-services.json")
val localProperties = Properties().apply {
    rootProject.file("local.properties").inputStream().use { load(it) }
}
val mobileBuildMode = if (
    gradle.startParameter.taskNames.any { it.contains("Debug", ignoreCase = true) } &&
    gradle.startParameter.taskNames.none { it.contains("Release", ignoreCase = true) || it.contains("Profile", ignoreCase = true) }
) "debug" else "release"
val validateMobileEnvironment = tasks.register<Exec>("validateMobileEnvironment") {
    environment("DART_DEFINES", mobileDefines)
    commandLine(
        "${localProperties.getProperty("flutter.sdk")}/bin/cache/dart-sdk/bin/dart",
        project.file("../../../../tool/validate_mobile_build.dart"),
        mobileAppDirectory, mobileBuildMode
    )
}
// Configure after variant registration: the provider plugin assigns its
// default search paths during registration and would overwrite an earlier set.
afterEvaluate {
    tasks.withType<com.google.gms.googleservices.GoogleServicesTask>().configureEach {
        googleServicesJsonFiles.set(listOf(mobileFirebaseFile))
        googleServicesJsonFiles.disallowChanges()
        dependsOn(validateMobileEnvironment)
    }
}
tasks.matching { it.name == "preBuild" || it.name.startsWith("compileFlutterBuild") }.configureEach {
    dependsOn(validateMobileEnvironment)
}

android {
    namespace = "com.trotxi.trotxi_driver"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Permanent once the listing exists: Play identifies the app by this
        // and it can never be changed afterwards.
        applicationId = "com.trotxi.trotxi_driver"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (signable) {
            create("upload") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig =
                signingConfigs.getByName(if (signable) "upload" else "debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
