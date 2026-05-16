/*
 * ============================================================
 * 時間輸入欄位組件
 * ============================================================
 *
 * 使用下拉式列表選擇小時和分鐘
 * - 小時：0-23
 * - 分鐘：0-59
 * - 24小時制
 * - 支援啟用/禁用狀態
 */

import 'package:flutter/material.dart';

class TimeInputField extends StatelessWidget {
  final String label; // 欄位標籤（例如：「開始時間」、「結束時間」）
  final TimeOfDay initialTime; // 初始時間
  final ValueChanged<TimeOfDay> onChanged; // 時間變更回調
  final bool enabled; // 是否啟用

  const TimeInputField({
    Key? key,
    required this.label,
    required this.initialTime,
    required this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  /// 生成小時選項列表 (0-23)
  List<int> get _hourOptions => List.generate(24, (index) => index);

  /// 生成分鐘選項列表 (0-59)
  List<int> get _minuteOptions => List.generate(60, (index) => index);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 標籤
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: enabled ? Colors.grey[700] : Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6),

        // 下拉選單容器
        Row(
          children: [
            // 小時下拉選單
            Expanded(
              child: DropdownButtonFormField<int>(
                value: initialTime.hour,
                decoration: InputDecoration(
                  labelText: '小時',
                  labelStyle: TextStyle(fontSize: 14),
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  enabled: enabled,
                ),
                style: TextStyle(fontSize: 16, color: Colors.black),
                items: _hourOptions.map((hour) {
                  return DropdownMenuItem<int>(
                    value: hour,
                    child: Text(hour.toString().padLeft(2, '0')),
                  );
                }).toList(),
                onChanged: enabled
                    ? (int? newHour) {
                        if (newHour != null) {
                          onChanged(
                              TimeOfDay(hour: newHour, minute: initialTime.minute));
                        }
                      }
                    : null,
              ),
            ),

            SizedBox(width: 12),

            // 分鐘下拉選單
            Expanded(
              child: DropdownButtonFormField<int>(
                value: initialTime.minute,
                decoration: InputDecoration(
                  labelText: '分鐘',
                  labelStyle: TextStyle(fontSize: 14),
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  enabled: enabled,
                ),
                style: TextStyle(fontSize: 16, color: Colors.black),
                items: _minuteOptions.map((minute) {
                  return DropdownMenuItem<int>(
                    value: minute,
                    child: Text(minute.toString().padLeft(2, '0')),
                  );
                }).toList(),
                onChanged: enabled
                    ? (int? newMinute) {
                        if (newMinute != null) {
                          onChanged(
                              TimeOfDay(hour: initialTime.hour, minute: newMinute));
                        }
                      }
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
