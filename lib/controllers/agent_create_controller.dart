// lib/controllers/login_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ai_assistant/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:ai_assistant/providers/conversation_provider.dart';
import 'package:ai_assistant/models/conversation.dart';

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
      final responseData = await _api.create_agent(
        agentNameController.text,
        sex.value,
        birthdayController.text,
        signatureController.text,
        hobbyController.text,
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

      final conversation = await Provider.of<ConversationProvider>(
        context,
        listen: false,
      ).createConversation(
        title: '与 ${agentName} 的对话',
        type: ConversationType.xiaozhi,
        configId: agentId!,
      );
      // 带参数跳转到聊天列表界面
      Get.toNamed('/agent/chatlist', arguments: conversation);
      print(">>> 创建agent成功end");
    } catch (e) {
      print(">>> 创建agent失败");
      print(e.toString());
      print("----");
      errorMessage.value = e.toString().replaceAll("Exception: ", "").trim();
      print(errorMessage);
      // 打印错误信息
    } finally {
      isLoading.value = false;
    }
  }
}
