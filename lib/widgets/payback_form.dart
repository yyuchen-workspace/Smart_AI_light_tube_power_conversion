/*
 * ============================================================
 * 攤提計算表單組件 (版本 10.0)
 * ============================================================
 *
 * 用於 Step 3，包含：
 * - 燈管計價方式選擇（租賃/買斷）
 * - 網關計價方式選擇（租賃/買斷）
 * - 總費用與攤提時間計算
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaybackForm extends StatelessWidget {
  // 燈管計價方式
  final String? pricingMethod;
  final ValueChanged<String?> onPricingMethodChanged;
  final TextEditingController rentalPriceController;
  final ValueChanged<String>? onRentalPriceChanged;
  final TextEditingController buyoutPriceController;
  final ValueChanged<String>? onBuyoutPriceChanged;
  final TextEditingController step3LightCountController;
  final ValueChanged<String>? onLightCountChanged;

  // 網關計價方式
  final String? gatewayPricingMethod;
  final ValueChanged<String?> onGatewayPricingMethodChanged;
  final TextEditingController gatewayRentalPriceController;
  final ValueChanged<String>? onGatewayRentalPriceChanged;
  final TextEditingController gatewayBuyoutPriceController;
  final ValueChanged<String>? onGatewayBuyoutPriceChanged;
  final TextEditingController gatewayCountController;
  final ValueChanged<String>? onGatewayCountChanged;

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
    required this.gatewayPricingMethod,
    required this.onGatewayPricingMethodChanged,
    required this.gatewayRentalPriceController,
    this.onGatewayRentalPriceChanged,
    required this.gatewayBuyoutPriceController,
    this.onGatewayBuyoutPriceChanged,
    required this.gatewayCountController,
    this.onGatewayCountChanged,
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
    // 檢查燈管和網關的計價方式是否一致
    bool pricingMethodsMatch = pricingMethod == gatewayPricingMethod;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 燈管區塊
        _buildSectionContainer(
          title: '燈管計價方式',
          child: Column(
            children: [
              _buildPricingMethodSection(
                pricingMethod: pricingMethod,
                onPricingMethodChanged: onPricingMethodChanged,
                rentalPriceController: rentalPriceController,
                onRentalPriceChanged: onRentalPriceChanged,
                buyoutPriceController: buyoutPriceController,
                onBuyoutPriceChanged: onBuyoutPriceChanged,
                rentalUnit: '元/支/月',
                buyoutUnit: '元/支',
              ),
              SizedBox(height: 16),
              _buildInputFieldWithUnit(
                '燈管數量',
                step3LightCountController,
                '支',
                integerOnly: true,
                onChanged: onLightCountChanged,
              ),
            ],
          ),
        ),

        SizedBox(height: 16),

        // 2. 網關區塊
        _buildSectionContainer(
          title: '網關計價方式',
          child: Column(
            children: [
              _buildPricingMethodSection(
                pricingMethod: gatewayPricingMethod,
                onPricingMethodChanged: onGatewayPricingMethodChanged,
                rentalPriceController: gatewayRentalPriceController,
                onRentalPriceChanged: onGatewayRentalPriceChanged,
                buyoutPriceController: gatewayBuyoutPriceController,
                onBuyoutPriceChanged: onGatewayBuyoutPriceChanged,
                rentalUnit: '元/台/月',
                buyoutUnit: '元/台',
              ),
              SizedBox(height: 16),
              _buildInputFieldWithUnit(
                '網關數量',
                gatewayCountController,
                '台',
                integerOnly: true,
                onChanged: onGatewayCountChanged,
              ),
            ],
          ),
        ),

        SizedBox(height: 16),

        // 3. 總費用 + 可節省費用/攤提時間區塊
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
              // 根據選擇顯示對應欄位
              if (pricingMethodsMatch && pricingMethod == '租賃') ...[
                _buildReadOnlyFieldWithUnit(
                  '每月租賃費用（燈管＋網關）',
                  monthlyRentalController,
                  '元',
                  hasInfo: true,
                ),
                SizedBox(height: 12),
                _buildReadOnlyFieldWithUnit(
                  '每月淨利',
                  totalMonthlySavingController,
                  '元',
                  hasInfo: true,
                  showRed: true,
                ),
              ] else if (pricingMethodsMatch && pricingMethod == '買斷') ...[
                _buildReadOnlyFieldWithUnit(
                  '買斷總費用（燈管＋網關）',
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
                  showRed: true,
                ),
              ] else ...[
                // 混合模式警告
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.amber[800]),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '燈管與網關的計價方式必須相同（皆為租賃或皆為買斷）',
                          style:
                              TextStyle(color: Colors.amber[900], fontSize: 14),
                        ),
                      ),
                    ],
                  ),
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
            onPressed:
                (useSimplifiedMode ? step1Calculated : step2Calculated) &&
                        pricingMethodsMatch
                    ? onCalculateStep3
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  (useSimplifiedMode ? step1Calculated : step2Calculated) &&
                          pricingMethodsMatch
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
                  ? (pricingMethodsMatch ? '計算結果' : '請確保燈管與網關計價方式相同')
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

  /// 建立區塊容器
  Widget _buildSectionContainer({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[25],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  /// 建立計價方式選擇區塊（可複用於燈管和網關）
  Widget _buildPricingMethodSection({
    required String? pricingMethod,
    required ValueChanged<String?> onPricingMethodChanged,
    required TextEditingController rentalPriceController,
    ValueChanged<String>? onRentalPriceChanged,
    required TextEditingController buyoutPriceController,
    ValueChanged<String>? onBuyoutPriceChanged,
    required String rentalUnit,
    required String buyoutUnit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
                      isDense: false,
                      suffixText: rentalUnit,
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
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
                      isDense: false,
                      suffixText: buyoutUnit,
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: showRed ? Colors.red : Colors.grey[700],
                  fontWeight: showRed ? FontWeight.bold : FontWeight.normal,
                ),
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
