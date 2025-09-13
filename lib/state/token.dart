import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

/* 
使用 .obs 包装变量（如 String.obs, int.obs, List.obs）
修改值时用 .value = xxx
自动触发 UI 更新，无需手动调用 update()
使用 Obx(() => ...) 或 GetBuilder 包裹 UI
这是目前官方推荐、社区主流、性能更好的方式
*/

class TokenController extends GetxController {
  static TokenController get to => Get.find(); // 定义 .to

  var token = ''.obs; // 可观察变量, 这是一种 响应式风格

  /// 设置token
  void set(String t) => token.value = t;

  /// 删除token
  void delete() => token.value = '';

  // /// 使用 jwt_decoder 官方库判断 access token 是否过期
  // Future<bool> isAccessTokenExpired() async {
  //   final accessToken = await TokenStorage.getAccessToken();
  //   if (accessToken == null || accessToken.isEmpty) {
  //     return true; // 无 token 视为过期
  //   }

  //   // 核心：一行代码判断是否过期
  //   return JwtDecoder.isExpired(accessToken);
  // }
}
