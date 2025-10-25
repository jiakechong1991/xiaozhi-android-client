// lib/controllers/login_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ai_assistant/services/api_service.dart';
import 'package:ai_assistant/controllers/agent_list_controller.dart';
import 'package:ai_assistant/models/conversation.dart';
import 'package:ai_assistant/controllers/config_controller.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:ai_assistant/screens/base/kit/index.dart';

class CreateAgentController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final isLoading = false.obs; // 用于显示 loading
  final errorMessage = ''.obs; // 用于显示错误信息
  final agnetListCtlIns = Get.find<AgentRoleListController>();
  final configControllerINs = Get.find<ConfigController>();
  final wcaoUtilsIns = Get.find<WcaoUtils>();

  // 表单控制器
  final agentNameController = TextEditingController();
  final birthdayController = TextEditingController();
  final characterSettingController = TextEditingController();
  final ageController = TextEditingController();
  var sex = 'f'.obs;
  var voices = "Chinese (Mandarin)_Soft_Girl".obs;

  // 音色映射：按性别分组
  static const Map<String, List<Map<String, String>>> _voiceOptions = {
    'f': [
      {'value': 'Chinese (Mandarin)_Soft_Girl', 'label': '柔和少女'},
      {'value': 'Chinese (Mandarin)_BashfulGirl', 'label': '害羞少女'},
    ],
    'm': [
      {'value': 'Chinese (Mandarin)_Pure-hearted_Boy', 'label': '纯真男孩'},
      {'value': 'Chinese (Mandarin)_Stubborn_Friend', 'label': '倔强男友'},
    ],
  };

  // 👇 新增：头像图片文件（可选）
  var avatarFile = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> getDefaultAvatar() async {
    final randomUrl = WcaoUtils.getRandomImage();
    // final randomUrl = await _api.randomAvatarImg(sex.value);
    File? imageFile = await wcaoUtilsIns.downloadAndCache(randomUrl);
    if (imageFile != null) {
      setAvatar(File(imageFile.path));
    }
  }

  // 更新头像
  void setAvatar(File? file) {
    avatarFile.value = file;
    // update(); // 触发 Obx 刷新 UI
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
    // update();
  }

  // 根据当前性别获取可用音色列表
  List<Map<String, String>> get availableVoices {
    return _voiceOptions[sex.value] ?? _voiceOptions['f']!;
  }

  // 当性别改变时，自动更新 voices 为该性别下的第一个选项
  void onSexChanged(String newSex) {
    if (newSex != sex.value) {
      sex.value = newSex;
      final firstVoice = availableVoices.first['value']!;
      voices.value = firstVoice;
    }
  }

  @override
  void onClose() {
    agentNameController.dispose();
    birthdayController.dispose();
    characterSettingController.dispose();
    ageController.dispose();
    super.onClose();
  }

  Future<void> create_agent() async {
    print(">>> create_agent 按钮被点击，开始创建agent");
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
      final newAgentRole = await agnetListCtlIns.createAgentRole(
        agentName: agentNameController.text,
        sex: sex.value,
        birthday: birthdayController.text,
        characterSetting: characterSettingController.text,
        age: ageController.text,
        voices: voices.value,
        avatarFile: avatarFile.value,
      );
      // 带参数回到home列表， 后续改成
      Get.offAndToNamed('/home');
      print(">>> 创建agent成功end");
    } catch (e, stackTrace) {
      print(">>> 创建agent失败");
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
