plugins {
    id("com.android.application")
<<<<<<< HEAD
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.exampro"
    compileSdk = flutter.compileSdkVersion
=======
    id("org.jetbrains.kotlin.android") // instead of kotlin-android, if needed
    id("dev.flutter.flutter-gradle-plugin")
}


android {
    namespace = "com.zenovtech.citizentest"
    compileSdk = 36
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
<<<<<<< HEAD
=======

        isCoreLibraryDesugaringEnabled = true
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
<<<<<<< HEAD

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.exampro"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
=======
    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.zenovtech.citizentest"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
<<<<<<< HEAD
=======

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
