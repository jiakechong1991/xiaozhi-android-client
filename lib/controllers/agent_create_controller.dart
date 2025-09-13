// lib/controllers/login_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ai_assistant/services/api_service.dart';

class CreateAgentController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final isLoading = false.obs; // 用于显示 loading
  final errorMessage = ''.obs; // 用于显示错误信息

  // 表单控制器
  final agentNameController = TextEditingController();
  final birthdayController = TextEditingController();
  final signatureController = TextEditingController();
  final hobbyController = TextEditingController();
  var sex = 'f'.obs;

  @override
  void onClose() {
    agentNameController.dispose();
    birthdayController.dispose();
    signatureController.dispose();
    hobbyController.dispose();
    super.onClose();
  }

  Future<void> create_agent() async {
    print(">>> create_agent 按钮被点击，开始创建agent");
    if (agentNameController.text.isEmpty || hobbyController.text.isEmpty) {
      errorMessage.value = "用户名或性格不能为空";
      return;
    }
    if (sex.value.isEmpty) {
      errorMessage.value = "请选择性别";
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _api.create_agent(
        agentNameController.text,
        sex.value,
        birthdayController.text,
        signatureController.text,
        hobbyController.text,
      );
      print("创建agent成功,要返回聊天界面了， 这里先用log代替");
      //Get.offAllNamed('/home');其实这里不需要，因为create_agent接口会返回创建的agent信息，所以可以直接跳转到home页面
    } catch (e) {
      errorMessage.value = e.toString().replaceAll("Exception: ", "");
    } finally {
      isLoading.value = false;
    }
  }
}
