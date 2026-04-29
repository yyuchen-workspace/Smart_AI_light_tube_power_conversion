/*
 * ============================================================
 * 數字格式化工具 - 版本 14.0
 * ============================================================
 *
 * 提供數字格式化功能,包括千分位逗點
 */

class NumberFormatter {
  /// 格式化數字,加入千分位逗點
  ///
  /// 範例:
  /// - formatWithComma(1234) => "1,234"
  /// - formatWithComma(1234567.89) => "1,234,567.89"
  /// - formatWithComma(1234, decimals: 1) => "1,234.0"
  static String formatWithComma(double value, {int? decimals}) {
    // 如果指定小數位數,先格式化小數
    String valueStr;
    if (decimals != null) {
      valueStr = value.toStringAsFixed(decimals);
    } else {
      valueStr = value.toString();
    }

    // 分離整數和小數部分
    List<String> parts = valueStr.split('.');
    String integerPart = parts[0];
    String? decimalPart = parts.length > 1 ? parts[1] : null;

    // 為整數部分添加千分位逗點(每3位)
    String formattedInteger = _addCommaToInteger(integerPart);

    // 組合結果
    if (decimalPart != null && decimalPart != '0') {
      return '$formattedInteger.$decimalPart';
    } else {
      return formattedInteger;
    }
  }

  /// 為整數字串添加千分位逗點
  static String _addCommaToInteger(String integerStr) {
    // 處理負號
    bool isNegative = integerStr.startsWith('-');
    if (isNegative) {
      integerStr = integerStr.substring(1);
    }

    // 從後往前每3位插入逗點
    StringBuffer result = StringBuffer();
    int length = integerStr.length;

    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        result.write(',');
      }
      result.write(integerStr[i]);
    }

    return isNegative ? '-${result.toString()}' : result.toString();
  }
}
