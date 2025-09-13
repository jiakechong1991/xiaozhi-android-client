import 'package:get/get.dart';
import 'package:ai_assistant/screens/home_screen.dart';
import 'package:ai_assistant/screens/login/login_password.dart';
import 'package:ai_assistant/screens/login/register.dart';
import 'package:ai_assistant/screens/conversation_create.dart';

import 'package:ai_assistant/screens/test_screen.dart';
import 'package:ai_assistant/screens/agreement/privacy.dart';
import 'package:ai_assistant/screens/agreement/user.dart';

List<GetPage<dynamic>> getRoutes = [
  GetPage(name: '/home', page: () => const HomeScreen()),
  GetPage(name: '/test', page: () => const TestScreen()),

  // 登录注册权限相关
  GetPage(name: '/login/password', page: () => const LoginPassword()),
  GetPage(name: '/login/register', page: () => const LoginRegister()),
  //GetPage(name: '/verify-code/:type', page: () => const VerifyCode()),
  //GetPage(name: '/password/reset', page: () => const PasswordReset()),
  //GetPage(name: '/password/update', page: () => const PasswordUpdate()),
  // 登录注册时的安全协议
  GetPage(name: '/agreement/user', page: () => const AgreementUser()),
  GetPage(name: '/agreement/privacy', page: () => const AgreementPrivacy()),

  // 聊天相关
  // 创建agent
  GetPage(name: '/agent/create', page: () => const ConversationTypeCreate()),
];
