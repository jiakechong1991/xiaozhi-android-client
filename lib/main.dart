import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:ai_assistant/controllers/theme_controller.dart';
import 'package:ai_assistant/controllers/config_controller.dart';
import 'package:ai_assistant/controllers/group_list_controller.dart';
import 'package:ai_assistant/controllers/agent_list_controller.dart';
import 'package:ai_assistant/utils/app_theme.dart';
import 'package:ai_assistant/route.dart';
import 'package:ai_assistant/state/token.dart';
import 'package:ai_assistant/services/api_service.dart';
import 'package:opus_flutter/opus_flutter.dart' as opus_flutter;
import 'package:opus_dart/opus_dart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:ui';
import 'package:ai_assistant/utils/audio_util.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:get/get.dart';
import 'package:ai_assistant/controllers/login_controller.dart';
import 'package:ai_assistant/controllers/user_controller.dart';
import 'package:ai_assistant/controllers/agent_create_controller.dart';
import 'package:ai_assistant/controllers/group_create_controller.dart';
import 'package:ai_assistant/controllers/register_controller.dart';
import 'package:ai_assistant/screens/base/kit/index.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ai_assistant/controllers/check_profile_controller.dart';
import 'package:ai_assistant/screens/consume/account_about_controller.dart';
import 'package:ai_assistant/utils/time_util.dart';
import 'package:ai_assistant/screens/chat/mac_setting_controller.dart';

// 是否启用调试工具
const bool enableDebugTools = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 设置全局沉浸式导航栏
  await _setupSystemUI();

  // 设置状态栏颜色变化监听器，确保状态栏样式始终如一
  SystemChannels.lifecycle.setMessageHandler((msg) async {
    if (msg == AppLifecycleState.resumed.toString()) {
      // 应用回到前台时重新应用系统UI设置
      await _setupSystemUI();
    }
    return null;
  });

  // 设置高性能渲染
  if (Platform.isAndroid || Platform.isIOS) {
    // 启用SkSL预热，提高首次渲染性能
    await Future.delayed(const Duration(milliseconds: 50));
    PaintingBinding.instance.imageCache.maximumSize = 1000;
    // 增加图像缓存容量
    PaintingBinding.instance.imageCache.maximumSizeBytes =
        100 * 1024 * 1024; // 100 MB
  }

  // 请求录音和存储权限
  await [
    Permission.microphone,
    Permission.storage,
    if (Platform.isAndroid) Permission.bluetoothConnect,
  ].request();

  // 添加中文本地化支持
  //
  timeago.setLocaleMessages('zh', timeago.ZhMessages());
  timeago.setDefaultLocale('zh');

  // 在Android上设置高刷新率
  if (Platform.isAndroid) {
    try {
      // 获取所有支持的显示模式
      final modes = await FlutterDisplayMode.supported;
      print('支持的显示模式: ${modes.length}');
      modes.forEach((mode) => print('模式: $mode'));

      // 获取当前活跃的模式
      final current = await FlutterDisplayMode.active;
      print('当前模式: $current');

      // 设置为高刷新率模式
      await FlutterDisplayMode.setHighRefreshRate();

      // 确认设置成功
      final afterSet = await FlutterDisplayMode.active;
      print('设置后模式: $afterSet');
    } catch (e) {
      print('设置高刷新率失败: $e');
    }
  }

  // 初始化Opus库
  try {
    initOpus(await opus_flutter.load());
    print('Opus初始化成功: ${getOpusVersion()}');
  } catch (e) {
    print('Opus初始化失败: $e');
  }

  // 初始化录音和播放器
  try {
    await AudioUtil.initRecorder();
    await AudioUtil.initPlayer();
    print('音频系统初始化成功!');
  } catch (e) {
    print('音频系统初始化失败: $e');
  }

  // 初始化配置管理
  Get.put(ConfigController());

  final tokenController = TokenController();
  await tokenController.loadToken(); // 异步加载，阻塞直到完成
  // 将 TokenController 注册为单例（GetX 需要）
  Get.put(tokenController);

  // 初始化并注入全局服务
  await Get.putAsync<WcaoUtils>(() => WcaoUtils().init());
  // 启动app时，获得app的时区
  await TimeUtil.getDeviceTimeZoneId();

  Get.put(ApiService()); // ApiService 无异步构造函数时
  Get.put(ThemeController());

  Get.lazyPut(() => RegisterController(), fenix: true);
  Get.lazyPut(() => GroupListController(), fenix: true);
  Get.lazyPut(() => AgentRoleListController(), fenix: true);
  Get.lazyPut(() => UserController(), fenix: true);
  //LoginController中有页面操作，必须延迟初始化
  Get.put(LoginController());
  Get.lazyPut(() => CreateAgentController(), fenix: true);
  Get.lazyPut(() => CreateGroupController(), fenix: true);

  Get.lazyPut(() => CheckProfileController(), fenix: true);
  Get.lazyPut(() => AccountAboutPageController(), fenix: true);
  Get.lazyPut(() => MacSettingController(), fenix: true);

  /*
  flutters
   */
  runApp(const MyApp());
}

// 设置系统UI沉浸式效果
Future<void> _setupSystemUI() async {
  // 设置状态栏和导航栏透明
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  if (Platform.isAndroid) {
    // 启用边缘到边缘显示模式，实现真正的全面屏效果
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  } else if (Platform.isIOS) {
    // iOS上设置为全屏显示但保留状态栏
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeControllerIns = Get.find<ThemeController>();

    return GetMaterialApp(
      //
      title: '小狮陪伴', // app名称
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeControllerIns.themeMode,
      initialRoute: _getInitialRoute(), // 让函数动态确定初始页面
      //在 GetMaterialApp 中，你应该使用 getPages 来定义路由表 —— 它是 GetX 专属、功能更强、更推荐的方式
      getPages: getRoutes,
      builder: EasyLoading.init(),
      // 添加平滑滚动设置
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        // 启用物理滚动
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        // 确保所有平台都有滚动条和弹性效果
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
      ),
    );
  }

  String _getInitialRoute() {
    return TokenController.to.token.value.isNotEmpty
        ? '/home'
        : '/login/password'; // 登录页面
  }
}
