/*
 * ============================================================
 * 攤提計算表單組件
 * ============================================================
 *
 * 用於 Step 3，包含：
 * - 計價方式選擇（租賃/買斷）
 * - 燈管數量輸入
 * - 租賃/買斷結果顯示
 * - 攤提時間折線圖
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaybackForm extends StatelessWidget {
  // 計價方式
  final String? pricingMethod; // '租賃' or '買斷'
  final ValueChanged<String?> onPricingMethodChanged;

  // 租賃價格
  final TextEditingController rentalPriceController;
  final ValueChanged<String>? onRentalPriceChanged;

  // 買斷價格
  final TextEditingController buyoutPriceController;
  final ValueChanged<String>? onBuyoutPriceChanged;

  // 燈管數量
  final TextEditingController step3LightCountController;
  final ValueChanged<String>? onLightCountChanged;

  // 計算結果控制器
  final TextEditingController monthlyRentalController;
  final TextEditingController totalMonthlySavingController;
  final TextEditingController buyoutTotalController;
  final TextEditingController paybackPeriodController;

  // 資訊按鈕回調
  final void Function(String fieldName) onInfoTap;

  // 計算按鈕回調
  final VoidCallback? onCalculateStep3;

  // 計算狀態
  final bool step1Calculated;
  final bool step2Calculated;
  final bool step3Calculated;

  // 計算模式
  final bool useSimplifiedMode;

  // 折線圖組件（可選）
  final Widget? trendChart;

  const PaybackForm({
    Key? key,
    required this.pricingMethod,
    required this.onPricingMethodChanged,
    required this.rentalPriceController,
    this.onRentalPriceChanged,
    required this.buyoutPriceController,
    this.onBuyoutPriceChanged,
    required this.step3LightCountController,
    this.onLightCountChanged,
    required this.monthlyRentalController,
    required this.totalMonthlySavingController,
    required this.buyoutTotalController,
    required this.paybackPeriodController,
    required this.onInfoTap,
    this.onCalculateStep3,
    required this.step1Calculated,
    required this.step2Calculated,
    required this.step3Calculated,
    required this.useSimplifiedMode,
    this.trendChart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 輸入區塊
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[25],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[200]!, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPricingMethodSection(),
            ],
          ),
        ),

        SizedBox(height: 16),

        // 結果區塊
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[25],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[200]!, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 固定顯示燈管數量（無論租賃或買斷）
              _buildInputFieldWithUnit(
                '燈管數量',
                step3LightCountController,
                '支',
                integerOnly: true,
                onChanged: onLightCountChanged,
              ),
              SizedBox(height: 20),

              // 根據選擇顯示對應欄位（始終顯示，不論是否已計算）
              if (pricingMethod == '租賃') ...[
                _buildReadOnlyFieldWithUnit(
                  '每月燈管租賃費用',
                  monthlyRentalController,
                  '元',
                  hasInfo: true,
                ),
                SizedBox(height: 12),
                _buildReadOnlyFieldWithUnit(
                  '每月總共可節省費用',
                  totalMonthlySavingController,
                  '元',
                  hasInfo: true,
                  showRed: !step2Calculated,
                ),
              ],

              if (pricingMethod == '買斷') ...[
                _buildReadOnlyFieldWithUnit(
                  '買斷總費用',
                  buyoutTotalController,
                  '元',
                  hasInfo: true,
                ),
                SizedBox(height: 12),
                _buildReadOnlyFieldWithUnit(
                  '多久時間攤提(月)',
                  paybackPeriodController,
                  '個月',
                  hasInfo: true,
                  showRed: !step2Calculated,
                ),
              ],
            ],
          ),
        ),

        SizedBox(height: 20),

        // 計算按鈕
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (useSimplifiedMode ? step1Calculated : step2Calculated)
                ? onCalculateStep3
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  (useSimplifiedMode ? step1Calculated : step2Calculated)
                      ? Colors.orange[600]
                      : Colors.grey[400],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              (useSimplifiedMode ? step1Calculated : step2Calculated)
                  ? '計算結果'
                  : useSimplifiedMode
                      ? '請先完成 Step 1 計算'
                      : '請先完成 Step 2 計算',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  /// 建立計價方式選擇區塊
  Widget _buildPricingMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '燈管計價方式',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),

        // 租賃選項
        RadioListTile<String>(
          title: Row(
            children: [
              Text('租賃', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              if (pricingMethod == '租賃') ...[
                Flexible(
                  child: TextField(
                    controller: rentalPriceController,
                    onTap: () {
                      // 點擊時自動全選文字
                      rentalPriceController.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: rentalPriceController.text.length,
                      );
                    },
                    onChanged: onRentalPriceChanged,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      isDense: false,
                      suffixText: '元/支/月',
                      suffixStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ],
          ),
          value: '租賃',
          groupValue: pricingMethod,
          onChanged: onPricingMethodChanged,
          contentPadding: EdgeInsets.zero,
        ),

        // 買斷選項
        RadioListTile<String>(
          title: Row(
            children: [
              Text('買斷', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              if (pricingMethod == '買斷') ...[
                Flexible(
                  child: TextField(
                    controller: buyoutPriceController,
                    onTap: () {
                      // 點擊時自動全選文字
                      buyoutPriceController.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: buyoutPriceController.text.length,
                      );
                    },
                    onChanged: onBuyoutPriceChanged,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      isDense: false,
                      suffixText: '元/支',
                      suffixStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ],
          ),
          value: '買斷',
          groupValue: pricingMethod,
          onChanged: onPricingMethodChanged,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  /// 建立輸入欄位（帶單位）
  Widget _buildInputFieldWithUnit(
    String label,
    TextEditingController controller,
    String unit, {
    ValueChanged<String>? onChanged,
    bool integerOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 4),
        TextField(
          controller: controller,
          onTap: () {
            // 點擊時自動全選文字
            controller.selection = TextSelection(
              baseOffset: 0,
              extentOffset: controller.text.length,
            );
          },
          decoration: InputDecoration(
            suffixText: unit,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          keyboardType: TextInputType.number,
          inputFormatters:
              integerOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  /// 建立唯讀欄位（帶單位和資訊按鈕）
  Widget _buildReadOnlyFieldWithUnit(
    String label,
    TextEditingController controller,
    String unit, {
    bool hasInfo = false,
    bool showRed = false,
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
                color: showRed ? Colors.red : Colors.grey[700],
                fontWeight: showRed ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (hasInfo) ...[
              SizedBox(width: 4),
              InkWell(
                onTap: () => onInfoTap(label),
                child: Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.orange[700],
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
                    color: showRed
                        ? Colors.red
                        : (controller.text.isEmpty
                            ? Colors.grey[400]
                            : Colors.black87),
                    fontWeight: showRed ? FontWeight.bold : FontWeight.normal,
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
