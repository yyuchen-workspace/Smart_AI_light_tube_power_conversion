/*
 * ============================================================
 * 亮燈策略資料模型
 * ============================================================
 *
 * 用於儲存車道燈/車位燈的亮燈策略設定
 * 包含日間/夜間的時段、亮度、感應時間等參數
 */

/// 時段設定 (日間或夜間)
class TimeSlotConfig {
  // 開始時間 (小時,0-24)
  double startHour;

  // 結束時間 (小時,0-24)
  double endHour;

  // 是否為全天候模式
  bool isAllDay;

  // 亮度設定
  BrightnessConfig brightness;

  TimeSlotConfig({
    required this.startHour,
    required this.endHour,
    required this.isAllDay,
    required this.brightness,
  });

  /// 計算時段長度(小時)
  double get duration {
    if (isAllDay) return 24.0;
    double diff = endHour - startHour;
    return diff < 0 ? diff + 24 : diff; // 處理跨午夜情況
  }
}

/// 亮度設定
class BrightnessConfig {
  // 感應前亮度 (0-100%)
  int brightnessBeforeSensing;

  // 感應後亮度 (0-100%)
  int brightnessAfterSensing;

  // 感應時間 (秒)
  int sensingDuration;

  BrightnessConfig({
    required this.brightnessBeforeSensing,
    required this.brightnessAfterSensing,
    required this.sensingDuration,
  });
}

/// 燈管類型的完整策略
class LightingStrategy {
  // 燈管數量
  int count;

  // 日間時段設定
  TimeSlotConfig daytime;

  // 夜間時段設定 (可能為null,如果選擇全天候)
  TimeSlotConfig? nighttime;

  LightingStrategy({
    required this.count,
    required this.daytime,
    this.nighttime,
  });

  /// 是否為全天候模式
  bool get isAllDayMode => daytime.isAllDay;
}
