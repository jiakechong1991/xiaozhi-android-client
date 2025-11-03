import 'package:get/get.dart';
import 'package:ai_assistant/models/conversation.dart';
import 'package:ai_assistant/services/api_service.dart';
import 'package:ai_assistant/utils/time_util.dart';

// 这个对应 账户积分 的 操作类
class AccountAboutPageController extends GetxController {
  final nowAccountPoint = 0.0.obs; // 用于显示当前账户的积分
  final todayConsumePoint_ = 0.0.obs; // 今日消耗积分
  final _consumePointRecordList =
      <ConsumePointRecord>[].obs; // [消费记录1, 消费记录2, ...]

  final ApiService _api = Get.find<ApiService>();

  ///封装的快捷方法
  List<ConsumePointRecord> get consumePointRecordList =>
      _consumePointRecordList;

  AccountAboutPageController() {
    print("---调用AccountAboutPageController的构造函数了---");
  }

  Future<void> getTodayConsumePoint() async {
    try {
      final resConsumePointRecords = await _api.getAccountConsumePonitRecords(
        startTime: TimeUtil.getTodayStartTimeString(),
        endTime: TimeUtil.getNowTimeString(),
        aggregationDim: TimeUtil.day,
        timeZone: TimeUtil.cachedTimeZoneId!,
      );
      print("从服务器拉取今天的 账户积分 列表成功");
      print(resConsumePointRecords);
      if (resConsumePointRecords.isEmpty) {
        todayConsumePoint_.value = 0.0;
      } else {
        todayConsumePoint_.value = resConsumePointRecords.values.first;
      }
    } catch (e, stackTrace) {
      print('从服务器拉取今天的 账户积分 列表失败: $e');
      print('堆栈: $stackTrace');
    }
  }

  Future<void> getAccountPonit() async {
    // 从服务器获得当前账户的积分余额
    try {
      final responseAccountInfo = await _api.getAccountPonit();
      nowAccountPoint.value = responseAccountInfo["balance_points"];
      final userName = responseAccountInfo["username"];
    } catch (e, stackTrace) {
      print('从服务器加载 账户积分信息 失败: $e');
    }
  }

  Future<void> loadPointConsumeRecordList(String aggregationDim) async {
    try {
      final resConsumePointRecords = await _api.getAccountConsumePonitRecords(
        startTime: TimeUtil.getTodayStartTimeString(),
        endTime: TimeUtil.getNowTimeString(),
        aggregationDim: aggregationDim,
        timeZone: TimeUtil.cachedTimeZoneId!,
      );
      print("从服务器拉取时间段的 账户积分 列表成功");
      print(resConsumePointRecords);
      _consumePointRecordList.value =
          resConsumePointRecords.entries.map((entry) {
            return ConsumePointRecord(
              timeStr: entry.key,
              consumePoints: entry.value,
            );
          }).toList();
    } catch (e, stackTrace) {
      print('从服务器加载 消费记录 列表失败: $e');
      print('堆栈: $stackTrace');
    }
  }
}
