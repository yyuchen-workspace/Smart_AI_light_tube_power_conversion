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
  final VoidCallback onDaytimeStartTap;
  final VoidCallback onDaytimeEndTap;
  final int dayBrightnessBefore;
  final int dayBrightnessAfter;
  final int daySensingTime;
  final ValueChanged<int?> onDayBrightnessBeforeChanged;
  final ValueChanged<int?> onDayBrightnessAfterChanged;
  final ValueChanged<int?> onDaySensingTimeChanged;
  final TimeOfDay? nighttimeStart;
  final TimeOfDay? nighttimeEnd;
  final VoidCallback? onNighttimeStartTap;
  final VoidCallback? onNighttimeEndTap;
  final int? nightBrightnessBefore;
  final int? nightBrightnessAfter;
  final int? nightSensingTime;
  final ValueChanged<int?>? onNightBrightnessBeforeChanged;
  final ValueChanged<int?>? onNightBrightnessAfterChanged;
  final ValueChanged<int?>? onNightSensingTimeChanged;
  final ValueChanged<String>? onCountChanged;

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
        side: BorderSide(color: widget.color.withOpacity(0.3), width: 1),
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
                color: widget.color.withOpacity(0.1),
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
                      color: widget.color.withOpacity(0.2),
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: widget.color,
                          ),
                        ),
                        if (widget.subtitle.isNotEmpty) ...[
                          SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: 14,
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
                onDaytimeStartTap: widget.onDaytimeStartTap,
                onDaytimeEndTap: widget.onDaytimeEndTap,
                dayBrightnessBefore: widget.dayBrightnessBefore,
                dayBrightnessAfter: widget.dayBrightnessAfter,
                daySensingTime: widget.daySensingTime,
                onDayBrightnessBeforeChanged: widget.onDayBrightnessBeforeChanged,
                onDayBrightnessAfterChanged: widget.onDayBrightnessAfterChanged,
                onDaySensingTimeChanged: widget.onDaySensingTimeChanged,
                nighttimeStart: widget.nighttimeStart,
                nighttimeEnd: widget.nighttimeEnd,
                onNighttimeStartTap: widget.onNighttimeStartTap,
                onNighttimeEndTap: widget.onNighttimeEndTap,
                nightBrightnessBefore: widget.nightBrightnessBefore,
                nightBrightnessAfter: widget.nightBrightnessAfter,
                nightSensingTime: widget.nightSensingTime,
                onNightBrightnessBeforeChanged: widget.onNightBrightnessBeforeChanged,
                onNightBrightnessAfterChanged: widget.onNightBrightnessAfterChanged,
                onNightSensingTimeChanged: widget.onNightSensingTimeChanged,
                onCountChanged: widget.onCountChanged,
              ),
            ),
        ],
      ),
    );
  }
}
