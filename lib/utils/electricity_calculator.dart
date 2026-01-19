import '../constants/electricity_pricing.dart';

/// 電費計算工具類
///
/// 提供台電電費相關的計算方法
/// 所有方法均為靜態方法（純函數），不依賴實例狀態
class ElectricityCalculator {
  // 基本電價計算
  /// 計算基本電價（契約容量 × 時期電價）
  /// [contractCapacity] 契約容量（瓩）
  /// [isSummer] 是否為夏季
  /// 返回基本電價（元）
  static double calculateBasicElectricity({
    required double contractCapacity,
    required bool isSummer,
  }) {
    final price = isSummer
        ? ElectricityPricing.summerCapacityPrice
        : ElectricityPricing.nonSummerCapacityPrice;
    return contractCapacity * price;
  }

  // 超約費用計算

  /// 計算超約費用
  /// 公式：(最高需量 - 契約容量) × 1.5 × 時期電價
  /// 只有當最高需量超過契約容量時才會產生超約費用
  /// [maxDemand] 最高需量（瓩）
  /// [contractCapacity] 契約容量（瓩）
  /// [isSummer] 是否為夏季
  /// 返回超約費用（元），若無超約則返回 0
  static double calculateExcessDemand({
    required double maxDemand,
    required double contractCapacity,
    required bool isSummer,
  }) {
    if (maxDemand <= contractCapacity) return 0.0;

    final excess = maxDemand - contractCapacity;
    final price = isSummer
        ? ElectricityPricing.summerCapacityPrice
        : ElectricityPricing.nonSummerCapacityPrice;
    return excess * 1.5 * price;
  }

  // ========== 流動電價計算 ==========

  /// 計算流動電價（計費度數 × 時期電價）
  ///
  /// [billingUnits] 計費度數（度）
  /// [isSummer] 是否為夏季
  /// 返回流動電價（元）
  static double calculateFlowElectricity({
    required double billingUnits,
    required bool isSummer,
  }) {
    final price = isSummer
        ? ElectricityPricing.summerUnitPrice
        : ElectricityPricing.nonSummerUnitPrice;
    return billingUnits * price;
  }

  // ========== 總電價計算 ==========

  /// 計算總電價（基本電價 + 流動電價 + 超約費用）
  ///
  /// [basicElectricity] 基本電價（元）
  /// [flowElectricity] 流動電價（元）
  /// [excessDemand] 超約費用（元）
  /// 返回總電價（元）
  static double calculateTotalElectricity({
    required double basicElectricity,
    required double flowElectricity,
    required double excessDemand,
  }) {
    return basicElectricity + flowElectricity + excessDemand;
  }

  // ========== AI 燈管耗電計算 ==========

  /// 計算傳統燈管每月耗電（度）
  ///
  /// 公式：瓦數 × 數量 × 24小時 × 30天 / 1000
  ///
  /// [watt] 燈管瓦數（W）
  /// [count] 燈管數量
  /// 返回每月耗電（度）
  static double calculateTraditionalConsumption({
    required double watt,
    required double count,
  }) {
    return watt * count * 24 * 30 / 1000;
  }

  /// 計算 AI 燈管每月耗電（度）
  ///
  /// 根據車道燈和車位燈數量分別計算
  /// 車道燈：82.12W，車位燈：2.95W
  ///
  /// [drivewayCount] 車道燈數量
  /// [parkingCount] 車位燈數量
  /// 返回每月耗電（度）
  static double calculateAIConsumption({
    required double drivewayCount,
    required double parkingCount,
  }) {
    return (ElectricityPricing.drivewayLightWatt * drivewayCount +
            ElectricityPricing.parkingLightWatt * parkingCount) *
        30 /
        1000;
  }

  /// 計算每月節省電費（元）
  ///
  /// [savingUnits] 節省的度數
  /// [isSummer] 是否為夏季
  /// 返回節省金額（元）
  static double calculateSaving({
    required double savingUnits,
    required bool isSummer,
  }) {
    final unitPrice = isSummer
        ? ElectricityPricing.summerUnitPrice
        : ElectricityPricing.nonSummerUnitPrice;
    return savingUnits * unitPrice;
  }

  // ========== 攤提計算 ==========

  /// 計算買斷模式的回本時間（月）
  ///
  /// [buyoutTotal] 買斷總額（元）
  /// [monthlySaving] 每月節省金額（元）
  /// 返回回本時間（月）
  static double calculatePaybackPeriod({
    required double buyoutTotal,
    required double monthlySaving,
  }) {
    if (monthlySaving <= 0) return 0.0;
    return buyoutTotal / monthlySaving;
  }

  /// 計算租賃模式的每月實際節省（元）
  ///
  /// [totalSaving] 總節省金額（元）
  /// [monthlyRental] 每月租金（元）
  /// 返回實際每月節省（元）
  static double calculateNetSaving({
    required double totalSaving,
    required double monthlyRental,
  }) {
    return totalSaving - monthlyRental;
  }

  // ========== 輔助方法 ==========

  /// 向上舍入到第一位小數
  ///
  /// 例如：123.45 → 123.5
  static double roundUpFirstDecimal(double value) {
    return (value * 10).ceilToDouble() / 10;
  }

  /// 取得時期電價（容量電價）
  static double getCapacityPrice(bool isSummer) {
    return isSummer
        ? ElectricityPricing.summerCapacityPrice
        : ElectricityPricing.nonSummerCapacityPrice;
  }

  /// 取得時期電價（流動電價）
  static double getUnitPrice(bool isSummer) {
    return isSummer
        ? ElectricityPricing.summerUnitPrice
        : ElectricityPricing.nonSummerUnitPrice;
  }
}
