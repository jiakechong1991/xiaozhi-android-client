import 'package:get/get.dart';

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
}
