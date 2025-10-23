// lib/controllers/login_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ai_assistant/services/api_service.dart';
import 'package:ai_assistant/controllers/group_list_controller.dart';
import 'package:ai_assistant/controllers/config_controller.dart';
import 'package:ai_assistant/screens/base/kit/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final isLoading = false.obs; // 用于显示 loading
  final errorMessage = ''.obs; // 用于显示错误信息
  final configControllerINs = Get.find<ConfigController>();
  final wcaoUtilsIns = Get.find<WcaoUtils>();

  // 表单控制器
  final userNameCtl = TextEditingController();
  final passwordCtl = TextEditingController();
  final password2Ctl = TextEditingController();
  final verificationCodeCtl = TextEditingController();
  final phoneCtl = TextEditingController();

  @override
  void onClose() {
    userNameCtl.dispose();
    passwordCtl.dispose();
    password2Ctl.dispose();
    verificationCodeCtl.dispose();
    phoneCtl.dispose();
    super.onClose();
  }

  Future<void> registerUser() async {
    print(">>>按钮被点击，开始registerUser");
    if (userNameCtl.text.isEmpty ||
        passwordCtl.text.isEmpty ||
        password2Ctl.text.isEmpty) {
      errorMessage.value = "用户名或者密码不能为空";
      return;
    }
    if (passwordCtl.text != password2Ctl.text) {
      errorMessage.value = "两次密码不相同";
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final responseData = await _api.registerUser(
        userNameCtl.text,
        phoneCtl.text,
        passwordCtl.text,
        password2Ctl.text,
        verificationCodeCtl.text,
      );
      if (responseData["code"] == 0) {
        print("账户创建成功");
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_username', userNameCtl.text);

        Get.offAllNamed('/login/password');
      } else {
        print("账户创建失败");
        print(responseData["message"]);
        WcaoUtils.toast("注册失败：${responseData["message"]}");
      }
      //回到 聊天界面
    } catch (e, stackTrace) {
      print(">>> 创建账户 失败");
      print("完整堆栈:");
      print(stackTrace); //
      // 打印错误信息
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getVerificationCode() async {
    print(">>>按钮被点击，开始获取验证码");
    if (phoneCtl.text.isEmpty || password2Ctl.text.isEmpty) {
      errorMessage.value = "请填写信息完整再获取验证码";
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final responseData = await _api.sendCode(phoneCtl.text);
      WcaoUtils.toast("验证码获取成功");
      //回到 聊天界面
    } catch (e, stackTrace) {
      WcaoUtils.toast("验证码获取失败");
      print(">>> 验证码获取失败");
      print("完整堆栈:");
      print(stackTrace); //
      errorMessage.value = e.toString().replaceAll("Exception: ", "").trim();
      // 打印错误信息
    } finally {
      isLoading.value = false;
    }
  }
}
