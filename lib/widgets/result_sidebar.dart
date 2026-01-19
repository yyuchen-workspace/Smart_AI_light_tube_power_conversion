/*
 * ============================================================
 * 側欄即時結果元件
 * ============================================================
 *
 * 顯示計算結果的側邊欄，包含節電量、節電率、預估費用等資訊
 */

import 'package:flutter/material.dart';

class ResultSidebar extends StatelessWidget {
  // Step 1 結果
  final double? aiMonthlyConsumption; // AI燈管每月用電量
  final double? traditionalMonthlyConsumption; // 傳統燈管每月用電量
  final double? monthlySavings; // 每月節電量
  final double? savingsRate; // 節電率

  // Step 2 結果（可選）
  final double? estimatedMonthlyCost; // 預估每月電費

  // Step 3 結果（可選）
  final double? paybackMonths; // 攤提月數

  final bool hasCalculated; // 是否已計算

  const ResultSidebar({
    Key? key,
    this.aiMonthlyConsumption,
    this.traditionalMonthlyConsumption,
    this.monthlySavings,
    this.savingsRate,
    this.estimatedMonthlyCost,
    this.paybackMonths,
    this.hasCalculated = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!hasCalculated) {
      return _buildPlaceholder();
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 標題
          Row(
            children: [
              Icon(Icons.assessment, color: Colors.blue[700], size: 24),
              SizedBox(width: 8),
              Text(
                '計算結果',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Step 1 結果
          if (monthlySavings != null) ...[
            _buildResultCard(
              icon: Icons.eco,
              iconColor: Colors.green,
              title: '每月節電量',
              value: '${monthlySavings!.toStringAsFixed(2)}',
              unit: '度',
              backgroundColor: Colors.green[50]!,
            ),
            SizedBox(height: 16),
          ],

          if (savingsRate != null) ...[
            _buildResultCard(
              icon: Icons.trending_down,
              iconColor: Colors.orange,
              title: '節電率',
              value: '${savingsRate!.toStringAsFixed(1)}',
              unit: '%',
              backgroundColor: Colors.orange[50]!,
            ),
            SizedBox(height: 16),
          ],

          // Step 2 結果
          if (estimatedMonthlyCost != null) ...[
            _buildResultCard(
              icon: Icons.attach_money,
              iconColor: Colors.purple,
              title: '預估每月電費',
              value: '${estimatedMonthlyCost!.toStringAsFixed(0)}',
              unit: '元',
              backgroundColor: Colors.purple[50]!,
            ),
            SizedBox(height: 16),
          ],

          // 總節電費用（如果有電費資訊）
          if (monthlySavings != null && estimatedMonthlyCost != null) ...[
            _buildResultCard(
              icon: Icons.savings,
              iconColor: Colors.teal,
              title: '預估每月節省',
              value: '${(monthlySavings! * 5).toStringAsFixed(0)}',
              unit: '元',
              backgroundColor: Colors.teal[50]!,
              subtitle: '以平均每度5元計算',
            ),
            SizedBox(height: 16),
          ],

          // Step 3 結果
          if (paybackMonths != null) ...[
            _buildResultCard(
              icon: Icons.event_available,
              iconColor: Colors.indigo,
              title: '攤提時間',
              value: '${paybackMonths!.toStringAsFixed(1)}',
              unit: '個月',
              backgroundColor: Colors.indigo[50]!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 2, style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calculate, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            '填寫資料後',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '按下「計算」查看結果',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String unit,
    required Color backgroundColor,
    String? subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
              SizedBox(width: 4),
              Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
