/*
 * ============================================================
 * 亮燈策略計算工具
 * ============================================================
 *
 * 根據版本6.0的新計算公式
 * 計算車道燈/車位燈的平均每日消耗瓦數
 */

import '../models/lighting_strategy.dart';
import '../constants/brightness_wattage_map.dart';

class LightingCalculator {
  // 車道燈固定感應次數
  static const int drivewayDaytimeSensing = 1440;  // 日間感應次數
  static const int drivewayNighttimeSensing = 1285; // 夜間感應次數
  static const int drivewayAllDaySensing = 2325;    // 全天候 = 1440 + 885

  // 車位燈固定感應次數
  static const int parkingDaytimeSensing = 80;     // 日間感應次數
  static const int parkingNighttimeSensing = 30;   // 夜間感應次數
  static const int parkingAllDaySensing = 110;     // 全天候 = 80 + 30

  /// 計算車道燈平均每日消耗瓦數
  ///
  /// 公式:
  /// - 一般模式: 日間*日間亮度感應前瓦數 + 1440次*日間感應時間*(感應後瓦數-感應前瓦數)
  ///           + 夜間*夜間亮度感應前瓦數 + 1285次*夜間感應時間*(感應後瓦數-感應前瓦數)
  ///
  /// - 全天候模式: 日間*日間亮度感應前瓦數 + 2325次*日間感應時間*(感應後瓦數-感應前瓦數)
  static double calculateDrivewayWattage(LightingStrategy strategy) {
    double totalWattage = 0.0;

    if (strategy.isAllDayMode) {
      // 全天候模式
      totalWattage = _calculateTimeSlotWattage(
        timeSlot: strategy.daytime,
        sensingCount: drivewayAllDaySensing,
      );
    } else {
      // 一般模式 (日間 + 夜間)
      totalWattage += _calculateTimeSlotWattage(
        timeSlot: strategy.daytime,
        sensingCount: drivewayDaytimeSensing,
      );

      if (strategy.nighttime != null) {
        totalWattage += _calculateTimeSlotWattage(
          timeSlot: strategy.nighttime!,
          sensingCount: drivewayNighttimeSensing,
        );
      }
    }

    return totalWattage;
  }

  /// 計算車位燈平均每日消耗瓦數
  ///
  /// 公式:
  /// - 一般模式: 日間*日間亮度感應前瓦數 + 80次*日間感應時間*(感應後瓦數-感應前瓦數)
  ///           + 夜間*夜間亮度感應前瓦數 + 30次*夜間感應時間*(感應後瓦數-感應前瓦數)
  ///
  /// - 全天候模式: 日間*日間亮度感應前瓦數 + 110次*日間感應時間*(感應後瓦數-感應前瓦數)
  static double calculateParkingWattage(LightingStrategy strategy) {
    double totalWattage = 0.0;

    if (strategy.isAllDayMode) {
      // 全天候模式
      totalWattage = _calculateTimeSlotWattage(
        timeSlot: strategy.daytime,
        sensingCount: parkingAllDaySensing,
      );
    } else {
      // 一般模式 (日間 + 夜間)
      totalWattage += _calculateTimeSlotWattage(
        timeSlot: strategy.daytime,
        sensingCount: parkingDaytimeSensing,
      );

      if (strategy.nighttime != null) {
        totalWattage += _calculateTimeSlotWattage(
          timeSlot: strategy.nighttime!,
          sensingCount: parkingNighttimeSensing,
        );
      }
    }

    return totalWattage;
  }

  /// 計算單一時段的瓦數消耗
  ///
  /// 公式: 時段長度 * 感應前瓦數 + 感應次數 * 感應時間(秒) * (感應後瓦數 - 感應前瓦數)
  static double _calculateTimeSlotWattage({
    required TimeSlotConfig timeSlot,
    required int sensingCount,
  }) {
    // 取得感應前後的瓦數
    double wattBefore = BrightnessWattageMap.getWattage(
      timeSlot.brightness.brightnessBeforeSensing,
    );
    double wattAfter = BrightnessWattageMap.getWattage(
      timeSlot.brightness.brightnessAfterSensing,
    );

    // 時段長度(小時)
    double duration = timeSlot.duration;

    // 感應時間(秒轉小時)
    double sensingDurationInHours =
        timeSlot.brightness.sensingDuration / 3600.0;

    // 計算公式
    double baseWattage = duration * wattBefore;
    double sensingWattage =
        sensingCount * sensingDurationInHours * (wattAfter - wattBefore);

    return baseWattage + sensingWattage;
  }

  /// 計算每月耗電量 (度/kWh)
  ///
  /// [dailyWattage] 每日消耗瓦數
  /// [count] 燈管數量
  /// 回傳每月耗電量 (度)
  static double calculateMonthlyConsumption(double dailyWattage, int count) {
    // 每日瓦數 * 數量 * 30天 / 1000 = 度數
    return dailyWattage * count * 30 / 1000;
  }
}
