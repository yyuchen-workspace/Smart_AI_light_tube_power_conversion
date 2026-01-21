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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),

          // 數量輸入
          TextField(
            controller: countController,
            decoration: InputDecoration(
              labelText: '數量',
              labelStyle: TextStyle(fontSize: 16),
              suffixText: '支',
              suffixStyle: TextStyle(fontSize: 14),
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
            style: TextStyle(fontSize: 16),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: onCountChanged,
          ),
          SizedBox(height: 16),

          // 全天候選項
          Row(
            children: [
              Checkbox(
                value: isAllDay,
                onChanged: onAllDayChanged,
              ),
              SizedBox(width: 8),
              Text(
                '全天候 (24小時)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),

          // 日間設定
          _buildTimeSlotSection(
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
            isDisabled: isAllDay,
          ),

          // 夜間設定 (只在非全天候模式顯示)
          if (!isAllDay) ...[
            SizedBox(height: 16),
            _buildTimeSlotSection(
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
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSlotSection({
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
    bool isDisabled = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 時間選擇區域（灰色背景當禁用時）
        Container(
          padding: EdgeInsets.all(12),
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDisabled ? Colors.grey[500] : Colors.black,
                ),
              ),
              SizedBox(height: 12),

              // 時間選擇（新版：小時分鐘分離輸入）
              Row(
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
                  SizedBox(width: 50),
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
              ),
            ],
          ),
        ),

        SizedBox(height: 12),

        // 亮度設定區域（始終保持白色背景）
        Container(
          padding: EdgeInsets.all(12),
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
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),

              // 感應前亮度
              _buildDropdown(
                label: '感應前亮度',
                value: brightnessBefore,
                items: BrightnessWattageMap.brightnessOptionsBefore,
                onChanged: onBrightnessBeforeChanged,
                suffix: '%',
                isDisabled: false,
              ),
              SizedBox(height: 8),

              // 感應後亮度
              _buildDropdown(
                label: '感應後亮度',
                value: brightnessAfter,
                items: BrightnessWattageMap.brightnessOptionsAfter,
                onChanged: onBrightnessAfterChanged,
                suffix: '%',
                isDisabled: false,
              ),
              SizedBox(height: 8),

              // 感應時間
              _buildDropdown(
                label: '感應時間',
                value: sensingTime,
                items: BrightnessWattageMap.sensingDurationOptions,
                onChanged: onSensingTimeChanged,
                suffix: '秒',
                isDisabled: false,
              ),
            ],
          ),
        ),
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
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: isDisabled ? Colors.grey[500] : Colors.black,
            ),
          ),
        ),
        Expanded(
          flex: 10,
          child: DropdownButtonFormField<int>(
            value: value,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              isDense: false,
              enabled: !isDisabled,
            ),
            style: TextStyle(fontSize: 16, color: Colors.black),
            items: items.map((int item) {
              return DropdownMenuItem<int>(
                value: item,
                child: Text('$item$suffix'),
              );
            }).toList(),
            onChanged: isDisabled ? null : onChanged,
          ),
        ),
      ],
    );
  }
}
