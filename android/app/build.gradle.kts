plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}


// 签名配置加载
import java.io.FileInputStream
import java.util.Properties

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        load(keystorePropertiesFile.inputStream())
    }
}


android {
    namespace = "com.lhht.ai_assistant"  
    compileSdk = flutter.compileSdkVersion // flutter版本
    ndkVersion = "27.0.12077973" //ndk版本 

    // Java编译选项
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11 // Java源代码兼容版本（JDK 11）
        targetCompatibility = JavaVersion.VERSION_11 // 编译后的字节码兼容版本（JDK 11）
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.lhht.ai_assistant" //app包名
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24  // 最低支持的 Android 版本
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // ndk {
        //     // 选择要添加的对应 cpu 类型的 .so 库。
        //     abiFilters 'armeabi', 'armeabi-v7a', 'arm64-v8a',
        // }
        // 新增JPush占位符
        manifestPlaceholders["JPUSH_PKGNAME"] = "com.lhht.ai_assistant"
        manifestPlaceholders["JPUSH_APPKEY"] = "429e098ff4eabb22f780efd0"
        manifestPlaceholders["JPUSH_CHANNEL"] = "default_developer"
        // manifestPlaceholders = [
        //     // 设置manifest.xml中的变量
        //     JPUSH_PKGNAME: applicationId,
        //     JPUSH_APPKEY : "429e098ff4eabb22f780efd0", //  JPush 上注册的包名对应的 Appkey
        //     JPUSH_CHANNEL: "default_developer", //暂时填写默认值即可
        // ]
    }

    //签名配置
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String? ?: "my-key-alias"
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = file(keystoreProperties["storeFile"] as String? ?: "")
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }
    // 构建配置
    buildTypes {
        release { // 正式发布版本的配置
            // 指定 release 版本使用的签名配置为之前定义的release签名配置
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true // 启用代码混淆和压缩
            isDebuggable = false // 关闭 release 版本的调试模式
            isShrinkResources = true  // 启用 压缩资源
            // 指定混淆规则文件的路径
            proguardFiles(
                // 默认的混淆规则文件
                getDefaultProguardFile("proguard-android-optimize.txt"), 
                // 自定义的混淆规则文件
                "proguard-rules.pro"
            )
        }
        
        debug { // 调试版本的配置
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
