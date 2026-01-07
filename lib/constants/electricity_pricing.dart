/// 台電電價常數（113年10月16日起適用）
///
/// 包含容量電價、流動電價及 AI 燈管消耗瓦數
class ElectricityPricing {
  // ========== 容量電價（元/瓩）==========

  /// 夏季容量電價（元/瓩）
  static const double summerCapacityPrice = 236.2;

  /// 非夏季容量電價（元/瓩）
  static const double nonSummerCapacityPrice = 173.2;

  // ========== 流動電價（元/度）==========

  /// 夏季流動電價（元/度）
  static const double summerUnitPrice = 4.08;

  /// 非夏季流動電價（元/度）
  static const double nonSummerUnitPrice = 3.87;

  // ========== AI 燈管消耗瓦數 ==========

  /// AI 燈管基礎消耗瓦數
  static const double aiLightWatt = 12.0;

  /// 車道燈消耗瓦數（W）
  static const double drivewayLightWatt = 82.12;

  /// 車位燈消耗瓦數（W）
  static const double parkingLightWatt = 2.95;
}
