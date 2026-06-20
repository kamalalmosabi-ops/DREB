plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
    
    // سطر الفايربيس الخاص بنا
    id("com.google.gms.google-services")
    id("kotlin-android")
    
}

android {
    namespace = "com.example.darb"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // السطر الجديد لتفعيل ميزة Desugaring
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.darb"
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

flutter {
    source = "../.."
}

dependencies {
    // السطر الجديد لجلب مكتبة Desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // استيراد الحزمة الأساسية للفايربيس
    implementation(platform("com.google.firebase:firebase-bom:34.13.0"))
    
    // استيراد مكتبة التحليلات 
    implementation("com.google.firebase:firebase-analytics")
}