// lib/controllers/login_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ai_assistant/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:ai_assistant/controllers/conversation_controller.dart';
import 'package:ai_assistant/models/conversation.dart';
import 'package:ai_assistant/controllers/config_controller.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CreateAgentController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final isLoading = false.obs; // 用于显示 loading
  final errorMessage = ''.obs; // 用于显示错误信息
  final conversationController_ins = Get.find<ConversationController>();
  final configControllerINs = Get.find<ConfigController>();
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
      final responseData = await _api.create_agent(
        agentNameController.text,
        sex.value,
        birthdayController.text,
        characterSettingController.text,
        ageController.text,
        voices.value,
        avatarFile.value, // 👈 新增
      );
      print("创建agent成功,要返回聊天界面了， 这里先用log代替");
      //回到 聊天界面
      String? agentId = responseData['id']?.toString();
      String agentName = responseData['agent_name'];

      // ✅ 使用 Get.context 获取 context
      final context = Get.context;
      if (context == null) {
        throw Exception('Context is not available');
      }
      final xiaozhiConfigs = configControllerINs.xiaozhiConfigs;

      print('=== 调试：创建 Agent 的入参 ===');
      print('✅ agentName: "${agentName}"');
      print('✅ agentId: "${agentId}"');
      print('✅ sex: ${xiaozhiConfigs.first.id!}');
      print('=================================');

      final conversation = await conversationController_ins.createConversation(
        title: '与 ${agentName} 的对话',
        agentId: agentId!,
        type: ConversationType.xiaozhi,
        configId: xiaozhiConfigs.first.id!, // 默认使用第一个小智server
      );
      // 带参数跳转到聊天列表界面
      Get.offAllNamed('/agent/chatlist', arguments: conversation);
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
