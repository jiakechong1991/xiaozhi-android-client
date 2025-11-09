import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ai_assistant/services/api_service.dart';
import 'package:ai_assistant/models/conversation.dart';
import 'package:ai_assistant/screens/base/kit/index.dart';
import 'package:ai_assistant/utils/time_util.dart';

class MacSettingController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final isLoading = false.obs; // 用于显示 loading
  final errorMessage = ''.obs; // 用于显示错误信息
  var activateCode = ''.obs; // 激活码
  final wcaoUtilsIns = Get.find<WcaoUtils>();

  // 表单控制器
  final codeEditCtlIns = TextEditingController();

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    codeEditCtlIns.dispose();
    super.onClose();
  }

  Future<void> getBandingInfo(GroupChat groupChatIns) async {
    print(">>> getBandingInfo 按钮被点击，开始该group的绑定信息");

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final resMacInfo = await _api.getMacBandingInfo(
        groupId: groupChatIns.groupId,
      );
      // 如果该group已经绑定，将激活码设置到activateCode中，如果没有绑定就结束
    } catch (e, stackTrace) {
      print(">>> getBandingInfo 失败");
      print("错误信息: $e");
      print("完整堆栈:");
      print(stackTrace); //
      print("----");
      errorMessage.value = e.toString().replaceAll("Exception: ", "").trim();
      // 打印错误信息
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteBanding(GroupChat groupChatIns) async {
    print(">>> deleteBanding 按钮被点击，开始删除绑定信息");
    if (activateCode.value.isEmpty) {
      errorMessage.value = "激活码不能为空";
      print(errorMessage.value);
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final resDelMacBanding = await _api.deleteMacBandingInfo(
        activateCode: activateCode.value,
      );
      activateCode.value = '';

      print(">>> 删除mac绑定成功");
    } catch (e, stackTrace) {
      print(">>> 删除mac绑定失败");
      print("错误信息: $e");
      print("完整堆栈:");
      print(stackTrace); //
      print("----");
      errorMessage.value = e.toString().replaceAll("Exception: ", "").trim();
      // 打印错误信息
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> doBanding(GroupChat groupChatIns) async {
    print(">>> create_agent 按钮被点击，开始绑定group");
    if (codeEditCtlIns.text.isEmpty) {
      errorMessage.value = "激活码不能为空";
      print(errorMessage.value);
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final newAgentRole = await _api.doMacBanding(
        activateCode: activateCode.value,
        groupId: groupChatIns.groupId,
        bandingAgentId: groupChatIns.createHumanAgentId,
        timezone: TimeUtil.cachedTimeZoneId!,
      );
      print(">>> 创建group成功end");
    } catch (e, stackTrace) {
      print(">>> 创建group失败");
      print("错误信息: $e");
      print("完整堆栈:");
      print(stackTrace); //
      print("----");
      errorMessage.value = e.toString().replaceAll("Exception: ", "").trim();
      // 打印错误信息
    } finally {
      isLoading.value = false;
    }
  }
}
