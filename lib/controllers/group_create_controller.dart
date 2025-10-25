// lib/controllers/login_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ai_assistant/services/api_service.dart';
import 'package:ai_assistant/controllers/group_list_controller.dart';
import 'package:ai_assistant/controllers/agent_list_controller.dart';
import 'package:ai_assistant/models/conversation.dart';
import 'package:ai_assistant/controllers/config_controller.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:ai_assistant/screens/base/kit/index.dart';

class CreateGroupController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final isLoading = false.obs; // 用于显示 loading
  final errorMessage = ''.obs; // 用于显示错误信息
  final groupListCtlIns = Get.find<ConversationController>();
  final agentListCtlIns = Get.find<AgentRoleListController>();
  final wcaoUtilsIns = Get.find<WcaoUtils>();

  // 表单控制器
  final titleEditCtlIns = TextEditingController();
  final settingEditCtlIns = TextEditingController();
  // 整个剧组的演员表
  var groupAgents = <AgentRole>[];
  var humanAgentList = <AgentRole>[]; // 完整的可选人类演员表
  var humanAgentUse = <AgentRole>[].obs;
  var aiAgentsUser = <AgentRole>[].obs;
  var aiAgentList = <AgentRole>[]; // 完整的可选ai演员表
  // 头像背景 图片文件（可选）
  var avatarFile = Rx<File?>(null);
  var backdropFile = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    // 设置默认的人类演员
    humanAgentUse.value = [agentListCtlIns.humanAgentRoleDefault];
    // 设定 可选的人类演员表和ai演员表
    humanAgentList = agentListCtlIns.humanAgentRoleList;
    aiAgentList = agentListCtlIns.aiAgentRoleList;
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
  }

  @override
  void onClose() {
    titleEditCtlIns.dispose();
    settingEditCtlIns.dispose();
    super.onClose();
  }

  Future<void> create_group() async {
    print(">>> create_agent 按钮被点击，开始创建agent");
    if (titleEditCtlIns.text.isEmpty) {
      errorMessage.value = "场景名称不能为空";
      return;
    }
    if (humanAgentUse.value == null) {
      errorMessage.value = "请选择自己的演员化身";
      return;
    }
    if (aiAgentsUser.value.isEmpty) {
      errorMessage.value = "请至少选择一个ai角色";
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // final newAgentRole = await groupListCtlIns.createAgentRole(
      //   agentName: agentNameController.text,
      //   sex: sex.value,
      //   birthday: birthdayController.text,
      //   characterSetting: characterSettingController.text,
      //   age: ageController.text,
      //   voices: voices.value,
      //   avatarFile: avatarFile.value,
      // );
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
