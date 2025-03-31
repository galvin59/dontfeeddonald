import java.io.File
import java.util.*

val keystoreProperties =
    Properties().apply {
        var file = File("key.properties")
        if (file.exists()) load(file.reader())
    }

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "net.saumande.dont_feed_donald"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "26.3.11579264"

    val appVersionCode = (System.getenv()["NEW_BUILD_NUMBER"] ?: "1")?.toInt()

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "net.saumande.dont_feed_donald"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = appVersionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (System.getenv()["CI"].toBoolean()) { // CI=true is exported by Codemagic
                storeFile = file(System.getenv()["CM_KEYSTORE_PATH"])
                storePassword = System.getenv()["CM_KEYSTORE_PASSWORD"]
                keyAlias = System.getenv()["CM_KEY_ALIAS"]
                keyPassword = System.getenv()["CM_KEY_PASSWORD"]
            } else {
                val localStoreFile = keystoreProperties.getProperty("storeFile")
                if (localStoreFile != null && localStoreFile.isNotEmpty()) {
                     println("Local release signing configured using key.properties.")
                     storeFile = file(localStoreFile)
                     storePassword = keystoreProperties.getProperty("storePassword")
                     keyAlias = keystoreProperties.getProperty("keyAlias")
                     keyPassword = keystoreProperties.getProperty("keyPassword")
                } else {
                    println("Warning: 'storeFile' not found in key.properties. Local release builds will not be signed with the release key.")
                }
            }
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            signingConfig = signingConfigs.findByName("release")
        }
    }
}

flutter {
    source = "../.."
}
