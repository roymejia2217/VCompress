plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.rjmejia.vcompressor"
    compileSdk = flutter.compileSdkVersion
    // Fijamos NDK 27 para compatibilidad con varios plugins (ffmpeg_kit, file_picker, etc.)
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.rjmejia.vcompressor"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // ffmpeg-kit requires minSdk 24+
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // ✅ Optimización: Solo ARM64 para maximizar reducción de tamaño (ARMv7 menos del 3% en 2025)
        ndk {
            abiFilters.addAll(listOf("arm64-v8a"))
        }
    }

    signingConfigs {
        create("release") {
            storeFile = file("upload-keystore.jks")
            storePassword = "android"
            keyAlias = "upload"
            keyPassword = "android"
        }
    }

    packagingOptions {
        // Excluir arquitecturas no-arm64 que trae ffmpeg_kit (ignora abiFilters)
        exclude("lib/armeabi-v7a/**")
        exclude("lib/x86/**")
        exclude("lib/x86_64/**")
    }

    buildTypes {
        release {
            // Configure proper release signing
            // Create keystore with: keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
            signingConfig = signingConfigs.getByName("release")
            // SOLUCIÓN DEFINITIVA: Sin minificación para evitar crashes
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        debug {
            isDebuggable = true
            applicationIdSuffix = ".debug"
        }
    }
}

flutter {
    source = "../.."
}

configurations.all {
    exclude(group = "com.google.android.play", module = "core")
}
