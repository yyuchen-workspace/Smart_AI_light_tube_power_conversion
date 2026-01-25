/*
 * ============================================================
 * 步驟一：AI 燈管設定頁面
 * ============================================================
 *
 * 包含傳統燈管設定、車道燈/車位燈亮燈策略設定
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/expandable_light_card.dart';

class Step1AILights extends StatelessWidget {
  // 夏季/非夏季設定
  final bool isSummer;
  final ValueChanged<bool?> onSeasonChanged;

  // 傳統燈管數量控制器
  final TextEditingController traditionalWattController;
  final TextEditingController traditionalLightCountController;
  final ValueChanged<String>? onTraditionalWattChanged;
  final ValueChanged<String>? onTraditionalCountChanged;
  final String traditionalMonthlyConsumption;

  // 車道燈相關參數
  final TextEditingController drivewayCountController;
  final bool drivewayAllDay;
  final ValueChanged<bool?> onDrivewayAllDayChanged;
  final TimeOfDay drivewayDaytimeStart;
  final TimeOfDay drivewayDaytimeEnd;
  final ValueChanged<TimeOfDay> onDrivewayDaytimeStartChanged;
  final ValueChanged<TimeOfDay> onDrivewayDaytimeEndChanged;
  final int drivewayDayBrightnessBefore;
  final int drivewayDayBrightnessAfter;
  final int drivewayDaySensingTime;
  final ValueChanged<int?> onDrivewayDayBrightnessBeforeChanged;
  final ValueChanged<int?> onDrivewayDayBrightnessAfterChanged;
  final ValueChanged<int?> onDrivewayDaySensingTimeChanged;
  final TimeOfDay? drivewayNighttimeStart;
  final TimeOfDay? drivewayNighttimeEnd;
  final ValueChanged<TimeOfDay>? onDrivewayNighttimeStartChanged;
  final ValueChanged<TimeOfDay>? onDrivewayNighttimeEndChanged;
  final int? drivewayNightBrightnessBefore;
  final int? drivewayNightBrightnessAfter;
  final int? drivewayNightSensingTime;
  final ValueChanged<int?>? onDrivewayNightBrightnessBeforeChanged;
  final ValueChanged<int?>? onDrivewayNightBrightnessAfterChanged;
  final ValueChanged<int?>? onDrivewayNightSensingTimeChanged;
  final ValueChanged<String>? onDrivewayCountChanged;
  final TextEditingController drivewayDaySensingCountController;
  final TextEditingController drivewayNightSensingCountController;
  final ValueChanged<String>? onDrivewayDaySensingCountChanged;
  final ValueChanged<String>? onDrivewayNightSensingCountChanged;

  // 車位燈相關參數
  final TextEditingController parkingCountController;
  final bool parkingAllDay;
  final ValueChanged<bool?> onParkingAllDayChanged;
  final TimeOfDay parkingDaytimeStart;
  final TimeOfDay parkingDaytimeEnd;
  final ValueChanged<TimeOfDay> onParkingDaytimeStartChanged;
  final ValueChanged<TimeOfDay> onParkingDaytimeEndChanged;
  final int parkingDayBrightnessBefore;
  final int parkingDayBrightnessAfter;
  final int parkingDaySensingTime;
  final ValueChanged<int?> onParkingDayBrightnessBeforeChanged;
  final ValueChanged<int?> onParkingDayBrightnessAfterChanged;
  final ValueChanged<int?> onParkingDaySensingTimeChanged;
  final TimeOfDay? parkingNighttimeStart;
  final TimeOfDay? parkingNighttimeEnd;
  final ValueChanged<TimeOfDay>? onParkingNighttimeStartChanged;
  final ValueChanged<TimeOfDay>? onParkingNighttimeEndChanged;
  final int? parkingNightBrightnessBefore;
  final int? parkingNightBrightnessAfter;
  final int? parkingNightSensingTime;
  final ValueChanged<int?>? onParkingNightBrightnessBeforeChanged;
  final ValueChanged<int?>? onParkingNightBrightnessAfterChanged;
  final ValueChanged<int?>? onParkingNightSensingTimeChanged;
  final ValueChanged<String>? onParkingCountChanged;
  final TextEditingController parkingDaySensingCountController;
  final TextEditingController parkingNightSensingCountController;
  final ValueChanged<String>? onParkingDaySensingCountChanged;
  final ValueChanged<String>? onParkingNightSensingCountChanged;

  // 資訊按鈕回調（車道燈）
  final VoidCallback? onDrivewayDaytimeInfoTap;
  final VoidCallback? onDrivewayNighttimeInfoTap;

  // 資訊按鈕回調（車位燈）
  final VoidCallback? onParkingDaytimeInfoTap;
  final VoidCallback? onParkingNighttimeInfoTap;

  // 計算結果顯示（車道燈）
  final String? drivewayDaytimeConsumption;
  final String? drivewayNighttimeConsumption;
  final String? drivewayDaytimeTitle;
  final String? drivewayNighttimeTitle;

  // 計算結果顯示（車位燈）
  final String? parkingDaytimeConsumption;
  final String? parkingNighttimeConsumption;
  final String? parkingDaytimeTitle;
  final String? parkingNighttimeTitle;

  // 計算按鈕回調
  final VoidCallback onCalculate;

  const Step1AILights({
    Key? key,
    required this.isSummer,
    required this.onSeasonChanged,
    required this.traditionalWattController,
    required this.traditionalLightCountController,
    this.onTraditionalWattChanged,
    this.onTraditionalCountChanged,
    required this.traditionalMonthlyConsumption,
    required this.drivewayCountController,
    required this.drivewayAllDay,
    required this.onDrivewayAllDayChanged,
    required this.drivewayDaytimeStart,
    required this.drivewayDaytimeEnd,
    required this.onDrivewayDaytimeStartChanged,
    required this.onDrivewayDaytimeEndChanged,
    required this.drivewayDayBrightnessBefore,
    required this.drivewayDayBrightnessAfter,
    required this.drivewayDaySensingTime,
    required this.onDrivewayDayBrightnessBeforeChanged,
    required this.onDrivewayDayBrightnessAfterChanged,
    required this.onDrivewayDaySensingTimeChanged,
    this.drivewayNighttimeStart,
    this.drivewayNighttimeEnd,
    this.onDrivewayNighttimeStartChanged,
    this.onDrivewayNighttimeEndChanged,
    this.drivewayNightBrightnessBefore,
    this.drivewayNightBrightnessAfter,
    this.drivewayNightSensingTime,
    this.onDrivewayNightBrightnessBeforeChanged,
    this.onDrivewayNightBrightnessAfterChanged,
    this.onDrivewayNightSensingTimeChanged,
    this.onDrivewayCountChanged,
    required this.drivewayDaySensingCountController,
    required this.drivewayNightSensingCountController,
    this.onDrivewayDaySensingCountChanged,
    this.onDrivewayNightSensingCountChanged,
    required this.parkingCountController,
    required this.parkingAllDay,
    required this.onParkingAllDayChanged,
    required this.parkingDaytimeStart,
    required this.parkingDaytimeEnd,
    required this.onParkingDaytimeStartChanged,
    required this.onParkingDaytimeEndChanged,
    required this.parkingDayBrightnessBefore,
    required this.parkingDayBrightnessAfter,
    required this.parkingDaySensingTime,
    required this.onParkingDayBrightnessBeforeChanged,
    required this.onParkingDayBrightnessAfterChanged,
    required this.onParkingDaySensingTimeChanged,
    this.parkingNighttimeStart,
    this.parkingNighttimeEnd,
    this.onParkingNighttimeStartChanged,
    this.onParkingNighttimeEndChanged,
    this.parkingNightBrightnessBefore,
    this.parkingNightBrightnessAfter,
    this.parkingNightSensingTime,
    this.onParkingNightBrightnessBeforeChanged,
    this.onParkingNightBrightnessAfterChanged,
    this.onParkingNightSensingTimeChanged,
    this.onParkingCountChanged,
    required this.parkingDaySensingCountController,
    required this.parkingNightSensingCountController,
    this.onParkingDaySensingCountChanged,
    this.onParkingNightSensingCountChanged,
    this.onDrivewayDaytimeInfoTap,
    this.onDrivewayNighttimeInfoTap,
    this.onParkingDaytimeInfoTap,
    this.onParkingNighttimeInfoTap,
    this.drivewayDaytimeConsumption,
    this.drivewayNighttimeConsumption,
    this.drivewayDaytimeTitle,
    this.drivewayNighttimeTitle,
    this.parkingDaytimeConsumption,
    this.parkingNighttimeConsumption,
    this.parkingDaytimeTitle,
    this.parkingNighttimeTitle,
    required this.onCalculate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 頁面標題
          Text(
            '更換 AI 燈管後電力試算',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
          SizedBox(height: 4),
          /*
          Text(
            '請填寫傳統燈管數量及 AI 燈管亮燈策略',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          */
          SizedBox(height: 16),

          // 夏季/非夏季選擇
          _buildSectionTitle('電價季節'),
          SizedBox(height: 12),
          // 根據螢幕寬度決定排列方式
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;

              if (isMobile) {
                // 手機版：垂直排列
                return Column(
                  children: [
                    CheckboxListTile(
                      title: Text('夏季 (6-9月)', style: TextStyle(fontSize: 16)),
                      subtitle: Text('每度 4.08 元', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      value: isSummer,
                      onChanged: onSeasonChanged,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: isSummer ? Colors.blue : Colors.grey[300]!, width: 2),
                      ),
                      tileColor: isSummer ? Colors.blue[50] : Colors.grey[50],
                    ),
                    SizedBox(height: 12),
                    CheckboxListTile(
                      title: Text('非夏季 (1-5月、10-12月)', style: TextStyle(fontSize: 16)),
                      subtitle: Text('每度 3.87 元', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      value: !isSummer,
                      onChanged: (value) => onSeasonChanged(value == true ? false : true),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: !isSummer ? Colors.orange : Colors.grey[300]!, width: 2),
                      ),
                      tileColor: !isSummer ? Colors.orange[50] : Colors.grey[50],
                    ),
                  ],
                );
              } else {
                // 桌面版：水平排列
                return Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: Text('夏季 (6-9月)', style: TextStyle(fontSize: 16)),
                        subtitle: Text('每度 4.08 元', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                        value: isSummer,
                        onChanged: onSeasonChanged,
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: isSummer ? Colors.blue : Colors.grey[300]!, width: 2),
                        ),
                        tileColor: isSummer ? Colors.blue[50] : Colors.grey[50],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: CheckboxListTile(
                        title: Text('非夏季 (1-5月、10-12月)', style: TextStyle(fontSize: 16)),
                        subtitle: Text('每度 3.87 元', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                        value: !isSummer,
                        onChanged: (value) => onSeasonChanged(value == true ? false : true),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: !isSummer ? Colors.orange : Colors.grey[300]!, width: 2),
                        ),
                        tileColor: !isSummer ? Colors.orange[50] : Colors.grey[50],
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          SizedBox(height: 24),

          // 傳統燈管設定
          _buildSectionTitle('原燈管'),
          SizedBox(height: 16),
          Row(
            children: [
              // 瓦數
              Expanded(
                child: TextField(
                  controller: traditionalWattController,
                  onTap: () {
                    // 點擊時自動全選文字
                    traditionalWattController.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: traditionalWattController.text.length,
                    );
                  },
                  decoration: InputDecoration(
                    labelText: '目前使用燈管瓦數',
                    labelStyle: const TextStyle(fontSize: 16),
                    suffixText: 'W',
                    suffixStyle: const TextStyle(fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  style: const TextStyle(fontSize: 16),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                  ],
                  onChanged: onTraditionalWattChanged,
                ),
              ),
              const SizedBox(width: 16),
              // 數量
              Expanded(
                child: TextField(
                  controller: traditionalLightCountController,
                  onTap: () {
                    // 點擊時自動全選文字
                    traditionalLightCountController.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: traditionalLightCountController.text.length,
                    );
                  },
                  decoration: InputDecoration(
                    labelText: '數量',
                    labelStyle: const TextStyle(fontSize: 16),
                    suffixText: '支',
                    suffixStyle: const TextStyle(fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  style: const TextStyle(fontSize: 16),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: onTraditionalCountChanged,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // 每月耗電顯示
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '每月耗電',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  traditionalMonthlyConsumption,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32),

          // AI 燈管亮燈策略
          _buildSectionTitle('AI 燈管亮燈策略'),
          SizedBox(height: 16),

          // 車道燈可展開卡片
          ExpandableLightCard(
            title: '車道燈',
            subtitle: _getSubtitle(drivewayCountController.text),
            icon: Icons.route,
            color: Colors.green,
            countController: drivewayCountController,
            isAllDay: drivewayAllDay,
            onAllDayChanged: onDrivewayAllDayChanged,
            daytimeStart: drivewayDaytimeStart,
            daytimeEnd: drivewayDaytimeEnd,
            onDaytimeStartChanged: onDrivewayDaytimeStartChanged,
            onDaytimeEndChanged: onDrivewayDaytimeEndChanged,
            dayBrightnessBefore: drivewayDayBrightnessBefore,
            dayBrightnessAfter: drivewayDayBrightnessAfter,
            daySensingTime: drivewayDaySensingTime,
            onDayBrightnessBeforeChanged: onDrivewayDayBrightnessBeforeChanged,
            onDayBrightnessAfterChanged: onDrivewayDayBrightnessAfterChanged,
            onDaySensingTimeChanged: onDrivewayDaySensingTimeChanged,
            nighttimeStart: drivewayNighttimeStart,
            nighttimeEnd: drivewayNighttimeEnd,
            onNighttimeStartChanged: onDrivewayNighttimeStartChanged,
            onNighttimeEndChanged: onDrivewayNighttimeEndChanged,
            nightBrightnessBefore: drivewayNightBrightnessBefore,
            nightBrightnessAfter: drivewayNightBrightnessAfter,
            nightSensingTime: drivewayNightSensingTime,
            onNightBrightnessBeforeChanged:
                onDrivewayNightBrightnessBeforeChanged,
            onNightBrightnessAfterChanged:
                onDrivewayNightBrightnessAfterChanged,
            onNightSensingTimeChanged: onDrivewayNightSensingTimeChanged,
            onCountChanged: onDrivewayCountChanged,
            daySensingCountController: drivewayDaySensingCountController,
            nightSensingCountController: drivewayNightSensingCountController,
            onDaySensingCountChanged: onDrivewayDaySensingCountChanged,
            onNightSensingCountChanged: onDrivewayNightSensingCountChanged,
            onDaytimeInfoTap: onDrivewayDaytimeInfoTap,
            onNighttimeInfoTap: onDrivewayNighttimeInfoTap,
            daytimeMonthlyConsumption: drivewayDaytimeConsumption,
            nighttimeMonthlyConsumption: drivewayNighttimeConsumption,
            daytimeResultTitle: drivewayDaytimeTitle,
            nighttimeResultTitle: drivewayNighttimeTitle,
          ),
          SizedBox(height: 16),

          // 車位燈可展開卡片
          ExpandableLightCard(
            title: '車位燈',
            subtitle: _getSubtitle(parkingCountController.text),
            icon: Icons.local_parking,
            color: Colors.orange,
            countController: parkingCountController,
            isAllDay: parkingAllDay,
            onAllDayChanged: onParkingAllDayChanged,
            daytimeStart: parkingDaytimeStart,
            daytimeEnd: parkingDaytimeEnd,
            onDaytimeStartChanged: onParkingDaytimeStartChanged,
            onDaytimeEndChanged: onParkingDaytimeEndChanged,
            dayBrightnessBefore: parkingDayBrightnessBefore,
            dayBrightnessAfter: parkingDayBrightnessAfter,
            daySensingTime: parkingDaySensingTime,
            onDayBrightnessBeforeChanged: onParkingDayBrightnessBeforeChanged,
            onDayBrightnessAfterChanged: onParkingDayBrightnessAfterChanged,
            onDaySensingTimeChanged: onParkingDaySensingTimeChanged,
            nighttimeStart: parkingNighttimeStart,
            nighttimeEnd: parkingNighttimeEnd,
            onNighttimeStartChanged: onParkingNighttimeStartChanged,
            onNighttimeEndChanged: onParkingNighttimeEndChanged,
            nightBrightnessBefore: parkingNightBrightnessBefore,
            nightBrightnessAfter: parkingNightBrightnessAfter,
            nightSensingTime: parkingNightSensingTime,
            onNightBrightnessBeforeChanged:
                onParkingNightBrightnessBeforeChanged,
            onNightBrightnessAfterChanged: onParkingNightBrightnessAfterChanged,
            onNightSensingTimeChanged: onParkingNightSensingTimeChanged,
            onCountChanged: onParkingCountChanged,
            daySensingCountController: parkingDaySensingCountController,
            nightSensingCountController: parkingNightSensingCountController,
            onDaySensingCountChanged: onParkingDaySensingCountChanged,
            onNightSensingCountChanged: onParkingNightSensingCountChanged,
            onDaytimeInfoTap: onParkingDaytimeInfoTap,
            onNighttimeInfoTap: onParkingNighttimeInfoTap,
            daytimeMonthlyConsumption: parkingDaytimeConsumption,
            nighttimeMonthlyConsumption: parkingNighttimeConsumption,
            daytimeResultTitle: parkingDaytimeTitle,
            nighttimeResultTitle: parkingNighttimeTitle,
          ),
          SizedBox(height: 32),

          // 計算按鈕
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCalculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                '計算結果',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }

  String _getSubtitle(String count) {
    if (count.isEmpty || count == '0') {
      return '未設定';
    }
    return '$count 支';
  }
}
