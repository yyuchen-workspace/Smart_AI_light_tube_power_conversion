/*
 * ============================================================
 * 亮燈策略設定元件
 * ============================================================
 *
 * 用於設定車道燈/車位燈的亮燈策略
 * 包含時間選擇、亮度設定、感應時間設定
 */

import 'package:flutter/material.dart';
import '../constants/brightness_wattage_map.dart';

class LightingStrategyConfig extends StatelessWidget {
  final String title; // 標題 (車道燈/車位燈)
  final TextEditingController countController; // 數量控制器

  // 全天候模式
  final bool isAllDay;
  final ValueChanged<bool?> onAllDayChanged;

  // 日間時段
  final TimeOfDay daytimeStart;
  final TimeOfDay daytimeEnd;
  final VoidCallback onDaytimeStartTap;
  final VoidCallback onDaytimeEndTap;

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
  final VoidCallback? onNighttimeStartTap;
  final VoidCallback? onNighttimeEndTap;

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
    required this.onDaytimeStartTap,
    required this.onDaytimeEndTap,
    required this.dayBrightnessBefore,
    required this.dayBrightnessAfter,
    required this.daySensingTime,
    required this.onDayBrightnessBeforeChanged,
    required this.onDayBrightnessAfterChanged,
    required this.onDaySensingTimeChanged,
    this.nighttimeStart,
    this.nighttimeEnd,
    this.onNighttimeStartTap,
    this.onNighttimeEndTap,
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),

          // 數量輸入
          TextField(
            controller: countController,
            decoration: InputDecoration(
              labelText: '數量',
              suffixText: '支',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: onCountChanged,
          ),
          SizedBox(height: 16),

          // 全天候選項
          CheckboxListTile(
            title: Text('全天候 (24小時)'),
            value: isAllDay,
            onChanged: onAllDayChanged,
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
          SizedBox(height: 8),

          // 日間設定
          _buildTimeSlotSection(
            title: '日間時段',
            start: daytimeStart,
            end: daytimeEnd,
            onStartTap: onDaytimeStartTap,
            onEndTap: onDaytimeEndTap,
            brightnessBefore: dayBrightnessBefore,
            brightnessAfter: dayBrightnessAfter,
            sensingTime: daySensingTime,
            onBrightnessBeforeChanged: onDayBrightnessBeforeChanged,
            onBrightnessAfterChanged: onDayBrightnessAfterChanged,
            onSensingTimeChanged: onDaySensingTimeChanged,
          ),

          // 夜間設定 (只在非全天候模式顯示)
          if (!isAllDay) ...[
            SizedBox(height: 16),
            _buildTimeSlotSection(
              title: '夜間時段',
              start: nighttimeStart ?? TimeOfDay(hour: 18, minute: 0),
              end: nighttimeEnd ?? TimeOfDay(hour: 6, minute: 0),
              onStartTap: onNighttimeStartTap ?? () {},
              onEndTap: onNighttimeEndTap ?? () {},
              brightnessBefore: nightBrightnessBefore ?? 10,
              brightnessAfter: nightBrightnessAfter ?? 100,
              sensingTime: nightSensingTime ?? 30,
              onBrightnessBeforeChanged: onNightBrightnessBeforeChanged ?? (_) {},
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
    required VoidCallback onStartTap,
    required VoidCallback onEndTap,
    required int brightnessBefore,
    required int brightnessAfter,
    required int sensingTime,
    required ValueChanged<int?> onBrightnessBeforeChanged,
    required ValueChanged<int?> onBrightnessAfterChanged,
    required ValueChanged<int?> onSensingTimeChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 時段標題
          Text(
            title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),

          // 時間選擇
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onStartTap,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: '開始',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Text(_formatTimeOfDay(start)),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text('至'),
              SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: onEndTap,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: '結束',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Text(_formatTimeOfDay(end)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // 亮度設定標題
          Text(
            '亮度設定',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),

          // 感應前亮度
          _buildDropdown(
            label: '感應前亮度',
            value: brightnessBefore,
            items: BrightnessWattageMap.brightnessOptions,
            onChanged: onBrightnessBeforeChanged,
            suffix: '%',
          ),
          SizedBox(height: 8),

          // 感應後亮度
          _buildDropdown(
            label: '感應後亮度',
            value: brightnessAfter,
            items: BrightnessWattageMap.brightnessOptions,
            onChanged: onBrightnessAfterChanged,
            suffix: '%',
          ),
          SizedBox(height: 8),

          // 感應時間
          _buildDropdown(
            label: '感應時間',
            value: sensingTime,
            items: BrightnessWattageMap.sensingDurationOptions,
            onChanged: onSensingTimeChanged,
            suffix: '秒',
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required int value,
    required List<int> items,
    required ValueChanged<int?> onChanged,
    required String suffix,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: TextStyle(fontSize: 12)),
        ),
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<int>(
            value: value,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            items: items.map((int item) {
              return DropdownMenuItem<int>(
                value: item,
                child: Text('$item$suffix'),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
