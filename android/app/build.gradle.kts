plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Direct Flutter and IDE builds do not go through tool/flutter_versioned.sh.
// Embed the checkout identity in Android packages as well.
fun gitOutput(vararg arguments: String): String? = try {
    val result = providers.exec {
        workingDir(rootProject.projectDir.parentFile)
        commandLine("git", *arguments)
        isIgnoreExitValue = true
    }
    if (result.result.get().exitValue == 0) result.standardOutput.asText.get().trim()
        .takeIf { it.isNotEmpty() } else null
} catch (_: Exception) {
    null
}

val debugGitDescription = gitOutput(
    "describe", "--tags", "--always", "--dirty", "--match", "v[0-9]*", "--match", "[0-9]*"
)
val debugGitBuildNumber = gitOutput("rev-list", "--count", "HEAD")
    ?.toIntOrNull()?.takeIf { it in 1..2100000000 }
val pubspecVersion = Regex("(?m)^version:\\s*([^\\s#]+)")
    .find(rootProject.projectDir.parentFile.resolve("pubspec.yaml").readText())
    ?.groupValues?.get(1)?.split("+", limit = 2)
val pubspecVersionName = pubspecVersion?.getOrNull(0)
val pubspecVersionCode = pubspecVersion?.getOrNull(1)?.toIntOrNull()
val releaseGitDescription = debugGitDescription?.removePrefix("v")
val releaseBuildNumber = providers.environmentVariable("LUMADRIVE_BUILD_NUMBER").orNull
    ?.toIntOrNull()?.takeIf { it in 1..2100000000 }

android {
    namespace = "com.lumadrive.lumadrive_control"
    compileSdk = 37 //- flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.lumadrive.lumadrive_control"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
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

androidComponents {
    onVariants(selector().withBuildType("debug")) { variant ->
        variant.outputs.forEach { output ->
            debugGitDescription?.let { output.versionName.set(it) }
            debugGitBuildNumber?.let { output.versionCode.set(it) }
        }
    }
    onVariants(selector().withBuildType("release")) { variant ->
        variant.outputs.forEach { output ->
            // Flutter passes pubspec defaults even when no override was supplied.
            // Preserve explicit non-default --build-name/--build-number values.
            if (flutter.versionName == pubspecVersionName) {
                releaseGitDescription?.let { output.versionName.set(it) }
            }
            if (flutter.versionCode == pubspecVersionCode) {
                (releaseBuildNumber ?: debugGitBuildNumber)?.let { output.versionCode.set(it) }
            }
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
