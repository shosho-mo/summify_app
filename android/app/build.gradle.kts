import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// 1. قراءة ملف الخصائص
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.summify"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    // 2. إعداد التوقيع الذكي
    signingConfigs {
        create("release") {
            // محاولة القراءة من النظام أولاً (GitHub Actions)، ثم من الملف المحلي
            keyAlias = System.getenv("KEY_ALIAS") ?: keystoreProperties.getProperty("keyAlias")
            keyPassword = System.getenv("KEY_PASSWORD") ?: keystoreProperties.getProperty("keyPassword")
            storePassword = System.getenv("STORE_PASSWORD") ?: keystoreProperties.getProperty("storePassword")
            
            // تحديد مسار الـ Keystore
            val storeFileProperty = System.getenv("STORE_FILE") ?: keystoreProperties.getProperty("storeFile")
            if (storeFileProperty != null) {
                storeFile = file(storeFileProperty)
            }
        }
    }

    defaultConfig {
        applicationId = "com.example.summify"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}