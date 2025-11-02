class ValueUtil {
  // 格式化积分值，去掉小数末尾的 0
  static String formatPoints(double value) {
    // 先转成字符串，如果包含 .0 则去掉
    String str = value.toString();
    if (str.endsWith('.0')) {
      return str.substring(0, str.length - 2);
    }
    // 如果有小数但末尾是 0，也可以进一步清理（可选）
    // 例如：10092.50 → 10092.5
    if (str.contains('.')) {
      // 移除小数部分末尾的 0
      str = str.replaceAll(RegExp(r'0+$'), ''); // 去掉小数点后末尾的 0
      if (str.endsWith('.')) {
        str = str.substring(0, str.length - 1); // 如果只剩小数点，也去掉
      }
    }
    return str;
  }
}
