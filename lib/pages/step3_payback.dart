/*
 * ============================================================
 * 步驟三：試算攤提時間頁面（選填）
 * ============================================================
 */

import 'package:flutter/material.dart';
import '../widgets/payback_form.dart';

class Step3Payback extends StatelessWidget {
  // 燈管計價方式
  final String? pricingMethod; // '租賃' or '買斷'
  final ValueChanged<String?> onPricingMethodChanged;

  // 燈管租賃價格
  final TextEditingController rentalPriceController;
  final ValueChanged<String>? onRentalPriceChanged;

  // 燈管買斷價格
  final TextEditingController buyoutPriceController;
  final ValueChanged<String>? onBuyoutPriceChanged;

  // 燈管數量
  final TextEditingController step3LightCountController;
  final ValueChanged<String>? onLightCountChanged;

  // 網關計價方式
  final String? gatewayPricingMethod; // '租賃' or '買斷'
  final ValueChanged<String?> onGatewayPricingMethodChanged;

  // 網關租賃價格
  final TextEditingController gatewayRentalPriceController;
  final ValueChanged<String>? onGatewayRentalPriceChanged;

  // 網關買斷價格
  final TextEditingController gatewayBuyoutPriceController;
  final ValueChanged<String>? onGatewayBuyoutPriceChanged;

  // 網關數量
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

  const Step3Payback({
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
            '攤提計算',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange[900],
            ),
          ),
          SizedBox(height: 8),
          Text(
            '此為選填項目，可計算投資回本時間',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 32),

          // 攤提計算表單
          PaybackForm(
            pricingMethod: pricingMethod,
            onPricingMethodChanged: onPricingMethodChanged,
            rentalPriceController: rentalPriceController,
            onRentalPriceChanged: onRentalPriceChanged,
            buyoutPriceController: buyoutPriceController,
            onBuyoutPriceChanged: onBuyoutPriceChanged,
            step3LightCountController: step3LightCountController,
            onLightCountChanged: onLightCountChanged,
            gatewayPricingMethod: gatewayPricingMethod,
            onGatewayPricingMethodChanged: onGatewayPricingMethodChanged,
            gatewayRentalPriceController: gatewayRentalPriceController,
            onGatewayRentalPriceChanged: onGatewayRentalPriceChanged,
            gatewayBuyoutPriceController: gatewayBuyoutPriceController,
            onGatewayBuyoutPriceChanged: onGatewayBuyoutPriceChanged,
            gatewayCountController: gatewayCountController,
            onGatewayCountChanged: onGatewayCountChanged,
            monthlyRentalController: monthlyRentalController,
            totalMonthlySavingController: totalMonthlySavingController,
            buyoutTotalController: buyoutTotalController,
            paybackPeriodController: paybackPeriodController,
            onInfoTap: onInfoTap,
            onCalculateStep3: onCalculateStep3,
            step1Calculated: step1Calculated,
            step2Calculated: step2Calculated,
            step3Calculated: step3Calculated,
            useSimplifiedMode: useSimplifiedMode,
          ),
        ],
      ),
    );
  }
}
