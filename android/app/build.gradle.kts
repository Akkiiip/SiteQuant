import java.util.Properties

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val debugAdMobAppId = "ca-app-pub-3940256099942544~3347511713"
val releaseAdMobAppId = providers.gradleProperty("ADMOB_APP_ID")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use(keystoreProperties::load)
}

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.sitequant.app"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.sitequant.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = rootProject.file(keystoreProperties.getProperty("storeFile"))
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        debug {
            manifestPlaceholders["admobAppId"] = debugAdMobAppId
        }
        release {
            proguardFiles("proguard-rules.pro")
            // Supply the production AdMob app ID with -PADMOB_APP_ID=ca-app-pub-...~...
            // The test ID is only a fallback so non-release Gradle configuration remains valid.
            manifestPlaceholders["admobAppId"] =
                releaseAdMobAppId.orNull ?: debugAdMobAppId
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

tasks.configureEach {
    if (name == "preReleaseBuild") {
        doFirst {
            check(!releaseAdMobAppId.orNull.isNullOrBlank()) {
                "Missing production AdMob app ID. Build with -PADMOB_APP_ID=ca-app-pub-...~..."
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
