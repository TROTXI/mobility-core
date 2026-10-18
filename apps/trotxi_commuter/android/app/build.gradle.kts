import java.util.Base64
import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
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
    namespace = "com.trotxi.trotxi_commuter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.trotxi.trotxi_commuter"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
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
