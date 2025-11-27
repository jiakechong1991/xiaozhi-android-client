plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}


// 添加这两行导入
import java.io.FileInputStream
import java.util.Properties

// 修改后的属性加载代码
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        // 使用 Kotlin 的 inputStream() 扩展函数替代 FileInputStream
        load(keystorePropertiesFile.inputStream())
    }
}


android {
    namespace = "com.lhht.ai_assistant"  //app包名
    compileSdk = flutter.compileSdkVersion
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
        applicationId = "com.lhht.ai_assistant"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    //新增的签名代码
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String? ?: "my-key-alias"
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = file(keystoreProperties["storeFile"] as String? ?: "")
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("release")
            //signingConfig = signingConfigs.getByName("debug")
            // 启用R8优化
            isMinifyEnabled = true 
            isDebuggable = false
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        
        debug {
            // 启用更好的调试性能
            isMinifyEnabled = false
            isShrinkResources = false
            isDebuggable = true
        }
    }

}

flutter {
    source = "../.."
}
