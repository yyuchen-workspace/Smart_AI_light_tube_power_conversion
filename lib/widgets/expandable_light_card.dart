/*
 * ============================================================
 * 可展開燈管設定卡片
 * ============================================================
 *
 * 用於車道燈/車位燈的展開式設定卡片
 * 預設收合，點擊後展開顯示詳細設定
 */

import 'package:flutter/material.dart';
import 'lighting_strategy_config.dart';

class ExpandableLightCard extends StatefulWidget {
  final String title; // 卡片標題（車道燈/車位燈）
  final String subtitle; // 副標題（例如：3組）
  final IconData icon; // 圖示
  final Color color; // 主題色

  // LightingStrategyConfig 所需的所有參數
  final TextEditingController countController;
  final bool isAllDay;
  final ValueChanged<bool?> onAllDayChanged;
  final TimeOfDay daytimeStart;
  final TimeOfDay daytimeEnd;
  final ValueChanged<TimeOfDay> onDaytimeStartChanged;
  final ValueChanged<TimeOfDay> onDaytimeEndChanged;
  final int dayBrightnessBefore;
  final int dayBrightnessAfter;
  final int daySensingTime;
  final ValueChanged<int?> onDayBrightnessBeforeChanged;
  final ValueChanged<int?> onDayBrightnessAfterChanged;
  final ValueChanged<int?> onDaySensingTimeChanged;
  final TimeOfDay? nighttimeStart;
  final TimeOfDay? nighttimeEnd;
  final ValueChanged<TimeOfDay>? onNighttimeStartChanged;
  final ValueChanged<TimeOfDay>? onNighttimeEndChanged;
  final int? nightBrightnessBefore;
  final int? nightBrightnessAfter;
  final int? nightSensingTime;
  final ValueChanged<int?>? onNightBrightnessBeforeChanged;
  final ValueChanged<int?>? onNightBrightnessAfterChanged;
  final ValueChanged<int?>? onNightSensingTimeChanged;
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

  const ExpandableLightCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
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
  _ExpandableLightCardState createState() => _ExpandableLightCardState();
}

class _ExpandableLightCardState extends State<ExpandableLightCard> {
  bool _isExpanded = false; // 預設收合

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: widget.color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          // 可點擊的標題列
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(12),
              bottom: _isExpanded ? Radius.zero : Radius.circular(12),
            ),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(12),
                  bottom: _isExpanded ? Radius.zero : Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  // 圖示
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 24),
                  ),
                  SizedBox(width: 12),

                  // 標題和副標題
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: widget.color,
                          ),
                        ),
                        if (widget.subtitle.isNotEmpty) ...[
                          SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // 展開/收合圖示
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: widget.color,
                  ),
                ],
              ),
            ),
          ),

          // 可展開的內容
          if (_isExpanded)
            Padding(
              padding: EdgeInsets.all(16),
              child: LightingStrategyConfig(
                title: widget.title,
                countController: widget.countController,
                isAllDay: widget.isAllDay,
                onAllDayChanged: widget.onAllDayChanged,
                daytimeStart: widget.daytimeStart,
                daytimeEnd: widget.daytimeEnd,
                onDaytimeStartChanged: widget.onDaytimeStartChanged,
                onDaytimeEndChanged: widget.onDaytimeEndChanged,
                dayBrightnessBefore: widget.dayBrightnessBefore,
                dayBrightnessAfter: widget.dayBrightnessAfter,
                daySensingTime: widget.daySensingTime,
                onDayBrightnessBeforeChanged: widget.onDayBrightnessBeforeChanged,
                onDayBrightnessAfterChanged: widget.onDayBrightnessAfterChanged,
                onDaySensingTimeChanged: widget.onDaySensingTimeChanged,
                nighttimeStart: widget.nighttimeStart,
                nighttimeEnd: widget.nighttimeEnd,
                onNighttimeStartChanged: widget.onNighttimeStartChanged,
                onNighttimeEndChanged: widget.onNighttimeEndChanged,
                nightBrightnessBefore: widget.nightBrightnessBefore,
                nightBrightnessAfter: widget.nightBrightnessAfter,
                nightSensingTime: widget.nightSensingTime,
                onNightBrightnessBeforeChanged: widget.onNightBrightnessBeforeChanged,
                onNightBrightnessAfterChanged: widget.onNightBrightnessAfterChanged,
                onNightSensingTimeChanged: widget.onNightSensingTimeChanged,
                onCountChanged: widget.onCountChanged,
                daySensingCountController: widget.daySensingCountController,
                nightSensingCountController: widget.nightSensingCountController,
                onDaySensingCountChanged: widget.onDaySensingCountChanged,
                onNightSensingCountChanged: widget.onNightSensingCountChanged,
                onDaytimeInfoTap: widget.onDaytimeInfoTap,
                onNighttimeInfoTap: widget.onNighttimeInfoTap,
                daytimeMonthlyConsumption: widget.daytimeMonthlyConsumption,
                nighttimeMonthlyConsumption: widget.nighttimeMonthlyConsumption,
                daytimeResultTitle: widget.daytimeResultTitle,
                nighttimeResultTitle: widget.nighttimeResultTitle,
              ),
            ),
        ],
      ),
    );
  }
}
