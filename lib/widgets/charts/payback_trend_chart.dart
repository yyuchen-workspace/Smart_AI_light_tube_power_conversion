import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// 節省金額趨勢折線圖（可展開）
///
/// 顯示未來 12 個月累計節省預測
/// 買斷模式下會顯示回本線參考
class PaybackTrendChart extends StatelessWidget {
  final double monthlySaving;     // 每月節省金額（元）
  final double? buyoutTotal;      // 買斷總額（可選，元）

  const PaybackTrendChart({
    Key? key,
    required this.monthlySaving,
    this.buyoutTotal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 如果沒有節省金額，不顯示圖表
    if (monthlySaving <= 0) return SizedBox.shrink();

    // 生成 12 個月的累計數據點
    List<FlSpot> spots = _generateDataSpots();

    return Container(
      margin: EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[300]!, width: 2),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(Icons.trending_up, color: Colors.orange[700], size: 20),
            SizedBox(width: 8),
            Text(
              '節省金額趨勢分析',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        subtitle: Text(
          '點擊查看未來 12 個月累計節省',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        children: [
          Container(
            height: 300,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // 買斷模式：顯示回本線說明
                if (buyoutTotal != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 16,
                        height: 2,
                        color: Colors.red[300],
                      ),
                      SizedBox(width: 8),
                      Text(
                        '買斷總額: ${_roundUpFirstDecimal(buyoutTotal!).toStringAsFixed(1)} 元',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
                // 折線圖
                Expanded(
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: monthlySaving * 2,
                      ),
                      titlesData: FlTitlesData(
                        // 左側 Y 軸：顯示金額（千元為單位）
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${(value / 1000).toStringAsFixed(0)}k',
                                style: TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        // 底部 X 軸：顯示月份
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}月',
                                style: TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Colors.green[600],
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.green[100]!.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                      // 買斷模式：添加回本線（紅色虛線）
                      extraLinesData: buyoutTotal != null
                          ? ExtraLinesData(
                              horizontalLines: [
                                HorizontalLine(
                                  y: buyoutTotal!,
                                  color: Colors.red[300]!,
                                  strokeWidth: 2,
                                  dashArray: [5, 5],
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 生成 12 個月累計數據點
  List<FlSpot> _generateDataSpots() {
    List<FlSpot> spots = [];
    for (int i = 0; i <= 12; i++) {
      double cumulativeSaving = monthlySaving * i;
      spots.add(FlSpot(i.toDouble(), cumulativeSaving));
    }
    return spots;
  }

  /// 向上舍入到第一位小數
  static double _roundUpFirstDecimal(double value) {
    return (value * 10).ceilToDouble() / 10;
  }
}
