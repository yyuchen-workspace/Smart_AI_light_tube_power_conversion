/*
 * ============================================================
 * 亮度與瓦數對照表
 * ============================================================
 *
 * 根據版本6.0需求文件中的圖表 (image-1.png)
 * 建立亮度百分比與對應瓦數的映射關係
 */

class BrightnessWattageMap {
  // 亮度百分比對應的瓦數 (T8燈管標準)
  // 數據來源: prd/image-1.png
  static const Map<int, double> wattageByBrightness = {
    0: 0.2, // 0%
    10: 1.3, // 10%
    20: 2.3, // 20%
    30: 3.4, // 30%
    40: 4.7, // 40%
    50: 5.9, // 50%
    60: 7.2, // 60%
    70: 8.6, // 70%
    80: 10.04, // 80%
    90: 11.4, // 90%
    100: 12, // 100%
  };

  /// 根據亮度百分比取得對應的瓦數
  ///
  /// [brightness] 亮度百分比 (0-100,必須是10的倍數)
  /// 回傳對應的瓦數,如果亮度值不在對照表中則拋出異常
  static double getWattage(int brightness) {
    if (!wattageByBrightness.containsKey(brightness)) {
      throw ArgumentError('亮度值必須是0-100之間且為10的倍數,目前值: $brightness');
    }
    return wattageByBrightness[brightness]!;
  }

  /// 取得所有可選的亮度選項 (用於下拉選單)
  static List<int> get brightnessOptions => wattageByBrightness.keys.toList();

  /// 取得更換前亮度選項 (限制在50%以下)
  static List<int> get brightnessOptionsBefore =>
      wattageByBrightness.keys.where((b) => b <= 50).toList();

  /// 取得更換後亮度選項 (完整範圍 0-100%)
  static List<int> get brightnessOptionsAfter =>
      wattageByBrightness.keys.toList();

  /// 可選的感應時間選項 (秒)
  static const List<int> sensingDurationOptions = [
    5,
    10,
    15,
    20,
    25,
    30,
    45,
    60,
    90,
    120,
    300
  ];
}
