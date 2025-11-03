import 'package:intl/intl.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

/// 时间工具类
class TimeUtil {
  static String? cachedTimeZoneId;
  static String timeFormat = 'yyyy-MM-dd HH:mm:ss';
  // 这是聚合的时间维度，这两个字符串是和服务端对应的，不要轻易修改
  static String month = "month";
  static String day = "day";

  /// 获取当前的时间字符串
  static String getNowTimeString() {
    DateTime now = DateTime.now();
    // 使用 DateFormat 格式化
    DateFormat formatter = DateFormat(timeFormat);
    return formatter.format(now);
  }

  // 获取今天的开始时间戳字符串
  static String getTodayStartTimeString() {
    DateTime now = DateTime.now();
    DateTime todayStart = DateTime(now.year, now.month, now.day);
    // 使用 DateFormat 格式化
    DateFormat formatter = DateFormat(timeFormat);
    return formatter.format(todayStart);
  }

  static Future<String> getDeviceTimeZoneId() async {
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    cachedTimeZoneId = timezoneInfo.identifier;
    return cachedTimeZoneId!;
  }

  // 获取当前的所在时区
  static String getTimeZone() {
    return DateTime.now().timeZoneName;
  }

  // 获取今天前N天的日期字符串
  static String getDateStringDaysAgo(int daysAgo) {
    DateTime targetDate = DateTime.now().subtract(Duration(days: daysAgo));
    DateTime targetDayStart = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );
    DateFormat formatter = DateFormat(timeFormat);
    return formatter.format(targetDayStart);
  }
}
