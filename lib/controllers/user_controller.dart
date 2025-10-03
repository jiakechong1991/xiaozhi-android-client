// lib/controllers/login_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ai_assistant/services/api_service.dart';
import 'package:ai_assistant/controllers/conversation_controller.dart';
import 'package:ai_assistant/controllers/config_controller.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:ai_assistant/screens/base/kit/index.dart';

class UserController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final isLoading = false.obs; // 用于显示 loading
  final errorMessage = ''.obs; // 用于显示错误信息
  final conversationControllerIns = Get.find<ConversationController>();
  final configControllerINs = Get.find<ConfigController>();
  final wcaoUtilsIns = Get.find<WcaoUtils>();

  // 表单控制器
  final agentNameController = TextEditingController();
  final birthdayController = TextEditingController();
  final characterSettingController = TextEditingController();
  final ageController = TextEditingController();
  var sex = 'f'.obs;

  // 👇 新增：头像图片文件（可选）
  var avatarFile = Rx<File?>(null);
  // 更新头像
  void setAvatar(File? file) {
    avatarFile.value = file;
    // update(); // 触发 Obx 刷新 UI
  }

  Future<void> getDefaultAvatar() async {
    print("----开始异步获取头像图片");
    final randomUrl = WcaoUtils.getRandomImage();
    File? imageFile = await wcaoUtilsIns.downloadAndCache(randomUrl);
    if (imageFile != null) {
      setAvatar(File(imageFile.path));
      print("----异步设置头像完成");
    }
  }

  // 从相册或相机选择图片
  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      setAvatar(File(image.path));
    }
  }

  // 清除头像
  void clearAvatar() {
    avatarFile.value = null;
  }

  @override
  void onClose() {
    agentNameController.dispose();
    birthdayController.dispose();
    characterSettingController.dispose();
    ageController.dispose();
    super.onClose();
  }

  void onSexChanged(String newSex) {
    if (newSex != sex.value) {
      sex.value = newSex;
    }
  }

  Future<void> update_user_profile() async {
    print(">>>按钮被点击，开始更新update_user_profile");
    if (agentNameController.text.isEmpty ||
        characterSettingController.text.isEmpty) {
      errorMessage.value = "用户名或设定不能为空";
      return;
    }
    if (sex.value.isEmpty) {
      errorMessage.value = "请选择性别";
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final responseData = await _api.updateUserProfile(
        agentNameController.text,
        sex.value,
        birthdayController.text,
        characterSettingController.text,
        ageController.text,
        avatarFile.value!, // 👈 新增
      );
      print("更新user profile 成功,要返回聊天界面了， 这里先用log代替");
      //回到 聊天界面
      Get.offAllNamed('/home');
    } catch (e, stackTrace) {
      print(">>> 更新user profile失败");
      print("错误信息: $e");
      print("完整堆栈:");
      print(stackTrace); //
      print("----");
      errorMessage.value = e.toString().replaceAll("Exception: ", "").trim();
      print(errorMessage);
      // 打印错误信息
    } finally {
      isLoading.value = false;
    }
  }
}
