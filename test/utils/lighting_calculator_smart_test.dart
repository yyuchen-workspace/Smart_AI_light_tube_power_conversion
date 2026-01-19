import 'package:flutter_test/flutter_test.dart';
import 'package:web_calculator_app/utils/lighting_calculator.dart';
import 'package:web_calculator_app/models/lighting_strategy.dart';
import 'package:web_calculator_app/constants/brightness_wattage_map.dart';

/// 智能亮燈策略測試 - 自動檢測計算錯誤
///
/// 這個測試會：
/// 1. 獨立計算預期結果（不依賴被測程式）
/// 2. 比對實際結果
/// 3. 當不符時，詳細列出差異和可能原因
void main() {
  group('智能檢測 - 車道燈計算', () {
    test('車道燈日夜分段模式 - 自動驗證', () {
      print('\n╔════════════════════════════════════════════════════════╗');
      print('║       智能檢測：車道燈日夜分段計算                       ║');
      print('╚════════════════════════════════════════════════════════╝');

      // 設定測試場景
      final daytimeStart = 6.0;
      final daytimeEnd = 18.0;
      final nighttimeStart = 18.0;
      final nighttimeEnd = 6.0;
      final dayBrightnessBefore = 30;
      final dayBrightnessAfter = 100;
      final nightBrightnessBefore = 10;
      final nightBrightnessAfter = 100;
      final sensingDuration = 30;

      print('\n【測試場景】');
      print('  日間：$daytimeStart:00 - $daytimeEnd:00');
      print('  夜間：$nighttimeStart:00 - $nighttimeEnd:00');
      print('  日間亮度：$dayBrightnessBefore% → $dayBrightnessAfter%');
      print('  夜間亮度：$nightBrightnessBefore% → $nightBrightnessAfter%');
      print('  感應時間：$sensingDuration 秒');

      // 建立策略
      final strategy = LightingStrategy(
        count: 1,
        daytime: TimeSlotConfig(
          startHour: daytimeStart,
          endHour: daytimeEnd,
          isAllDay: false,
          brightness: BrightnessConfig(
            brightnessBeforeSensing: dayBrightnessBefore,
            brightnessAfterSensing: dayBrightnessAfter,
            sensingDuration: sensingDuration,
          ),
        ),
        nighttime: TimeSlotConfig(
          startHour: nighttimeStart,
          endHour: nighttimeEnd,
          isAllDay: false,
          brightness: BrightnessConfig(
            brightnessBeforeSensing: nightBrightnessBefore,
            brightnessAfterSensing: nightBrightnessAfter,
            sensingDuration: sensingDuration,
          ),
        ),
      );

      // === 獨立計算預期結果 ===
      print('\n【獨立計算預期值】');

      // 日間計算
      final dayWattBefore = BrightnessWattageMap.getWattage(dayBrightnessBefore);
      final dayWattAfter = BrightnessWattageMap.getWattage(dayBrightnessAfter);
      var dayDuration = daytimeEnd - daytimeStart;
      // 智能檢測：如果跨午夜，自動修正
      if (dayDuration < 0) {
        print('  ⚠️  日間時段跨午夜，自動修正：$dayDuration → ${dayDuration + 24}');
        dayDuration += 24;
      }
      final daySensingHours = sensingDuration / 3600.0;
      final daySensingCount = 1440;

      final expectedDayBase = dayDuration * dayWattBefore;
      final expectedDaySensing = daySensingCount * daySensingHours * (dayWattAfter - dayWattBefore);
      final expectedDayTotal = expectedDayBase + expectedDaySensing;

      print('  日間基礎：$dayDuration × $dayWattBefore = ${expectedDayBase.toStringAsFixed(3)} Wh');
      print('  日間感應：$daySensingCount × ${daySensingHours.toStringAsFixed(6)} × ${dayWattAfter - dayWattBefore} = ${expectedDaySensing.toStringAsFixed(3)} Wh');
      print('  日間總計：${expectedDayTotal.toStringAsFixed(3)} Wh');

      // 夜間計算
      final nightWattBefore = BrightnessWattageMap.getWattage(nightBrightnessBefore);
      final nightWattAfter = BrightnessWattageMap.getWattage(nightBrightnessAfter);
      var nightDuration = nighttimeEnd - nighttimeStart;
      // 智能檢測：如果跨午夜，自動修正
      if (nightDuration < 0) {
        print('  ⚠️  夜間時段跨午夜，自動修正：$nightDuration → ${nightDuration + 24}');
        nightDuration += 24;
      }
      final nightSensingHours = sensingDuration / 3600.0;
      final nightSensingCount = 885;

      final expectedNightBase = nightDuration * nightWattBefore;
      final expectedNightSensing = nightSensingCount * nightSensingHours * (nightWattAfter - nightWattBefore);
      final expectedNightTotal = expectedNightBase + expectedNightSensing;

      print('  夜間基礎：$nightDuration × $nightWattBefore = ${expectedNightBase.toStringAsFixed(3)} Wh');
      print('  夜間感應：$nightSensingCount × ${nightSensingHours.toStringAsFixed(6)} × ${nightWattAfter - nightWattBefore} = ${expectedNightSensing.toStringAsFixed(3)} Wh');
      print('  夜間總計：${expectedNightTotal.toStringAsFixed(3)} Wh');

      final expectedTotal = expectedDayTotal + expectedNightTotal;
      print('\n  預期每日總耗電：${expectedTotal.toStringAsFixed(3)} Wh');

      // === 執行程式計算 ===
      print('\n【執行程式計算】');
      final actualResult = LightingCalculator.calculateDrivewayWattage(strategy);
      print('  實際每日總耗電：${actualResult.toStringAsFixed(3)} Wh');

      // === 智能比對與診斷 ===
      print('\n【結果比對】');
      final difference = (actualResult - expectedTotal).abs();
      final tolerance = 0.01;

      if (difference <= tolerance) {
        print('  ✅ 計算正確！差異 ${difference.toStringAsFixed(6)} Wh (< ${tolerance} Wh)');
      } else {
        print('  ❌ 計算錯誤！差異 ${difference.toStringAsFixed(3)} Wh');
        print('\n【錯誤診斷】');

        // 診斷 1: 檢查是否為跨午夜問題
        final nightDurationRaw = nighttimeEnd - nighttimeStart;
        if (nightDurationRaw < 0) {
          final wrongNightBase = nightDurationRaw * nightWattBefore;
          final wrongNightTotal = wrongNightBase + expectedNightSensing;
          final wrongTotal = expectedDayTotal + wrongNightTotal;
          final diffFromWrongCalc = (actualResult - wrongTotal).abs();

          if (diffFromWrongCalc < tolerance) {
            print('  🐛 診斷結果：跨午夜時段計算錯誤');
            print('     夜間 duration = $nighttimeEnd - $nighttimeStart = $nightDurationRaw (錯誤)');
            print('     應該修正為：$nightDurationRaw + 24 = ${nightDurationRaw + 24}');
            print('     錯誤的基礎瓦數：$nightDurationRaw × $nightWattBefore = ${wrongNightBase.toStringAsFixed(3)} Wh');
            print('     正確的基礎瓦數：${nightDuration} × $nightWattBefore = ${expectedNightBase.toStringAsFixed(3)} Wh');
            print('     影響：每日少算 ${(expectedNightBase - wrongNightBase).toStringAsFixed(3)} Wh');
          }
        }

        // 診斷 2: 檢查感應次數是否正確
        final expectedWithWrongDaySensing = (dayDuration * dayWattBefore) + (nightSensingCount * daySensingHours * (dayWattAfter - dayWattBefore)) + expectedNightTotal;
        if ((actualResult - expectedWithWrongDaySensing).abs() < tolerance) {
          print('  🐛 診斷結果：日間感應次數錯誤');
          print('     可能使用了夜間感應次數 $nightSensingCount 而非 $daySensingCount');
        }

        // 診斷 3: 檢查瓦數對照是否正確
        print('\n  瓦數對照檢查：');
        print('     $dayBrightnessBefore% = $dayWattBefore W');
        print('     $dayBrightnessAfter% = $dayWattAfter W');
        print('     $nightBrightnessBefore% = $nightWattBefore W');
        print('     $nightBrightnessAfter% = $nightWattAfter W');
      }

      print('\n╔════════════════════════════════════════════════════════╗');
      if (difference <= tolerance) {
        print('║  ✅ 測試通過                                           ║');
      } else {
        print('║  ❌ 測試失敗 - 請檢查上方診斷結果                      ║');
      }
      print('╚════════════════════════════════════════════════════════╝\n');

      expect(actualResult, closeTo(expectedTotal, tolerance));
    });

    test('車位燈日夜分段模式 - 自動驗證', () {
      print('\n╔════════════════════════════════════════════════════════╗');
      print('║       智能檢測：車位燈日夜分段計算                       ║');
      print('╚════════════════════════════════════════════════════════╝');

      final strategy = LightingStrategy(
        count: 1,
        daytime: TimeSlotConfig(
          startHour: 6,
          endHour: 18,
          isAllDay: false,
          brightness: BrightnessConfig(
            brightnessBeforeSensing: 30,
            brightnessAfterSensing: 100,
            sensingDuration: 30,
          ),
        ),
        nighttime: TimeSlotConfig(
          startHour: 18,
          endHour: 6,
          isAllDay: false,
          brightness: BrightnessConfig(
            brightnessBeforeSensing: 10,
            brightnessAfterSensing: 100,
            sensingDuration: 30,
          ),
        ),
      );

      print('\n【獨立計算預期值】');

      // 日間
      var dayDuration = 18.0 - 6.0;
      final dayWattBefore = BrightnessWattageMap.getWattage(30);
      final dayWattAfter = BrightnessWattageMap.getWattage(100);
      final expectedDayBase = dayDuration * dayWattBefore;
      final expectedDaySensing = 80 * (30 / 3600.0) * (dayWattAfter - dayWattBefore);
      final expectedDayTotal = expectedDayBase + expectedDaySensing;
      print('  日間總計：${expectedDayTotal.toStringAsFixed(3)} Wh');

      // 夜間
      var nightDuration = 6.0 - 18.0;
      if (nightDuration < 0) {
        print('  ⚠️  夜間跨午夜，修正：$nightDuration → ${nightDuration + 24}');
        nightDuration += 24;
      }
      final nightWattBefore = BrightnessWattageMap.getWattage(10);
      final nightWattAfter = BrightnessWattageMap.getWattage(100);
      final expectedNightBase = nightDuration * nightWattBefore;
      final expectedNightSensing = 30 * (30 / 3600.0) * (nightWattAfter - nightWattBefore);
      final expectedNightTotal = expectedNightBase + expectedNightSensing;
      print('  夜間總計：${expectedNightTotal.toStringAsFixed(3)} Wh');

      final expectedTotal = expectedDayTotal + expectedNightTotal;
      print('  預期總計：${expectedTotal.toStringAsFixed(3)} Wh');

      // 執行程式計算
      print('\n【執行程式計算】');
      final actualResult = LightingCalculator.calculateParkingWattage(strategy);
      print('  實際總計：${actualResult.toStringAsFixed(3)} Wh');

      // 比對結果
      final difference = (actualResult - expectedTotal).abs();
      print('\n【結果比對】');
      if (difference <= 0.01) {
        print('  ✅ 計算正確！');
      } else {
        print('  ❌ 計算錯誤！差異 ${difference.toStringAsFixed(3)} Wh');
      }

      print('\n╔════════════════════════════════════════════════════════╗');
      print('║  ${difference <= 0.01 ? "✅ 測試通過" : "❌ 測試失敗"}                                           ║');
      print('╚════════════════════════════════════════════════════════╝\n');

      expect(actualResult, closeTo(expectedTotal, 0.01));
    });
  });

  group('智能檢測 - 邊界情況', () {
    test('跨午夜時段檢測（23:00-1:00）', () {
      print('\n╔════════════════════════════════════════════════════════╗');
      print('║       跨午夜邊界測試（23:00-1:00）                      ║');
      print('╚════════════════════════════════════════════════════════╝');

      final strategy = LightingStrategy(
        count: 1,
        daytime: TimeSlotConfig(
          startHour: 23,
          endHour: 1,
          isAllDay: false,
          brightness: BrightnessConfig(
            brightnessBeforeSensing: 50,
            brightnessAfterSensing: 100,
            sensingDuration: 10,
          ),
        ),
      );

      // 獨立計算
      var duration = 1.0 - 23.0;
      print('\n【時段分析】');
      print('  原始計算：1 - 23 = $duration 小時');

      if (duration < 0) {
        duration += 24;
        print('  跨午夜修正：$duration 小時 ✓');
      }

      final wattBefore = BrightnessWattageMap.getWattage(50);
      final wattAfter = BrightnessWattageMap.getWattage(100);
      final expectedBase = duration * wattBefore;
      final expectedSensing = 1440 * (10 / 3600.0) * (wattAfter - wattBefore);
      final expected = expectedBase + expectedSensing;

      print('  預期基礎瓦數：$duration × $wattBefore = ${expectedBase.toStringAsFixed(3)} Wh');
      print('  預期感應瓦數：${expectedSensing.toStringAsFixed(3)} Wh');
      print('  預期總計：${expected.toStringAsFixed(3)} Wh');

      final actual = LightingCalculator.calculateDrivewayWattage(strategy);
      print('\n  實際結果：${actual.toStringAsFixed(3)} Wh');

      final diff = (actual - expected).abs();
      print('  差異：${diff.toStringAsFixed(3)} Wh ${diff <= 0.01 ? "✅" : "❌"}');

      expect(actual, closeTo(expected, 0.01));
    });
  });
}
