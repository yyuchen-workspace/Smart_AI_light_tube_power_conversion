/*
 * ============================================================
 * 步驟二：台電帳單資訊頁面（選填）
 * ============================================================
 */

import 'package:flutter/material.dart';
import '../widgets/bill_info_form.dart';

class Step2BillInfo extends StatelessWidget {
  // 季節選擇
  final bool timeTypeSummer;
  final bool timeTypeNonSummer;
  final ValueChanged<bool?> onSummerChanged;
  final ValueChanged<bool?> onNonSummerChanged;

  // 輸入欄位控制器
  final TextEditingController contractCapacityController;
  final TextEditingController maxDemandController;
  final TextEditingController billingUnitsController;

  // 輸入變更回調
  final ValueChanged<String>? onContractCapacityChanged;
  final ValueChanged<String>? onMaxDemandChanged;
  final ValueChanged<String>? onBillingUnitsChanged;

  // 計算結果控制器
  final TextEditingController basicElectricityController;
  final TextEditingController excessDemandController;
  final TextEditingController flowElectricityController;
  final TextEditingController totalElectricityController;

  // 資訊按鈕回調
  final void Function(String fieldName) onInfoTap;

  // 計算按鈕回調
  final VoidCallback? onCalculateStep2;

  // 計算狀態
  final bool step2Calculated;
  final bool step3Calculated;

  // Step 3 節電數據（可選，用於顯示與上期比較）
  final TextEditingController? totalMonthlySavingController;

  // 圓餅圖組件（可選）
  final Widget? pieChart;

  const Step2BillInfo({
    Key? key,
    required this.timeTypeSummer,
    required this.timeTypeNonSummer,
    required this.onSummerChanged,
    required this.onNonSummerChanged,
    required this.contractCapacityController,
    required this.maxDemandController,
    required this.billingUnitsController,
    this.onContractCapacityChanged,
    this.onMaxDemandChanged,
    this.onBillingUnitsChanged,
    required this.basicElectricityController,
    required this.excessDemandController,
    required this.flowElectricityController,
    required this.totalElectricityController,
    required this.onInfoTap,
    this.onCalculateStep2,
    required this.step2Calculated,
    required this.step3Calculated,
    this.totalMonthlySavingController,
    this.pieChart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 頁面標題
          Text(
            '台電帳單資訊',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
          SizedBox(height: 8),
          Text(
            '此為選填項目，可提供更精確的電費試算',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 32),

          // 台電帳單表單
          BillInfoForm(
            timeTypeSummer: timeTypeSummer,
            timeTypeNonSummer: timeTypeNonSummer,
            onSummerChanged: onSummerChanged,
            onNonSummerChanged: onNonSummerChanged,
            contractCapacityController: contractCapacityController,
            maxDemandController: maxDemandController,
            billingUnitsController: billingUnitsController,
            onContractCapacityChanged: onContractCapacityChanged,
            onMaxDemandChanged: onMaxDemandChanged,
            onBillingUnitsChanged: onBillingUnitsChanged,
            basicElectricityController: basicElectricityController,
            excessDemandController: excessDemandController,
            flowElectricityController: flowElectricityController,
            totalElectricityController: totalElectricityController,
            onInfoTap: onInfoTap,
            onCalculateStep2: onCalculateStep2,
            step2Calculated: step2Calculated,
            step3Calculated: step3Calculated,
            totalMonthlySavingController: totalMonthlySavingController,
            pieChart: pieChart,
          ),
        ],
      ),
    );
  }
}
