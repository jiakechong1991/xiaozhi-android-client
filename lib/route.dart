import 'package:get/get.dart';
import 'package:ai_assistant/screens/home_screen.dart';
import 'package:ai_assistant/screens/login/password.dart';
import 'package:ai_assistant/screens/login/register.dart';

import 'package:ai_assistant/screens/test_screen.dart';
import 'package:ai_assistant/screens/agreement/privacy.dart';
import 'package:ai_assistant/screens/agreement/user.dart';

List<GetPage<dynamic>> getRoutes = [
  GetPage(name: '/home', page: () => const HomeScreen()),
  GetPage(name: '/test', page: () => const TestScreen()),
  GetPage(name: '/login/password', page: () => const LoginPassword()),
  GetPage(name: '/login/register', page: () => const LoginRegister()),

  //GetPage(name: '/verify-code/:type', page: () => const VerifyCode()),
  //GetPage(name: '/password/reset', page: () => const PasswordReset()),
  //GetPage(name: '/password/update', page: () => const PasswordUpdate()),
  GetPage(name: '/agreement/user', page: () => const AgreementUser()),
  GetPage(name: '/agreement/privacy', page: () => const AgreementPrivacy()),
];
