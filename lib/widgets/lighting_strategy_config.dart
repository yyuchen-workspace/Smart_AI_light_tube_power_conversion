/*
 * ============================================================
 * 亮燈策略設定元件
 * ============================================================
 *
 * 用於設定車道燈/車位燈的亮燈策略
 * 包含時間選擇、亮度設定、感應時間設定
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/brightness_wattage_map.dart';
import 'common/time_input_field.dart';

class LightingStrategyConfig extends StatelessWidget {
  final String title; // 標題 (車道燈/車位燈)
  final TextEditingController countController; // 數量控制器

  // 全天候模式
  final bool isAllDay;
  final ValueChanged<bool?> onAllDayChanged;

  // 日間時段
  final TimeOfDay daytimeStart;
  final TimeOfDay daytimeEnd;
  final ValueChanged<TimeOfDay> onDaytimeStartChanged;
  final ValueChanged<TimeOfDay> onDaytimeEndChanged;

  // 日間亮度
  final int dayBrightnessBefore;
  final int dayBrightnessAfter;
  final int daySensingTime;
  final ValueChanged<int?> onDayBrightnessBeforeChanged;
  final ValueChanged<int?> onDayBrightnessAfterChanged;
  final ValueChanged<int?> onDaySensingTimeChanged;

  // 夜間時段 (可選)
  final TimeOfDay? nighttimeStart;
  final TimeOfDay? nighttimeEnd;
  final ValueChanged<TimeOfDay>? onNighttimeStartChanged;
  final ValueChanged<TimeOfDay>? onNighttimeEndChanged;

  // 夜間亮度 (可選)
  final int? nightBrightnessBefore;
  final int? nightBrightnessAfter;
  final int? nightSensingTime;
  final ValueChanged<int?>? onNightBrightnessBeforeChanged;
  final ValueChanged<int?>? onNightBrightnessAfterChanged;
  final ValueChanged<int?>? onNightSensingTimeChanged;

  // 通用回調
  final ValueChanged<String>? onCountChanged;

  // 模擬人車感應次數
  final TextEditingController daySensingCountController;
  final TextEditingController? nightSensingCountController;
  final ValueChanged<String>? onDaySensingCountChanged;
  final ValueChanged<String>? onNightSensingCountChanged;

  // 資訊按鈕回調
  final VoidCallback? onDaytimeInfoTap;
  final VoidCallback? onNighttimeInfoTap;

  // 計算結果顯示
  final String? daytimeMonthlyConsumption;
  final String? nighttimeMonthlyConsumption;
  final String? daytimeResultTitle;
  final String? nighttimeResultTitle;

  const LightingStrategyConfig({
    Key? key,
    required this.title,
    required this.countController,
    required this.isAllDay,
    required this.onAllDayChanged,
    required this.daytimeStart,
    required this.daytimeEnd,
    required this.onDaytimeStartChanged,
    required this.onDaytimeEndChanged,
    required this.dayBrightnessBefore,
    required this.dayBrightnessAfter,
    required this.daySensingTime,
    required this.onDayBrightnessBeforeChanged,
    required this.onDayBrightnessAfterChanged,
    required this.onDaySensingTimeChanged,
    this.nighttimeStart,
    this.nighttimeEnd,
    this.onNighttimeStartChanged,
    this.onNighttimeEndChanged,
    this.nightBrightnessBefore,
    this.nightBrightnessAfter,
    this.nightSensingTime,
    this.onNightBrightnessBeforeChanged,
    this.onNightBrightnessAfterChanged,
    this.onNightSensingTimeChanged,
    this.onCountChanged,
    required this.daySensingCountController,
    this.nightSensingCountController,
    this.onDaySensingCountChanged,
    this.onNightSensingCountChanged,
    this.onDaytimeInfoTap,
    this.onNighttimeInfoTap,
    this.daytimeMonthlyConsumption,
    this.nighttimeMonthlyConsumption,
    this.daytimeResultTitle,
    this.nighttimeResultTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // 根據螢幕尺寸調整間距
    final containerPadding = isMobile ? 12.0 : 16.0;
    final sectionSpacing = isMobile ? 10.0 : 12.0;
    final titleFontSize = isMobile ? 16.0 : 18.0;

    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 標題
          Text(
            title,
            style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: sectionSpacing),

          // 數量輸入
          TextField(
            controller: countController,
            onTap: () {
              // 點擊時自動全選文字
              countController.selection = TextSelection(
                baseOffset: 0,
                extentOffset: countController.text.length,
              );
            },
            decoration: InputDecoration(
              labelText: '數量',
              labelStyle: const TextStyle(fontSize: 16),
              suffixText: '支',
              suffixStyle: const TextStyle(fontSize: 14),
              border: const OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
            style: const TextStyle(fontSize: 16),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: onCountChanged,
          ),
          SizedBox(height: sectionSpacing),

          // 全天候選項
          Row(
            children: [
              Checkbox(
                value: isAllDay,
                onChanged: onAllDayChanged,
              ),
              const SizedBox(width: 8),
              Text(
                '全天候 (24小時)',
                style: TextStyle(
                  fontSize: isMobile ? 15.0 : 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 6 : 8),

          // 日間設定
          _buildTimeSlotSection(
            context: context,
            title: '日間時段',
            start: daytimeStart,
            end: daytimeEnd,
            onStartChanged: onDaytimeStartChanged,
            onEndChanged: onDaytimeEndChanged,
            brightnessBefore: dayBrightnessBefore,
            brightnessAfter: dayBrightnessAfter,
            sensingTime: daySensingTime,
            onBrightnessBeforeChanged: onDayBrightnessBeforeChanged,
            onBrightnessAfterChanged: onDayBrightnessAfterChanged,
            onSensingTimeChanged: onDaySensingTimeChanged,
            sensingCountController: daySensingCountController,
            onSensingCountChanged: onDaySensingCountChanged,
            onInfoTap: onDaytimeInfoTap,
            monthlyConsumption: daytimeMonthlyConsumption,
            resultTitle: daytimeResultTitle,
            isDisabled: isAllDay,
          ),

          // 夜間設定 (只在非全天候模式顯示)
          if (!isAllDay) ...[
            SizedBox(height: sectionSpacing),
            _buildTimeSlotSection(
              context: context,
              title: '夜間時段',
              start: nighttimeStart ?? TimeOfDay(hour: 18, minute: 0),
              end: nighttimeEnd ?? TimeOfDay(hour: 6, minute: 0),
              onStartChanged: onNighttimeStartChanged ?? (_) {},
              onEndChanged: onNighttimeEndChanged ?? (_) {},
              brightnessBefore: nightBrightnessBefore ?? 10,
              brightnessAfter: nightBrightnessAfter ?? 100,
              sensingTime: nightSensingTime ?? 30,
              onBrightnessBeforeChanged:
                  onNightBrightnessBeforeChanged ?? (_) {},
              onBrightnessAfterChanged: onNightBrightnessAfterChanged ?? (_) {},
              onSensingTimeChanged: onNightSensingTimeChanged ?? (_) {},
              sensingCountController: nightSensingCountController ?? TextEditingController(text: '0'),
              onSensingCountChanged: onNightSensingCountChanged,
              onInfoTap: onNighttimeInfoTap,
              monthlyConsumption: nighttimeMonthlyConsumption,
              resultTitle: nighttimeResultTitle,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSlotSection({
    required BuildContext context,
    required String title,
    required TimeOfDay start,
    required TimeOfDay end,
    required ValueChanged<TimeOfDay> onStartChanged,
    required ValueChanged<TimeOfDay> onEndChanged,
    required int brightnessBefore,
    required int brightnessAfter,
    required int sensingTime,
    required ValueChanged<int?> onBrightnessBeforeChanged,
    required ValueChanged<int?> onBrightnessAfterChanged,
    required ValueChanged<int?> onSensingTimeChanged,
    required TextEditingController sensingCountController,
    ValueChanged<String>? onSensingCountChanged,
    VoidCallback? onInfoTap,
    String? monthlyConsumption,
    String? resultTitle,
    bool isDisabled = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // 手機版縮小間距和字體
    final containerPadding = isMobile ? 10.0 : 12.0;
    final sectionSpacing = isMobile ? 10.0 : 12.0;
    final titleFontSize = isMobile ? 15.0 : 16.0;
    final labelFontSize = isMobile ? 14.0 : 15.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 時間選擇區域（灰色背景當禁用時）
        Container(
          padding: EdgeInsets.all(containerPadding),
          decoration: BoxDecoration(
            color: isDisabled ? Colors.grey[200] : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 時段標題
              Text(
                title,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: isDisabled ? Colors.grey[500] : Colors.black,
                ),
              ),
              SizedBox(height: sectionSpacing),

              // 時間選擇（新版：小時分鐘分離輸入）
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 400;

                  if (isMobile) {
                    // 手機版：垂直排列
                    return Column(
                      children: [
                        TimeInputField(
                          label: '開始時間',
                          initialTime: start,
                          onChanged: onStartChanged,
                          enabled: !isDisabled,
                        ),
                        const SizedBox(height: 8),
                        TimeInputField(
                          label: '結束時間',
                          initialTime: end,
                          onChanged: onEndChanged,
                          enabled: !isDisabled,
                        ),
                      ],
                    );
                  } else {
                    // 桌面版：水平排列
                    return Row(
                      children: [
                        SizedBox(
                          width: 150,
                          child: TimeInputField(
                            label: '開始時間',
                            initialTime: start,
                            onChanged: onStartChanged,
                            enabled: !isDisabled,
                          ),
                        ),
                        const SizedBox(width: 50),
                        SizedBox(
                          width: 150,
                          child: TimeInputField(
                            label: '結束時間',
                            initialTime: end,
                            onChanged: onEndChanged,
                            enabled: !isDisabled,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),

        SizedBox(height: sectionSpacing),

        // 亮度設定區域（始終保持白色背景）
        Container(
          padding: EdgeInsets.all(containerPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 亮度設定標題
              Text(
                '亮度設定',
                style: TextStyle(
                  fontSize: labelFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: isMobile ? 6 : 8),

              // 感應前亮度
              _buildDropdown(
                label: '感應前亮度',
                value: brightnessBefore,
                items: BrightnessWattageMap.brightnessOptionsBefore,
                onChanged: onBrightnessBeforeChanged,
                suffix: '%',
                isDisabled: false,
              ),
              SizedBox(height: isMobile ? 6 : 8),

              // 感應後亮度
              _buildDropdown(
                label: '感應後亮度',
                value: brightnessAfter,
                items: BrightnessWattageMap.brightnessOptionsAfter,
                onChanged: onBrightnessAfterChanged,
                suffix: '%',
                isDisabled: false,
              ),
              SizedBox(height: isMobile ? 6 : 8),

              // 感應時間
              _buildDropdown(
                label: '感應時間',
                value: sensingTime,
                items: BrightnessWattageMap.sensingDurationOptions,
                onChanged: onSensingTimeChanged,
                suffix: '秒',
                isDisabled: false,
              ),
              SizedBox(height: isMobile ? 6 : 8),

              // 模擬人車感應次數
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '模擬人車感應次數',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700], // 永遠保持黑色，不受全天候模式影響
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: sensingCountController,
                    onTap: () {
                      sensingCountController.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: sensingCountController.text.length,
                      );
                    },
                    decoration: InputDecoration(
                      labelText: '次數',
                      labelStyle: TextStyle(fontSize: 14),
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      enabled: true, // 改為永遠可編輯，即使在全天候模式下
                      suffixText: '次',
                      suffixStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    style: TextStyle(fontSize: 16, color: Colors.black),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: onSensingCountChanged,
                  ),
                ],
              ),
            ],
          ),
        ),

        // 計算結果顯示區域
        if (resultTitle != null) ...[
          SizedBox(height: sectionSpacing),
          Container(
            padding: EdgeInsets.all(containerPadding),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 標題與資訊按鈕（不可擴展）
                Row(
                  children: [
                    Text(
                      resultTitle,
                      style: TextStyle(
                        fontSize: labelFontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    if (onInfoTap != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onInfoTap,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              'i',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(width: 8),
                // 數值（可擴展，自動縮放）
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      monthlyConsumption ?? '0.00 度',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required int value,
    required List<int> items,
    required ValueChanged<int?> onChanged,
    required String suffix,
    bool isDisabled = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 標題在上方（與 TimeInputField 一致）
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDisabled ? Colors.grey[500] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 6),
        // 下拉選單
        DropdownButtonFormField<int>(
          value: value,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            isDense: true,
            enabled: !isDisabled,
          ),
          style: const TextStyle(fontSize: 16, color: Colors.black),
          items: items.map((int item) {
            return DropdownMenuItem<int>(
              value: item,
              child: Text('$item$suffix'),
            );
          }).toList(),
          onChanged: isDisabled ? null : onChanged,
        ),
      ],
    );
  }
}
