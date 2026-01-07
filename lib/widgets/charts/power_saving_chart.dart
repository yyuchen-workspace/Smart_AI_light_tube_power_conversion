import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// 節電成果環形進度圖
///
/// 顯示節電百分比（環形進度）和關鍵節省數據
/// - 左側：環形圖 + 中央百分比
/// - 右側：節電度數和節省金額
class PowerSavingChart extends StatelessWidget {
  final double savingUnits; // 可節電（度）
  final double savingPercent; // 可節電（%）
  final double totalSaving; // 共節省電費（元）

  const PowerSavingChart({
    Key? key,
    required this.savingUnits,
    required this.savingPercent,
    required this.totalSaving,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(24),
      height: 240,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[50]!, Colors.green[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[400]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 左側：環形進度圖
          Expanded(
            flex: 2,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 環形進度條
                SizedBox(
                  width: 160,
                  height: 160,
                  child: PieChart(
                    PieChartData(
                      startDegreeOffset: -90, // 從頂部開始
                      sectionsSpace: 0,
                      centerSpaceRadius: 55,
                      sections: [
                        // 節省部分（綠色）
                        PieChartSectionData(
                          value: savingPercent,
                          color: Colors.green[600],
                          radius: 25,
                          showTitle: false,
                        ),
                        // 未節省部分（灰色）
                        PieChartSectionData(
                          value: 100 - savingPercent,
                          color: Colors.grey[300],
                          radius: 25,
                          showTitle: false,
                        ),
                      ],
                    ),
                  ),
                ),
                // 中央數據
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${savingPercent.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    Text(
                      '節電率',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 24),

          // 右側：關鍵數據展示
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 標題
                Row(
                  children: [
                    Icon(Icons.bolt, color: Colors.orange[700], size: 24),
                    SizedBox(width: 8),
                    Text(
                      '節能成果',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // 每月節電度數
                _buildSavingDataRow(
                  icon: Icons.electric_bolt,
                  iconColor: Colors.amber[700]!,
                  label: '每月節電',
                  value: '${savingUnits.toStringAsFixed(1)}',
                  unit: '度',
                ),
                SizedBox(height: 12),

                // 每月節省金額（高亮顯示）
                _buildSavingDataRow(
                  icon: Icons.savings,
                  iconColor: Colors.green[700]!,
                  label: '每月節省',
                  value: '${_roundUpFirstDecimal(totalSaving).toStringAsFixed(0)}',
                  unit: '元',
                  isHighlight: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 建構單行節省數據展示
  Widget _buildSavingDataRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String unit,
    bool isHighlight = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlight ? Colors.green[600] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isHighlight
            ? [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: isHighlight ? Colors.white : iconColor, size: 20),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isHighlight ? Colors.white : Colors.grey[700],
            ),
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isHighlight ? Colors.white : Colors.grey[900],
            ),
          ),
          SizedBox(width: 4),
          Text(
            unit,
            style: TextStyle(
              fontSize: 14,
              color: isHighlight ? Colors.white70 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// 向上舍入到第一位小數
  static double _roundUpFirstDecimal(double value) {
    return (value * 10).ceilToDouble() / 10;
  }
}
