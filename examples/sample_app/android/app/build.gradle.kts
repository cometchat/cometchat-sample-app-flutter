plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

configurations.all {
    resolutionStrategy {
        // Force AndroidX instead of support library
        force("androidx.core:core:1.17.0")
    }
    // Exclude old support library
    exclude(group = "com.android.support", module = "support-compat")
    exclude(group = "com.android.support", module = "support-v4")
}

android {
    namespace = "com.cometchat.sampleapp.flutter.android"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.cometchat.sampleapp.flutter.android"
        minSdk = 26
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
        // Flutter creates a 'profile' build type. cometchat_calls_sdk pulls in
        // React Native deps that only publish 'debug'/'release' variants.
        // configureEach runs during evaluation so matchingFallbacks isn't locked yet.
        configureEach {
            if (name == "profile") {
                matchingFallbacks += listOf("release")
            }
        }
    }
}

// androidx.activity 1.13.0's ComponentActivity implements
// androidx.core.app.PictureInPictureProvider, an interface that does not exist
// in androidx.core 1.17.0 — the version this app resolves. The result is that
// ComponentActivity (and therefore FragmentActivity) cannot be loaded at
// runtime: the classes are in the APK, but resolving them throws
// NoClassDefFoundError the moment the Calls SDK's React Native view touches
// them, which kills the app on answering a call.
//
// master_app resolves activity 1.12.4 and is unaffected. Pin to the same
// version. Gradle otherwise picks the highest, so this must be forced.
configurations.all {
    resolutionStrategy {
        force("androidx.activity:activity:1.12.4")
        force("androidx.activity:activity-ktx:1.12.4")
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
