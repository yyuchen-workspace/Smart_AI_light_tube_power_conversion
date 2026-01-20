/*
 * ============================================================
 * 台電帳單資訊表單組件
 * ============================================================
 *
 * 用於 Step 2，包含：
 * - 季節選擇（夏季/非夏季）
 * - 契約容量、最高需量、計費度數輸入
 * - 基本電價、超約費用、流動電價、總電價顯示
 * - 電費組成圓餅圖
 */

import 'package:flutter/material.dart';

class BillInfoForm extends StatelessWidget {
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

  // 計算狀態
  final bool step2Calculated;
  final bool step3Calculated;

  // Step 3 節電數據（可選，用於顯示與上期比較）
  final TextEditingController? totalMonthlySavingController;

  // 圓餅圖組件（可選）
  final Widget? pieChart;

  const BillInfoForm({
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
    required this.step2Calculated,
    required this.step3Calculated,
    this.totalMonthlySavingController,
    this.pieChart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左右分佈佈局
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左邊：輸入區塊
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[25],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 固定勾選項目（不可取消）
                    CheckboxListTile(
                      title: Text('電力需量非營業用',
                          style: TextStyle(fontSize: 16)),
                      value: true, // 固定為 true
                      onChanged: null, // 不可變更
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      title: Text('非時間電價', style: TextStyle(fontSize: 16)),
                      value: true, // 固定為 true
                      onChanged: null, // 不可變更
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),

                    // 季節選擇（可變更）
                    CheckboxListTile(
                      title: Text('夏季(6/1–9/30)',
                          style: TextStyle(fontSize: 16)),
                      value: timeTypeSummer,
                      onChanged: onSummerChanged,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      title: Text('非夏季', style: TextStyle(fontSize: 16)),
                      value: timeTypeNonSummer,
                      onChanged: onNonSummerChanged,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),

                    SizedBox(height: 12),

                    // 輸入欄位
                    _buildInputFieldWithUnit(
                      '契約容量',
                      contractCapacityController,
                      '瓩',
                      onChanged: onContractCapacityChanged,
                    ),
                    SizedBox(height: 12),
                    _buildInputFieldWithUnit(
                      '最高需量',
                      maxDemandController,
                      '瓩',
                      onChanged: onMaxDemandChanged,
                    ),
                    SizedBox(height: 12),
                    _buildInputFieldWithUnit(
                      '計費度數',
                      billingUnitsController,
                      '度',
                      onChanged: onBillingUnitsChanged,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(width: 16),

            // 右邊：結果區塊
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[25],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildReadOnlyFieldWithUnit(
                      '基本電價(約定)',
                      basicElectricityController,
                      '元',
                      hasInfo: true,
                    ),
                    SizedBox(height: 12),
                    _buildReadOnlyFieldWithUnit(
                      '最高需量有超用契約容量',
                      excessDemandController,
                      '元',
                      hasInfo: true,
                    ),
                    SizedBox(height: 12),
                    _buildReadOnlyFieldWithUnit(
                      '流動電價',
                      flowElectricityController,
                      '元',
                      hasInfo: true,
                    ),
                    SizedBox(height: 12),
                    _buildReadOnlyFieldWithUnit(
                      '總電價',
                      totalElectricityController,
                      '元',
                      hasInfo: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // 計算結果摘要卡片
        if (step2Calculated) ...[
          SizedBox(height: 24),
          Text(
            '計算結果',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          // 結果卡片 1: 本期電費總計
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt_long, color: Colors.blue[700], size: 20),
                    SizedBox(width: 8),
                    Text(
                      '本期電費總計',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      totalElectricityController.text.isNotEmpty
                          ? double.parse(totalElectricityController.text)
                              .toStringAsFixed(0)
                          : '0',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '元',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 結果卡片 2: 與上期比較（如果 Step 3 已計算且有節電）
          if (step3Calculated &&
              totalMonthlySavingController != null &&
              totalMonthlySavingController!.text.isNotEmpty &&
              double.parse(totalMonthlySavingController!.text) > 0) ...[
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_down,
                          color: Colors.green[700], size: 20),
                      SizedBox(width: 8),
                      Text(
                        '與上期比較',
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '節省 ${double.parse(totalMonthlySavingController!.text).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '元/月',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],

        // 圓餅圖（如果提供且已計算）
        if (step2Calculated && pieChart != null) ...[
          SizedBox(height: 24),
          Text(
            '電費組成分析',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          pieChart!,
        ],
      ],
    );
  }

  /// 建立輸入欄位（帶單位）
  Widget _buildInputFieldWithUnit(
    String label,
    TextEditingController controller,
    String unit, {
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixText: unit,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      style: TextStyle(fontSize: 16),
    );
  }

  /// 建立唯讀欄位（帶單位和資訊按鈕）
  Widget _buildReadOnlyFieldWithUnit(
    String label,
    TextEditingController controller,
    String unit, {
    bool hasInfo = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            if (hasInfo) ...[
              SizedBox(width: 4),
              InkWell(
                onTap: () => onInfoTap(label),
                child: Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  controller.text.isEmpty ? '-' : controller.text,
                  style: TextStyle(
                    fontSize: 16,
                    color: controller.text.isEmpty
                        ? Colors.grey[400]
                        : Colors.black87,
                  ),
                ),
              ),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
