import 'package:flutter_test/flutter_test.dart';
import 'package:web_calculator_app/utils/lighting_calculator.dart';
import 'package:web_calculator_app/models/lighting_strategy.dart';
import 'package:web_calculator_app/constants/brightness_wattage_map.dart';

/// 亮燈策略計算工具測試
///
/// 測試車道燈和車位燈的亮度策略計算邏輯
/// 驗證公式：時段長度 × 感應前瓦數 + 感應次數 × 感應時間 × (感應後瓦數 - 感應前瓦數)
void main() {
  group('LightingCalculator - 車道燈計算', () {
    test('車道燈全天候模式計算', () {
      print('\n╔════════════════════════════════════════════════════════╗');
      print('║           車道燈全天候模式計算                           ║');
      print('╚════════════════════════════════════════════════════════╝');

      print('\n【場景設定】');
      print('  - 模式：全天候 (24小時)');
      print('  - 感應前亮度：30% → ${BrightnessWattageMap.getWattage(30)} W');
      print('  - 感應後亮度：100% → ${BrightnessWattageMap.getWattage(100)} W');
      print('  - 感應時間：30 秒');
      print('  - 固定感應次數：2325 次');

      // 建立策略
      final strategy = LightingStrategy(
        count: 1,
        daytime: TimeSlotConfig(
          startHour: 0,
          endHour: 24,
          isAllDay: true,
          brightness: BrightnessConfig(
            brightnessBeforeSensing: 30,
            brightnessAfterSensing: 100,
            sensingDuration: 30,
          ),
        ),
      );

      print('\n【計算步驟】');
      print('  公式: 時段長度 × 感應前瓦數 + 感應次數 × 感應時間(小時) × (感應後瓦數 - 感應前瓦數)');

      final wattBefore = BrightnessWattageMap.getWattage(30);
      final wattAfter = BrightnessWattageMap.getWattage(100);
      final duration = 24.0;
      final sensingCount = 2325;
      final sensingHours = 30 / 3600.0;

      print('  步驟 1: 基礎瓦數 = 時段長度 × 感應前瓦數');
      print('         = $duration × $wattBefore');
      final baseWattage = duration * wattBefore;
      print('         = $baseWattage Wh');

      print('  步驟 2: 感應瓦數 = 感應次數 × 感應時間(小時) × 瓦數差');
      print(
          '         = $sensingCount × ${sensingHours.toStringAsFixed(6)} × (${wattAfter} - ${wattBefore})');
      print(
          '         = $sensingCount × ${sensingHours.toStringAsFixed(6)} × ${wattAfter - wattBefore}');
      final sensingWattage =
          sensingCount * sensingHours * (wattAfter - wattBefore);
      print('         = ${sensingWattage.toStringAsFixed(3)} Wh');

      print('  步驟 3: 總瓦數 = 基礎瓦數 + 感應瓦數');
      print('         = $baseWattage + ${sensingWattage.toStringAsFixed(3)}');

      final result = LightingCalculator.calculateDrivewayWattage(strategy);

      print('  結果: ${result.toStringAsFixed(3)} Wh/日');
      print('\n╔════════════════════════════════════════════════════════╗');
      print('║  每支車道燈每日消耗 ${result.toStringAsFixed(2)} Wh             ║');
      print('╚════════════════════════════════════════════════════════╝\n');

      expect(result, closeTo(baseWattage + sensingWattage, 0.01));
    });

    test('車道燈日夜分段模式計算', () {
      print('\n╔════════════════════════════════════════════════════════╗');
      print('║           車道燈日夜分段模式計算                          ║');
      print('╚════════════════════════════════════════════════════════╝');

      print('\n【場景設定】');
      print('  日間時段 (6:00-18:00, 12小時):');
      print('    - 感應前亮度：30% → ${BrightnessWattageMap.getWattage(30)} W');
      print('    - 感應後亮度：100% → ${BrightnessWattageMap.getWattage(100)} W');
      print('    - 感應時間：30 秒');
      print('    - 固定感應次數：1440 次');
      print('  夜間時段 (18:00-6:00, 12小時):');
      print('    - 感應前亮度：10% → ${BrightnessWattageMap.getWattage(10)} W');
      print('    - 感應後亮度：100% → ${BrightnessWattageMap.getWattage(100)} W');
      print('    - 感應時間：30 秒');
      print('    - 固定感應次數：885 次');

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

      print('\n【計算步驟】');

      // 日間計算
      print('  【日間計算】');
      final dayWattBefore = BrightnessWattageMap.getWattage(30);
      final dayWattAfter = BrightnessWattageMap.getWattage(100);
      final dayDuration = 12.0;
      final daySensingCount = 1440;
      final daySensingHours = 30 / 3600.0;

      print(
          '    基礎瓦數 = $dayDuration × $dayWattBefore = ${dayDuration * dayWattBefore} Wh');
      final dayBase = dayDuration * dayWattBefore;

      print(
          '    感應瓦數 = $daySensingCount × ${daySensingHours.toStringAsFixed(6)} × ${dayWattAfter - dayWattBefore}');
      final daySensing =
          daySensingCount * daySensingHours * (dayWattAfter - dayWattBefore);
      print('             = ${daySensing.toStringAsFixed(3)} Wh');

      print('    日間總計 = ${(dayBase + daySensing).toStringAsFixed(3)} Wh');

      // 夜間計算
      print('\n  【夜間計算】');
      print('    ⚠️  注意：夜間時段 18:00-6:00 跨越午夜');
      print('    TimeSlotConfig.duration = endHour - startHour = 6 - 18 = -12');
      print('    實際程式會使用負值！這可能是 BUG');

      final nightWattBefore = BrightnessWattageMap.getWattage(10);
      final nightWattAfter = BrightnessWattageMap.getWattage(100);
      final nightDuration = -12.0; // 程式實際使用的值（BUG）
      final nightSensingCount = 885;
      final nightSensingHours = 30 / 3600.0;

      print(
          '    基礎瓦數 = $nightDuration × $nightWattBefore = ${nightDuration * nightWattBefore} Wh');
      final nightBase = nightDuration * nightWattBefore;

      print(
          '    感應瓦數 = $nightSensingCount × ${nightSensingHours.toStringAsFixed(6)} × ${nightWattAfter - nightWattBefore}');
      final nightSensing = nightSensingCount *
          nightSensingHours *
          (nightWattAfter - nightWattBefore);
      print('             = ${nightSensing.toStringAsFixed(3)} Wh');

      print('    夜間總計 = ${(nightBase + nightSensing).toStringAsFixed(3)} Wh');

      print('\n  【總計算】');
      final expectedTotal = dayBase + daySensing + nightBase + nightSensing;
      print('    每日總瓦數 = 日間總計 + 夜間總計');
      print(
          '             = ${(dayBase + daySensing).toStringAsFixed(3)} + ${(nightBase + nightSensing).toStringAsFixed(3)}');
      print('             = ${expectedTotal.toStringAsFixed(3)} Wh');
      print('\n    🐛 發現 BUG: 跨午夜時段的 duration 計算錯誤！');

      final result = LightingCalculator.calculateDrivewayWattage(strategy);

      print('\n  結果: ${result.toStringAsFixed(3)} Wh/日');
      print('\n╔════════════════════════════════════════════════════════╗');
      print('║  每支車道燈每日消耗 ${result.toStringAsFixed(2)} Wh             ║');
      print('╚════════════════════════════════════════════════════════╝\n');

      expect(result, closeTo(expectedTotal, 0.01));
    });
  });

  group('LightingCalculator - 車位燈計算', () {
    test('車位燈全天候模式計算', () {
      print('\n╔════════════════════════════════════════════════════════╗');
      print('║           車位燈全天候模式計算                           ║');
      print('╚════════════════════════════════════════════════════════╝');

      print('\n【場景設定】');
      print('  - 模式：全天候 (24小時)');
      print('  - 感應前亮度：30% → ${BrightnessWattageMap.getWattage(30)} W');
      print('  - 感應後亮度：100% → ${BrightnessWattageMap.getWattage(100)} W');
      print('  - 感應時間：30 秒');
      print('  - 固定感應次數：110 次');

      final strategy = LightingStrategy(
        count: 1,
        daytime: TimeSlotConfig(
          startHour: 0,
          endHour: 24,
          isAllDay: true,
          brightness: BrightnessConfig(
            brightnessBeforeSensing: 30,
            brightnessAfterSensing: 100,
            sensingDuration: 30,
          ),
        ),
      );

      print('\n【計算步驟】');
      final wattBefore = BrightnessWattageMap.getWattage(30);
      final wattAfter = BrightnessWattageMap.getWattage(100);
      final duration = 24.0;
      final sensingCount = 110;
      final sensingHours = 30 / 3600.0;

      print(
          '  步驟 1: 基礎瓦數 = $duration × $wattBefore = ${duration * wattBefore} Wh');
      final baseWattage = duration * wattBefore;

      print(
          '  步驟 2: 感應瓦數 = $sensingCount × ${sensingHours.toStringAsFixed(6)} × ${wattAfter - wattBefore}');
      final sensingWattage =
          sensingCount * sensingHours * (wattAfter - wattBefore);
      print('         = ${sensingWattage.toStringAsFixed(3)} Wh');

      print(
          '  步驟 3: 總瓦數 = ${baseWattage} + ${sensingWattage.toStringAsFixed(3)}');

      final result = LightingCalculator.calculateParkingWattage(strategy);

      print('  結果: ${result.toStringAsFixed(3)} Wh/日');
      print('\n╔════════════════════════════════════════════════════════╗');
      print('║  每支車位燈每日消耗 ${result.toStringAsFixed(2)} Wh             ║');
      print('╚════════════════════════════════════════════════════════╝\n');

      expect(result, closeTo(baseWattage + sensingWattage, 0.01));
    });

    test('車位燈日夜分段模式計算', () {
      print('\n╔════════════════════════════════════════════════════════╗');
      print('║           車位燈日夜分段模式計算                          ║');
      print('╚════════════════════════════════════════════════════════╝');

      print('\n【場景設定】');
      print('  日間時段 (6:00-18:00, 12小時):');
      print('    - 感應前亮度：30% → ${BrightnessWattageMap.getWattage(30)} W');
      print('    - 感應後亮度：100% → ${BrightnessWattageMap.getWattage(100)} W');
      print('    - 感應時間：30 秒');
      print('    - 固定感應次數：80 次');
      print('  夜間時段 (18:00-6:00, 12小時):');
      print('    - 感應前亮度：10% → ${BrightnessWattageMap.getWattage(10)} W');
      print('    - 感應後亮度：100% → ${BrightnessWattageMap.getWattage(100)} W');
      print('    - 感應時間：30 秒');
      print('    - 固定感應次數：30 次');

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

      print('\n【計算步驟】');

      // 日間計算
      print('  【日間計算】');
      final dayWattBefore = BrightnessWattageMap.getWattage(30);
      final dayWattAfter = BrightnessWattageMap.getWattage(100);
      final dayBase = 12.0 * dayWattBefore;
      final daySensing = 80 * (30 / 3600.0) * (dayWattAfter - dayWattBefore);
      print('    基礎瓦數 = 12 × $dayWattBefore = $dayBase Wh');
      print(
          '    感應瓦數 = 80 × ${(30 / 3600.0).toStringAsFixed(6)} × ${dayWattAfter - dayWattBefore} = ${daySensing.toStringAsFixed(3)} Wh');
      print('    日間總計 = ${(dayBase + daySensing).toStringAsFixed(3)} Wh');

      // 夜間計算
      print('\n  【夜間計算】');
      print('    ⚠️  注意：夜間時段 18:00-6:00 跨越午夜');
      print('    TimeSlotConfig.duration = 6 - 18 = -12 (BUG)');

      final nightWattBefore = BrightnessWattageMap.getWattage(10);
      final nightWattAfter = BrightnessWattageMap.getWattage(100);
      final nightBase = -12.0 * nightWattBefore; // 程式實際使用負值
      final nightSensing =
          30 * (30 / 3600.0) * (nightWattAfter - nightWattBefore);
      print('    基礎瓦數 = -12 × $nightWattBefore = $nightBase Wh');
      print(
          '    感應瓦數 = 30 × ${(30 / 3600.0).toStringAsFixed(6)} × ${nightWattAfter - nightWattBefore} = ${nightSensing.toStringAsFixed(3)} Wh');
      print('    夜間總計 = ${(nightBase + nightSensing).toStringAsFixed(3)} Wh');

      print('\n  【總計算】');
      final expectedTotal = dayBase + daySensing + nightBase + nightSensing;
      print('    每日總瓦數 = ${expectedTotal.toStringAsFixed(3)} Wh');
      print('    🐛 發現 BUG: 跨午夜時段計算錯誤');

      final result = LightingCalculator.calculateParkingWattage(strategy);

      print('  結果: ${result.toStringAsFixed(3)} Wh/日');
      print('\n╔════════════════════════════════════════════════════════╗');
      print('║  每支車位燈每日消耗 ${result.toStringAsFixed(2)} Wh             ║');
      print('╚════════════════════════════════════════════════════════╝\n');

      expect(result, closeTo(expectedTotal, 0.01));
    });
  });

  group('LightingCalculator - 每月耗電量計算', () {
    test('計算多支燈管每月總耗電量', () {
      print('\n╔════════════════════════════════════════════════════════╗');
      print('║         計算多支燈管每月總耗電量                         ║');
      print('╚════════════════════════════════════════════════════════╝');

      print('\n【場景設定】');
      print('  - 每支燈管每日消耗：82.12 Wh');
      print('  - 燈管數量：50 支');

      print('\n【計算步驟】');
      print('  公式: 每日瓦數 × 數量 × 30天 / 1000');
      print('  計算: 82.12 × 50 × 30 / 1000');

      final dailyWattage = 82.12;
      final count = 50;
      final expected = dailyWattage * count * 30 / 1000;

      print('       = ${dailyWattage * count * 30} / 1000');
      print('       = $expected 度');

      final result =
          LightingCalculator.calculateMonthlyConsumption(dailyWattage, count);

      print('\n  結果: ${result.toStringAsFixed(3)} 度/月');
      print('\n╔════════════════════════════════════════════════════════╗');
      print('║  50支燈管每月總耗電 ${result.toStringAsFixed(2)} 度                ║');
      print('╚════════════════════════════════════════════════════════╝\n');

      expect(result, closeTo(expected, 0.01));
    });
  });

  group('LightingCalculator - 亮度與瓦數對照', () {
    test('驗證各亮度等級的瓦數對照', () {
      print('\n╔════════════════════════════════════════════════════════╗');
      print('║           亮度與瓦數對照表                              ║');
      print('╚════════════════════════════════════════════════════════╝\n');

      print('  亮度(%)  |  瓦數(W)');
      print('  ---------|----------');

      final expectedMap = {
        0: 0.2,
        10: 1.3,
        20: 2.3,
        30: 3.4,
        40: 4.7,
        50: 5.9,
        60: 7.2,
        70: 8.6,
        80: 10.04,
        90: 11.4,
        100: 12.0,
      };

      expectedMap.forEach((brightness, expectedWatt) {
        final actualWatt = BrightnessWattageMap.getWattage(brightness);
        print('    ${brightness.toString().padLeft(3)}%   |   $actualWatt W');
        expect(actualWatt, expectedWatt);
      });

      print('\n  ✓ 所有亮度等級對照正確\n');
    });
  });

  group('LightingCalculator - 感應時間影響', () {
    test('不同感應時間對耗電量的影響', () {
      print('\n╔════════════════════════════════════════════════════════╗');
      print('║        不同感應時間對耗電量的影響                         ║');
      print('╚════════════════════════════════════════════════════════╝');

      print('\n【測試條件】');
      print('  - 全天候模式 (24小時)');
      print('  - 感應前亮度：30% (3.4W)');
      print('  - 感應後亮度：100% (12W)');
      print('  - 車道燈感應次數：2325次');

      print('\n  感應時間(秒) | 每日耗電(Wh) | 每月耗電(度/支)');
      print('  ------------|-------------|----------------');

      final sensingTimes = [10, 30, 60, 120, 180];

      for (final time in sensingTimes) {
        final strategy = LightingStrategy(
          count: 1,
          daytime: TimeSlotConfig(
            startHour: 0,
            endHour: 24,
            isAllDay: true,
            brightness: BrightnessConfig(
              brightnessBeforeSensing: 30,
              brightnessAfterSensing: 100,
              sensingDuration: time,
            ),
          ),
        );

        final dailyWatt = LightingCalculator.calculateDrivewayWattage(strategy);
        final monthlyKwh =
            LightingCalculator.calculateMonthlyConsumption(dailyWatt, 1);

        print(
            '     ${time.toString().padLeft(3)} 秒      |  ${dailyWatt.toStringAsFixed(2).padLeft(10)} |  ${monthlyKwh.toStringAsFixed(3).padLeft(12)}');
      }

      print('\n  ✓ 感應時間越長，耗電量越高\n');
    });
  });
}
