// lib/controllers/login_controller.dart
import 'package:get/get.dart';
import 'package:ai_assistant/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckProfileController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final hasProfile = true.obs; // 用于表示这个用户是否填写了自己的信息

  Future<void> loadHasProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final hasPrfile_ = prefs.getBool('has_profile');
    print("----loadHasProfile结果：$hasPrfile_");
    if (hasPrfile_ == null) {
      // 如果值为空 或者值为
      // 请求server然后写入缓存
      final resData = await _api.checkProfileComplete();
      if (resData["code"] == 0) {
        hasProfile.value = resData["has_profile"];
        prefs.setBool("has_profile", resData["has_profile"]);
      }
    } else {
      hasProfile.value = hasPrfile_;
    }
  }
}
