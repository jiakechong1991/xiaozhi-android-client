// lib/controllers/login_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ai_assistant/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_assistant/screens/base/kit/index.dart';

class LoginController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final isLoading = false.obs; // 用于显示 loading
  final errorMessage = ''.obs; // 用于显示错误信息

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> loadSavedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('saved_username');
    if (savedUsername != null && savedUsername.isNotEmpty) {
      usernameController.text = savedUsername;
      // 可选：自动聚焦到密码框
      FocusScope.of(Get.context!).requestFocus(FocusNode());
    }
  }

  Future<void> login() async {
    print(">>> 登录按钮被点击，开始登录流程");
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      errorMessage.value = "用户名或密码不能为空";
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _api.login(
        usernameController.text,
        passwordController.text,
      );

      if (response["code"] != 0) {
        WcaoUtils.toast("登录失败: ${response['message']}");
      } else {
        // 保存用户名，方便输入
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_username', usernameController.text);
        Get.offAllNamed('/home');
      }
    } catch (e) {
      print("登录错误了");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    print(">>> 退出按钮被点击，开始退出流程");

    try {
      await _api.logout();
    } catch (e) {
      print("logout失败");
    }
  }
}
