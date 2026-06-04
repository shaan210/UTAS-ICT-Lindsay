plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
    id "com.google.gms.google-services"
}

android {
    namespace = "com.salesinterior.app"
    compileSdk = 34
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    defaultConfig {
        applicationId = "com.salesinterior.app"
        minSdkVersion = 24
        targetSdkVersion = 34
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.debug
        }
    }
}

flutter {
    source = "../../../.."
}

dependencies {
    implementation 'com.google.firebase:firebase-core:32.7.3'
    implementation 'com.google.firebase:firebase-analytics:21.6.2'
    implementation 'com.google.firebase:firebase-firestore:24.11.1'
}
