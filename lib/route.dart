import 'package:get/get.dart';
import 'package:ai_assistant/screens/home_screen.dart';
import 'package:ai_assistant/screens/login/login_password.dart';
import 'package:ai_assistant/screens/login/register.dart';
import 'package:ai_assistant/screens/conversation_create.dart';
import 'package:ai_assistant/models/conversation.dart';

import 'package:ai_assistant/screens/agreement/privacy.dart';
import 'package:ai_assistant/screens/agreement/user.dart';
import 'package:ai_assistant/screens/chat_screen.dart';

import 'package:ai_assistant/screens/settings/index.dart';
import 'package:ai_assistant/screens/settings/account/index.dart';
import 'package:ai_assistant/screens/settings/account/update_phone.dart';
import 'package:ai_assistant/screens/settings/account/update_phone2.dart';
import 'package:ai_assistant/screens/settings/account/account_cancellation.dart';
import 'package:ai_assistant/screens/settings/notification/index.dart';
import 'package:ai_assistant/screens/settings/about/index.dart';
import 'package:ai_assistant/screens/settings/backlist/index.dart';
import 'package:ai_assistant/screens/settings/privacy/index.dart';
import 'package:ai_assistant/screens/userprofile_create.dart';

List<GetPage<dynamic>> getRoutes = [
  GetPage(name: '/home', page: () => const HomeScreen()),

  // 登录注册权限相关
  GetPage(name: '/login/password', page: () => const LoginPassword()),
  GetPage(name: '/login/register', page: () => const LoginRegister()),
  GetPage(name: '/user/update_profile', page: () => const UserprofileCreate()),
  //GetPage(name: '/verify-code/:type', page: () => const VerifyCode()),
  //GetPage(name: '/password/reset', page: () => const PasswordReset()),
  //GetPage(name: '/password/update', page: () => const PasswordUpdate()),

  // settting系列路由
  GetPage(name: '/settings', page: () => const Settings()),
  GetPage(name: '/settings/account', page: () => const SettingsAccount()),
  GetPage(
    name: '/settings/account/update-phone',
    page: () => const AccountUpdatePhone(),
  ),
  GetPage(
    name: '/settings/account/update-phone2',
    page: () => const AccountUpdatePhone2(),
  ),
  // 注销账户
  GetPage(
    name: '/settings/account/cancellation',
    page: () => const AccountCancellation(),
  ),
  GetPage(
    name: '/settings/notification',
    page: () => const SettingsNotification(),
  ),
  GetPage(name: '/settings/privacy', page: () => const SettingsPrivacy()),
  GetPage(name: '/settings/backlist', page: () => const SettingsBacklist()),
  GetPage(name: '/settings/about', page: () => const SettingsAbout()),

  // 登录注册时的安全协议
  GetPage(name: '/agreement/user', page: () => const AgreementUser()),
  GetPage(name: '/agreement/privacy', page: () => const AgreementPrivacy()),

  // 聊天相关
  // 创建agent
  GetPage(name: '/agent/create', page: () => const ConversationTypeCreate()),
  GetPage(
    name: '/agent/chatlist',
    page: () {
      // 从 Get.arguments 中获取参数
      final conversation = Get.arguments as GroupChat;
      return ChatScreen(groupConversation: conversation);
    },
  ),
];
