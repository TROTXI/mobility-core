import java.util.Base64
import java.util.Properties
import org.gradle.api.file.DirectoryProperty
import org.gradle.api.tasks.OutputDirectory

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
val mobileAppDirectory = project.file("../..")
// Model sync/help may inspect provider inputs without Flutter definitions.
// Leave invalid selections empty; validateMobileEnvironment rejects them as
// a build dependency, before provider processing or compilation can run.
val mobileFirebaseFiles = providers.provider {
    val mobileValues = runCatching {
        mobileDefines.split(",").filter { it.isNotEmpty() }.associate {
            val pair = String(Base64.getDecoder().decode(it), Charsets.UTF_8)
            pair.substringBefore("=") to pair.substringAfter("=", "")
        }
    }.getOrDefault(emptyMap())
    val mobileEnvironment = mobileValues["APP_ENVIRONMENT"].orEmpty()
    val providerEnvironment = if (mobileEnvironment == "local") "staging" else mobileEnvironment
    if (providerEnvironment in listOf("staging", "production")) {
        listOf(project.file("../../config/$providerEnvironment/google-services.json"))
    } else {
        emptyList()
    }
}
val localProperties = Properties().apply {
    rootProject.file("local.properties").inputStream().use { load(it) }
}
val mobileBuildMode = if (
    gradle.startParameter.taskNames.any { it.contains("Debug", ignoreCase = true) } &&
    gradle.startParameter.taskNames.none { it.contains("Release", ignoreCase = true) || it.contains("Profile", ignoreCase = true) }
) "debug" else "release"
abstract class ValidateMobileEnvironmentTask : Exec() {
    @get:OutputDirectory
    abstract val receiptDirectory: DirectoryProperty
}

val validateMobileEnvironment = tasks.register<ValidateMobileEnvironmentTask>("validateMobileEnvironment") {
    receiptDirectory.set(layout.buildDirectory.dir("generated/mobile/assets"))
    // This is an authorization/configuration gate, not just a file generator.
    // Never skip it because a previous build already produced a receipt.
    outputs.upToDateWhen { false }
    environment("DART_DEFINES", mobileDefines)
    environment("MOBILE_BUILD_RECEIPT", receiptDirectory.file("trotxi_build.json").get().asFile)
    environment("MOBILE_BUILD_NUMBER", flutter.versionCode)
    environment("MOBILE_BUILD_NAME", flutter.versionName)
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
        googleServicesJsonFiles.set(mobileFirebaseFiles)
        googleServicesJsonFiles.disallowChanges()
        dependsOn(validateMobileEnvironment)
    }
}
tasks.matching { it.name == "preBuild" || it.name.startsWith("compileFlutterBuild") }.configureEach {
    dependsOn(validateMobileEnvironment)
}

android {
    namespace = "com.trotxi.trotxi_commuter"
    compileSdk = maxOf(36, flutter.compileSdkVersion)
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
        targetSdk = maxOf(36, flutter.targetSdkVersion)
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

}

// AGP 9 rejects Providers in the old SourceSet API. Register the producing
// task through the variant API so asset merging also depends on validation.
androidComponents.onVariants { variant ->
    variant.sources.assets?.addGeneratedSourceDirectory(
        validateMobileEnvironment, ValidateMobileEnvironmentTask::receiptDirectory
    )
}

apply(from = "../../../../tool/android-release.gradle")

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
