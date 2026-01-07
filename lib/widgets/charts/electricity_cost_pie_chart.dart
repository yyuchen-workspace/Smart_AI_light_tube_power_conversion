import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// 電費組成分析圓餅圖（可展開）
///
/// 顯示基本電價、流動電價、超約費用的佔比
/// 包含互動式圖例，顯示具體金額
class ElectricityCostPieChart extends StatelessWidget {
  final double basicElectricity;   // 基本電價（元）
  final double flowElectricity;    // 流動電價（元）
  final double excessDemand;       // 超約費用（元）

  const ElectricityCostPieChart({
    Key? key,
    required this.basicElectricity,
    required this.flowElectricity,
    required this.excessDemand,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double total = basicElectricity + flowElectricity + excessDemand;

    // 如果總額為 0，不顯示圖表
    if (total == 0) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[300]!, width: 2),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(Icons.pie_chart, color: Colors.blue[700], size: 20),
            SizedBox(width: 8),
            Text(
              '電費組成分析',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        subtitle: Text(
          '點擊查看電費組成比例',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        children: [
          Container(
            height: 280,
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // 左側：圓餅圖
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        // 基本電價（藍色）
                        PieChartSectionData(
                          value: basicElectricity,
                          title: '${(basicElectricity / total * 100).toStringAsFixed(1)}%',
                          color: Colors.blue[400],
                          radius: 80,
                          titleStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        // 流動電價（橙色）
                        PieChartSectionData(
                          value: flowElectricity,
                          title: '${(flowElectricity / total * 100).toStringAsFixed(1)}%',
                          color: Colors.orange[400],
                          radius: 80,
                          titleStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        // 超約費用（紅色，如果有的話）
                        if (excessDemand > 0)
                          PieChartSectionData(
                            value: excessDemand,
                            title: '${(excessDemand / total * 100).toStringAsFixed(1)}%',
                            color: Colors.red[400],
                            radius: 80,
                            titleStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // 右側：圖例
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem('基本電價', basicElectricity, Colors.blue[400]!),
                      SizedBox(height: 8),
                      _buildLegendItem('流動電價', flowElectricity, Colors.orange[400]!),
                      if (excessDemand > 0) ...[
                        SizedBox(height: 8),
                        _buildLegendItem('超約費用', excessDemand, Colors.red[400]!),
                      ],
                      SizedBox(height: 16),
                      Divider(),
                      _buildLegendItem('總計', total, Colors.grey[700]!, isBold: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 建構圖例項目
  Widget _buildLegendItem(String label, double value, Color color, {bool isBold = false}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Text(
                '${_roundUpFirstDecimal(value).toStringAsFixed(1)} 元',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: isBold ? Colors.black : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 向上舍入到第一位小數
  static double _roundUpFirstDecimal(double value) {
    return (value * 10).ceilToDouble() / 10;
  }
}
