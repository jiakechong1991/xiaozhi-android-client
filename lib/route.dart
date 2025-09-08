import 'package:get/get.dart';
import 'package:ai_assistant/screens/home_screen.dart';
import 'package:ai_assistant/screens/login/password.dart';
import 'package:ai_assistant/screens/test_screen.dart';

List<GetPage<dynamic>> getRoutes = [
  GetPage(name: '/home', page: () => const HomeScreen()),
  GetPage(name: '/test', page: () => const TestScreen()),
  GetPage(name: '/login/password', page: () => const LoginPassword()),

  //GetPage(name: '/verify-code/:type', page: () => const VerifyCode()),
  //GetPage(name: '/password/reset', page: () => const PasswordReset()),
  //GetPage(name: '/password/update', page: () => const PasswordUpdate()),
];
