import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// 節電成果環形進度圖
///
/// 顯示節電百分比（環形進度）和關鍵節省數據
/// - 上方：環形圖 + 中央百分比
/// - 下方：節電前度數、更換前電費、AI燈耗電、更換後電費、每月節電、共節省電費
class PowerSavingChart extends StatelessWidget {
  final double traditionalMonthlyConsumption; // 節電前度數（舊燈管每月耗電，度）
  final double aiMonthlyConsumption; // AI燈管每月耗電（度）
  final double monthlySavings; // 每月節電量（度）
  final double savingsRate; // 節電率（%）
  final double oldMonthlyCost; // 更換前每月電費（元）
  final double newMonthlyCost; // 更換後每月電費（元）

  const PowerSavingChart({
    Key? key,
    required this.traditionalMonthlyConsumption,
    required this.aiMonthlyConsumption,
    required this.monthlySavings,
    required this.savingsRate,
    required this.oldMonthlyCost,
    required this.newMonthlyCost,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 判斷是否為負節電率（AI燈管反而更耗電）
    final bool isNegativeSavings = savingsRate < 0;

    return Container(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isNegativeSavings
              ? [Colors.grey[200]!, Colors.grey[300]!]
              : [Colors.green[50]!, Colors.green[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNegativeSavings ? Colors.grey[400]! : Colors.green[400]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isNegativeSavings
                ? Colors.grey.withValues(alpha: 0.2)
                : Colors.green.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 上方：環形進度圖
          SizedBox(
            height: 180,
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
                        // 節省部分
                        PieChartSectionData(
                          value: isNegativeSavings
                              ? savingsRate.abs().clamp(0, 100)
                              : (savingsRate >= 100 ? 100 : savingsRate),
                          color: isNegativeSavings ? Colors.grey[500] : Colors.green[600],
                          radius: 25,
                          showTitle: false,
                        ),
                        // 未節省部分（如果超過100%或為負數則不顯示）
                        if (savingsRate < 100 && !isNegativeSavings)
                          PieChartSectionData(
                            value: 100 - savingsRate,
                            color: Colors.grey[300],
                            radius: 25,
                            showTitle: false,
                          ),
                        // 負數時的未節省部分
                        if (isNegativeSavings && savingsRate.abs() < 100)
                          PieChartSectionData(
                            value: 100 - savingsRate.abs(),
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
                      '${savingsRate.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: isNegativeSavings ? Colors.grey[600] : Colors.green[700],
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

          SizedBox(height: 8),

          // 下方：表格式數據展示
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // 表頭
                Row(
                  children: [
                    Expanded(flex: 3, child: SizedBox()), // 空白（左側標籤區）
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                          '原燈管',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                          'AI燈管',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(height: 20, thickness: 2),

                // 第一行：度數
                _buildTableRow(
                  label: '度數',
                  oldValue: '${traditionalMonthlyConsumption.toStringAsFixed(1)}',
                  newValue: '${aiMonthlyConsumption.toStringAsFixed(1)}',
                  unit: '度/月',
                ),
                SizedBox(height: 12),

                // 第二行：每月電費
                _buildTableRow(
                  label: '每月電費',
                  oldValue: '${oldMonthlyCost.toStringAsFixed(0)}',
                  newValue: '${newMonthlyCost.toStringAsFixed(0)}',
                  unit: '元',
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // 節省數據（高亮顯示）
          _buildSavingDataRow(
            icon: Icons.trending_down,
            iconColor: Colors.blue[800]!,
            label: '每月節電',
            value: '${monthlySavings.toStringAsFixed(1)}',
            unit: '度',
            isHighlight: true,
          ),
          SizedBox(height: 10),

          _buildSavingDataRow(
            icon: Icons.trending_down,
            iconColor: Colors.blue[800]!,
            label: '共節省電費',
            value: '${(oldMonthlyCost - newMonthlyCost).toStringAsFixed(0)}',
            unit: '元/月',
            isHighlight: true,
          ),
        ],
      ),
    );
  }

  /// 建構表格行
  Widget _buildTableRow({
    required String label,
    required String oldValue,
    required String newValue,
    required String unit,
  }) {
    return Row(
      children: [
        // 左側標籤（包含單位）
        Expanded(
          flex: 3,
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
              children: [
                TextSpan(text: label),
                TextSpan(
                  text: ' ($unit)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
        // 原燈管數值
        Expanded(
          flex: 2,
          child: Center(
            child: Text(
              oldValue,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange[800],
              ),
            ),
          ),
        ),
        // AI燈管數值
        Expanded(
          flex: 2,
          child: Center(
            child: Text(
              newValue,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ),
        ),
      ],
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
}
