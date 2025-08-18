import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '智慧AI燈管電力換算',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  // 第一步：台電帳單資訊 - 輸入控制器
  final TextEditingController contractCapacityController = TextEditingController();
  final TextEditingController maxDemandController = TextEditingController();
  final TextEditingController billingUnitsController = TextEditingController();
  
  // 第一步：台電帳單資訊 - 唯讀結果控制器
  final TextEditingController basicElectricityController = TextEditingController();
  final TextEditingController excessDemandController = TextEditingController();
  final TextEditingController flowElectricityController = TextEditingController();
  final TextEditingController totalElectricityController = TextEditingController();
  
  // 第二步：燈管電力試算 - 輸入控制器
  final TextEditingController currentLightWattController = TextEditingController();
  final TextEditingController lightCountController = TextEditingController();
  
  // 第二步：燈管電力試算 - 唯讀結果控制器
  final TextEditingController monthlyConsumptionBeforeController = TextEditingController();
  final TextEditingController aiLightWattController = TextEditingController();
  final TextEditingController aiLightCountController = TextEditingController();
  final TextEditingController monthlyConsumptionAfterController = TextEditingController();
  final TextEditingController savingUnitsController = TextEditingController();
  final TextEditingController savingPercentController = TextEditingController();
  final TextEditingController nextBillController = TextEditingController();
  final TextEditingController totalSavingController = TextEditingController();
  
  // 第三步：攤提時間試算 - 輸入控制器
  final TextEditingController rentalPriceController = TextEditingController();
  final TextEditingController buyoutPriceController = TextEditingController();
  
  // 第三步：攤提時間試算 - 唯讀結果控制器
  final TextEditingController monthlyRentalController = TextEditingController();
  final TextEditingController buyoutTotalController = TextEditingController();
  final TextEditingController totalMonthlySavingController = TextEditingController();
  final TextEditingController paybackPeriodController = TextEditingController();
  
  // 狀態欄
  final TextEditingController statusController = TextEditingController();
  
  // 狀態變數 - 修改預設值
  bool electricityTypeNonBusiness = true; // 預設勾選且不可取消
  bool timeTypeNonTime = true; // 預設勾選且不可取消
  bool timeTypeSummer = true; // 預設勾選夏季
  bool timeTypeNonSummer = false; // 非夏季
  
  String? pricingMethod = '租賃'; // 預設勾選租賃
  
  bool isCalculated = false;
  bool needsRecalculation = false;
  
  // 電價常數
  static const double summerCapacityPrice = 236.2;
  static const double nonSummerCapacityPrice = 173.2;
  static const double summerUnitPrice = 4.08;
  static const double nonSummerUnitPrice = 3.87;
  static const double aiLightWatt = 12.0;
  
  // 背景計算暫存
  double backgroundBasicElectricity = 0.0;
  double backgroundFlowElectricity = 0.0;
  double backgroundTotalElectricity = 0.0;
  double backgroundSavingUnits = 0.0;
  double backgroundTotalSaving = 0.0;

  @override
  void initState() {
    super.initState();
    statusController.text = '完成所有選項設定後點擊計算結果';
    aiLightWattController.text = aiLightWatt.toString();
    
    // 添加監聽器
    contractCapacityController.addListener(_updateNotification);
    maxDemandController.addListener(_updateNotification);
    billingUnitsController.addListener(_updateNotification);
    currentLightWattController.addListener(_updateNotification);
    lightCountController.addListener(() {
      _updateNotification();
      _syncLightCount(); // 同步燈管數量
    });
    rentalPriceController.addListener(_updateNotification);
    buyoutPriceController.addListener(_updateNotification);
  }

  @override
  void dispose() {
    // 清理所有控制器
    contractCapacityController.dispose();
    maxDemandController.dispose();
    billingUnitsController.dispose();
    basicElectricityController.dispose();
    excessDemandController.dispose();
    flowElectricityController.dispose();
    totalElectricityController.dispose();
    currentLightWattController.dispose();
    lightCountController.dispose();
    monthlyConsumptionBeforeController.dispose();
    aiLightWattController.dispose();
    aiLightCountController.dispose();
    monthlyConsumptionAfterController.dispose();
    savingUnitsController.dispose();
    savingPercentController.dispose();
    nextBillController.dispose();
    totalSavingController.dispose();
    rentalPriceController.dispose();
    buyoutPriceController.dispose();
    monthlyRentalController.dispose();
    buyoutTotalController.dispose();
    totalMonthlySavingController.dispose();
    paybackPeriodController.dispose();
    statusController.dispose();
    super.dispose();
  }

  void _updateNotification() {
    if (isCalculated && !needsRecalculation) {
      setState(() {
        needsRecalculation = true;
        statusController.text = '務必點擊「計算結果」，重新計算！！';
      });
    }
  }

  // 同步燈管數量到AI燈管數量
  void _syncLightCount() {
    setState(() {
      aiLightCountController.text = lightCountController.text;
    });
  }

  double _roundUpFirstDecimal(double value) {
    double firstDecimal = (value * 10) % 10;
    if (firstDecimal > 0) {
      return (value * 10).floor() / 10 + 0.1;
    }
    return value;
  }

  void _calculateResults() {
    List<String> errors = [];

    // 驗證第一步輸入
    if (contractCapacityController.text.isEmpty) {
      errors.add('請填寫契約容量');
    } else {
      double? value = double.tryParse(contractCapacityController.text);
      if (value == null || value <= 0) {
        errors.add('契約容量必須為正數');
      }
    }
    if (maxDemandController.text.isEmpty) {
      errors.add('請填寫最高需量');
    } else {
      double? value = double.tryParse(maxDemandController.text);
      if (value == null || value <= 0) {
        errors.add('最高需量必須為正數');
      }
    }
    if (billingUnitsController.text.isEmpty) {
      errors.add('請填寫計費度數');
    } else {
      double? value = double.tryParse(billingUnitsController.text);
      if (value == null || value <= 0) {
        errors.add('計費度數必須為正數');
      }
    }

    // 驗證第二步輸入
    if (currentLightWattController.text.isEmpty) {
      errors.add('請填寫目前使用燈管瓦數');
    } else {
      double? value = double.tryParse(currentLightWattController.text);
      if (value == null || value <= 0) {
        errors.add('目前使用燈管瓦數必須為正數');
      }
    }
    if (lightCountController.text.isEmpty) {
      errors.add('請填寫燈管數量');
    } else {
      double? value = double.tryParse(lightCountController.text);
      if (value == null || value <= 0) {
        errors.add('燈管數量必須為正數');
      }
    }

    // 驗證第三步輸入
    if (pricingMethod == '租賃') {
      if (rentalPriceController.text.isEmpty) {
        errors.add('請填寫租賃價格');
      } else {
        double? value = double.tryParse(rentalPriceController.text);
        if (value == null || value <= 0) {
          errors.add('租賃價格必須為正數');
        }
      }
    }
    if (pricingMethod == '買斷') {
      if (buyoutPriceController.text.isEmpty) {
        errors.add('請填寫買斷價格');
      } else {
        double? value = double.tryParse(buyoutPriceController.text);
        if (value == null || value <= 0) {
          errors.add('買斷價格必須為正數');
        }
      }
    }

    if (errors.isNotEmpty) {
      _showErrorDialog(errors);
      return;
    }

    // 執行計算
    double contractCapacity = double.parse(contractCapacityController.text);
    double maxDemand = double.parse(maxDemandController.text);
    double billingUnits = double.parse(billingUnitsController.text);
    double currentLightWatt = double.parse(currentLightWattController.text);
    double lightCount = double.parse(lightCountController.text);

    // 根據第一步選擇的時間種類決定電價
    double capacityPrice = timeTypeSummer ? summerCapacityPrice : nonSummerCapacityPrice;
    double unitPrice = timeTypeSummer ? summerUnitPrice : nonSummerUnitPrice;

    // 第一步計算
    double basicElectricity = contractCapacity * capacityPrice;
    backgroundBasicElectricity = basicElectricity;

    double excessDemand = 0.0;
    String excessText = '無超約';
    if (maxDemand > contractCapacity) {
      excessDemand = (maxDemand - contractCapacity) * 1.5 * capacityPrice;
      excessText = _roundUpFirstDecimal(excessDemand).toStringAsFixed(1);
    }

    double flowElectricity = billingUnits * unitPrice;
    backgroundFlowElectricity = flowElectricity;

    double totalElectricity = basicElectricity + flowElectricity + excessDemand;
    backgroundTotalElectricity = totalElectricity;

    // 第二步計算
    double monthlyConsumptionBefore = currentLightWatt * lightCount * 24 * 30 / 1000;
    double monthlyConsumptionAfter = aiLightWatt * lightCount * 8 * 30 / 1000;
    double savingUnits = monthlyConsumptionBefore - monthlyConsumptionAfter;
    backgroundSavingUnits = savingUnits;
    double savingPercent = (savingUnits / monthlyConsumptionBefore) * 100;
    double nextBill = totalElectricity - (savingUnits * unitPrice);
    
    if (nextBill < 0) {
      _showErrorDialog(['所輸入的燈管瓦數不合邏輯，無法計算']);
      return;
    }

    double totalSaving = savingUnits * unitPrice;
    backgroundTotalSaving = totalSaving;

    // 第三步計算 - 根據第一步選擇的時間種類
    double monthlyRental = 0.0;
    double buyoutTotal = 0.0;
    double totalMonthlySaving = 0.0;
    double paybackPeriod = 0.0;

    if (pricingMethod == '租賃') {
      double rentalPrice = double.parse(rentalPriceController.text);
      monthlyRental = rentalPrice * lightCount;
      // 使用第一步選擇的時間種類進行計算
      totalMonthlySaving = totalSaving - monthlyRental;
    } else if (pricingMethod == '買斷') {
      double buyoutPrice = double.parse(buyoutPriceController.text);
      buyoutTotal = buyoutPrice * lightCount;
      // 使用第一步選擇的時間種類進行計算
      paybackPeriod = buyoutTotal / totalSaving;
    }

    // 更新UI
    setState(() {
      isCalculated = true;
      needsRecalculation = false;
      statusController.text = '計算成功';

      // 第一步結果
      basicElectricityController.text = _roundUpFirstDecimal(basicElectricity).toStringAsFixed(1);
      excessDemandController.text = excessText;
      flowElectricityController.text = _roundUpFirstDecimal(flowElectricity).toStringAsFixed(1);
      totalElectricityController.text = _roundUpFirstDecimal(totalElectricity).toStringAsFixed(1);

      // 第二步結果
      monthlyConsumptionBeforeController.text = _roundUpFirstDecimal(monthlyConsumptionBefore).toStringAsFixed(1);
      monthlyConsumptionAfterController.text = _roundUpFirstDecimal(monthlyConsumptionAfter).toStringAsFixed(1);
      savingUnitsController.text = _roundUpFirstDecimal(savingUnits).toStringAsFixed(1);
      savingPercentController.text = _roundUpFirstDecimal(savingPercent).toStringAsFixed(1);
      nextBillController.text = _roundUpFirstDecimal(nextBill).toStringAsFixed(1);
      totalSavingController.text = _roundUpFirstDecimal(totalSaving).toStringAsFixed(1);

      // 第三步結果
      if (pricingMethod == '租賃') {
        monthlyRentalController.text = _roundUpFirstDecimal(monthlyRental).toStringAsFixed(1);
        totalMonthlySavingController.text = _roundUpFirstDecimal(totalMonthlySaving).toStringAsFixed(1);
      } else {
        buyoutTotalController.text = _roundUpFirstDecimal(buyoutTotal).toStringAsFixed(1);
        paybackPeriodController.text = _roundUpFirstDecimal(paybackPeriod).toStringAsFixed(1);
      }
    });
  }

  void _showErrorDialog(List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('錯誤', style: TextStyle(fontSize: 24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: errors.map((error) => Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: Text('• $error', style: TextStyle(fontSize: 20)),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('確定', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }

  void _showFieldInfo(String fieldName, String info) {
    // 檢查是否處於計算成功狀態（只有計算成功且未修改才能查看？按鈕）
    if (!isCalculated || needsRecalculation) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('提醒', style: TextStyle(fontSize: 20, color: Colors.red)),
          content: Text('請先點擊「計算結果」按鈕進行計算', style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('確定', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      );
      return;
    }

    // 動態生成計算說明內容
    String dynamicInfo = _generateDynamicInfo(fieldName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$fieldName - 計算說明', style: TextStyle(fontSize: 20)),
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(dynamicInfo, style: TextStyle(fontSize: 16)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('確定', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  String _generateDynamicInfo(String fieldName) {
    // 獲取用戶輸入的實際數字
    double contractCapacity = double.tryParse(contractCapacityController.text) ?? 0;
    double maxDemand = double.tryParse(maxDemandController.text) ?? 0;
    double billingUnits = double.tryParse(billingUnitsController.text) ?? 0;
    double currentLightWatt = double.tryParse(currentLightWattController.text) ?? 0;
    double lightCount = double.tryParse(lightCountController.text) ?? 0;

    // 根據時間種類決定電價
    double capacityPrice = timeTypeSummer ? summerCapacityPrice : nonSummerCapacityPrice;
    double unitPrice = timeTypeSummer ? summerUnitPrice : nonSummerUnitPrice;
    String timeTypeText = timeTypeSummer ? '夏季' : '非夏季';
    String capacityPriceText = timeTypeSummer ? '236.2' : '173.2';
    String unitPriceText = timeTypeSummer ? '4.08' : '3.87';

    switch (fieldName) {
      case '基本電價(約定)':
        return '''表示用電容量，同時間可用多少電，超過則罰款
夏季236.2\$/度，非夏季173.2\$/度
契約容量*$timeTypeText
＝$contractCapacity*$capacityPriceText=${(contractCapacity * capacityPrice).toStringAsFixed(1)}元''';

      case '最高需量有超用契約容量':
        if (contractCapacity >= maxDemand) {
          return '''契約容量>最高需量，顯示無超約
契約容量($contractCapacity)>最高需量($maxDemand)，顯示無超約''';
        } else {
          double excess = (maxDemand - contractCapacity) * 1.5 * capacityPrice;
          return '''契約容量<最高需量，計算如下
（最高需量-契約容量）*1.5*時間種類
＝($maxDemand-$contractCapacity)*1.5*$capacityPriceText=${excess.toStringAsFixed(1)}元''';
        }

      case '流動電價':
        return '''夏季4.08\$，非夏季3.87\$
計費度數*時間種類
=$billingUnits*$unitPriceText=${(billingUnits * unitPrice).toStringAsFixed(1)}元''';

      case '總電價':
        double basic = contractCapacity * capacityPrice;
        double flow = billingUnits * unitPrice;
        double excess = maxDemand > contractCapacity ? (maxDemand - contractCapacity) * 1.5 * capacityPrice : 0;
        return '''基本電價+流動電價+超約價格
=${basic.toStringAsFixed(1)}+${flow.toStringAsFixed(1)}+${excess.toStringAsFixed(1)}=${(basic + flow + excess).toStringAsFixed(1)}元''';

      case '每月耗電(度)':
        return '''燈管瓦數*燈管數量*24小時*30天/1000
=$currentLightWatt*$lightCount*24*30/1000=${(currentLightWatt * lightCount * 24 * 30 / 1000).toStringAsFixed(1)}度''';

      case 'AI燈管每月耗電(度)':
        return '''燈管瓦數*燈管數量*8小時*30天/1000
＝${aiLightWatt}*${lightCount}*8*30/1000=${(aiLightWatt * lightCount * 8 * 30 / 1000).toStringAsFixed(1)}度''';

      case '可節電（度）':
        double before = currentLightWatt * lightCount * 24 * 30 / 1000;
        double after = aiLightWatt * lightCount * 8 * 30 / 1000;
        return '''更換前-更換後=共可節電(度)
＝${before.toStringAsFixed(1)}度-${after.toStringAsFixed(1)}度=${(before - after).toStringAsFixed(1)}度''';

      case '可節電(%)':
        double before = currentLightWatt * lightCount * 24 * 30 / 1000;
        double after = aiLightWatt * lightCount * 8 * 30 / 1000;
        double saving = before - after;
        double percent = (saving / before) * 100;
        return '''可節電(度)/每月耗電(度)*100%
＝${saving.toStringAsFixed(1)}/${before.toStringAsFixed(1)}*100%=${percent.toStringAsFixed(1)}%''';

      case '預估下期帳單費用':
        double totalElectricity = backgroundTotalElectricity;
        double savingUnits = backgroundSavingUnits;
        double nextBill = totalElectricity - (savingUnits * unitPrice);
        return '''總電價-(可節電度數*時間種類)
=${totalElectricity.toStringAsFixed(1)}-(${savingUnits.toStringAsFixed(1)}*$unitPriceText)=${nextBill.toStringAsFixed(1)}元''';

      case '共節省電費':
        double savingUnits = backgroundSavingUnits;
        return '''可節電度數*時間種類
=${savingUnits.toStringAsFixed(1)}*$unitPriceText=${(savingUnits * unitPrice).toStringAsFixed(1)}元''';

      case '每月總共可節省費用':
        double totalSaving = backgroundTotalSaving;
        double rentalFee = 0;
        if (pricingMethod == '租賃') {
          double rentalPrice = double.tryParse(rentalPriceController.text) ?? 0;
          rentalFee = rentalPrice * lightCount;
        }
        return '''共節省電費-每月燈管租賃費用
=${totalSaving.toStringAsFixed(1)}-${rentalFee.toStringAsFixed(1)}=${(totalSaving - rentalFee).toStringAsFixed(1)}元''';

      case '多久時間攤提(月)':
        double totalSaving = backgroundTotalSaving;
        double buyoutTotal = 0;
        if (pricingMethod == '買斷') {
          double buyoutPrice = double.tryParse(buyoutPriceController.text) ?? 0;
          buyoutTotal = buyoutPrice * lightCount;
        }
        return '''總費用/共節省電費
=${buyoutTotal.toStringAsFixed(1)}/${totalSaving.toStringAsFixed(1)}=${(buyoutTotal / totalSaving).toStringAsFixed(1)}個月''';

      default:
        return '暫無計算說明';
    }
  }

  Widget _buildSectionTitle(String title, {bool isRed = false}) {
    return Padding(
      padding: EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.bold,
          color: isRed ? Colors.red : null,
        ),
      ),
    );
  }

  Widget _buildSectionCard({required Widget child, Color? color}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: child,
    );
  }

  Widget _buildInputFieldWithUnit(String title, TextEditingController controller, String unit, {bool hasInfo = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionTitle(title),
            if (hasInfo) ...[
              SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showFieldInfo(title, ''),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('?', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ],
        ),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
          style: TextStyle(fontSize: 16),
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            suffixText: unit,
            suffixStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyFieldWithUnit(String title, TextEditingController controller, String unit, {bool grayed = false, bool isRed = false, bool hasInfo = false, bool titleRed = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionTitle(title, isRed: titleRed),
            if (hasInfo) ...[
              SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showFieldInfo(title, ''),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('?', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ],
        ),
        MouseRegion(
          cursor: SystemMouseCursors.forbidden,
          child: TextField(
            controller: controller,
            readOnly: true,
            enableInteractiveSelection: false,
            mouseCursor: SystemMouseCursors.forbidden,
            style: TextStyle(
              fontSize: 16,
              color: grayed ? Colors.grey[500] : (isRed ? Colors.red : null),
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              fillColor: grayed ? Colors.grey[300] : Colors.grey[100],
              filled: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              suffixText: unit,
              suffixStyle: TextStyle(fontSize: 14, color: grayed ? Colors.grey[500] : Colors.grey[600]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('燈管計價方式'),
        RadioListTile<String>(
          title: Row(
            children: [
              Text('租賃', style: TextStyle(fontSize: 16)),
              SizedBox(width: 16),
              if (pricingMethod == '租賃') ...[
                Expanded(
                  child: TextField(
                    controller: rentalPriceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      isDense: true,
                      suffixText: '元/支/月',
                    ),
                  ),
                ),
              ],
            ],
          ),
          value: '租賃',
          groupValue: pricingMethod,
          onChanged: (value) {
            setState(() {
              pricingMethod = value;
            });
            _updateNotification();
          },
        ),
        RadioListTile<String>(
          title: Row(
            children: [
              Text('買斷', style: TextStyle(fontSize: 16)),
              SizedBox(width: 16),
              if (pricingMethod == '買斷') ...[
                Expanded(
                  child: TextField(
                    controller: buyoutPriceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      isDense: true,
                      suffixText: '元/支',
                    ),
                  ),
                ),
              ],
            ],
          ),
          value: '買斷',
          groupValue: pricingMethod,
          onChanged: (value) {
            setState(() {
              pricingMethod = value;
            });
            _updateNotification();
          },
        ),
      ],
    );
  }

  Widget _buildStatusBar() {
    Color statusColor = needsRecalculation 
        ? Colors.red 
        : (isCalculated ? Colors.green : Colors.blue);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        border: Border.all(color: statusColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        statusController.text,
        style: TextStyle(
          fontSize: 18,
          color: statusColor,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('智慧AI燈管電力換算', style: TextStyle(fontSize: isDesktop ? 24 : 20)),
        centerTitle: true,
      ),
      body: Center( // 卡片置中
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isDesktop ? 800 : 600), // 調整最大寬度
            child: Column(
              children: [
                // 第一步：提供台電帳單資訊
                _buildSectionCard(
                  color: Colors.blue[50],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('第一步：提供台電帳單資訊', 
                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      
                      // 輸入區塊
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[25],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blue[200]!, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 固定勾選項目（不可取消）
                            CheckboxListTile(
                              title: Text('電力需量非營業用', style: TextStyle(fontSize: 16)),
                              value: electricityTypeNonBusiness,
                              onChanged: null, // 設為null表示不可變更
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),
                            
                            CheckboxListTile(
                              title: Text('非時間電價', style: TextStyle(fontSize: 16)),
                              value: timeTypeNonTime,
                              onChanged: null, // 設為null表示不可變更
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: CheckboxListTile(
                                    title: Text('夏季(6/1–9/30)', style: TextStyle(fontSize: 16)),
                                    value: timeTypeSummer,
                                    onChanged: (value) {
                                      setState(() {
                                        timeTypeSummer = value ?? false;
                                        if (value == true) timeTypeNonSummer = false;
                                      });
                                      _updateNotification();
                                    },
                                    controlAffinity: ListTileControlAffinity.leading,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                Expanded(
                                  child: CheckboxListTile(
                                    title: Text('非夏季', style: TextStyle(fontSize: 16)),
                                    value: timeTypeNonSummer,
                                    onChanged: (value) {
                                      setState(() {
                                        timeTypeNonSummer = value ?? false;
                                        if (value == true) timeTypeSummer = false;
                                      });
                                      _updateNotification();
                                    },
                                    controlAffinity: ListTileControlAffinity.leading,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 8),
                            _buildInputFieldWithUnit('契約容量', contractCapacityController, '瓩'),
                            SizedBox(height: 8),
                            _buildInputFieldWithUnit('最高需量', maxDemandController, '瓩'),
                            SizedBox(height: 8),
                            _buildInputFieldWithUnit('計費度數', billingUnitsController, '度'),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      // 結果區塊
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[25],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blue[200]!, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildReadOnlyFieldWithUnit('基本電價(約定)', basicElectricityController, '元', hasInfo: true),
                            SizedBox(height: 8),
                            _buildReadOnlyFieldWithUnit('最高需量有超用契約容量', excessDemandController, '元', hasInfo: true),
                            SizedBox(height: 8),
                            _buildReadOnlyFieldWithUnit('流動電價', flowElectricityController, '元', hasInfo: true),
                            SizedBox(height: 8),
                            _buildReadOnlyFieldWithUnit('總電價', totalElectricityController, '元', hasInfo: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 第二步：更換 AI 燈管後電力試算
                _buildSectionCard(
                  color: Colors.green[50],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('第二步：更換 AI 燈管後電力試算', 
                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      
                      // 更換前區塊
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[25],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.green[200]!, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputFieldWithUnit('目前使用燈管瓦數', currentLightWattController, 'W'),
                            SizedBox(height: 8),
                            _buildInputFieldWithUnit('燈管數量', lightCountController, '支'),
                            SizedBox(height: 8),
                            _buildReadOnlyFieldWithUnit('每月耗電(度)', monthlyConsumptionBeforeController, '度', hasInfo: true),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      Text('更換AI燈管後 (僅供參考，亮燈策略將影響實際成果)', 
                           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      
                      // 更換後區塊
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[25],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.green[200]!, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildReadOnlyFieldWithUnit('目前使用AI燈管瓦數', aiLightWattController, 'W'),
                            SizedBox(height: 8),
                            _buildReadOnlyFieldWithUnit('AI燈管數量', aiLightCountController, '支'),
                            SizedBox(height: 8),
                            _buildReadOnlyFieldWithUnit('AI燈管每月耗電(度)', monthlyConsumptionAfterController, '度', hasInfo: true),
                            SizedBox(height: 8),
                            _buildReadOnlyFieldWithUnit('可節電（度）', savingUnitsController, '度', hasInfo: true),
                            SizedBox(height: 8),
                            _buildReadOnlyFieldWithUnit('可節電(%)', savingPercentController, '%', hasInfo: true),
                            SizedBox(height: 8),
                            _buildReadOnlyFieldWithUnit('預估下期帳單費用', nextBillController, '元', hasInfo: true),
                            SizedBox(height: 8),
                            _buildReadOnlyFieldWithUnit('共節省電費', totalSavingController, '元', isRed: true, titleRed: true, hasInfo: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 第三步：試算攤提時間
                _buildSectionCard(
                  color: Colors.orange[50],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('第三步：試算攤提時間', 
                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      
                      // 輸入區塊
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[25],
                          borderRadius: BorderRadius.circular(6),
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
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[25],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.orange[200]!, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 固定顯示燈管數量（無論租賃或買斷）
                            _buildReadOnlyFieldWithUnit('燈管數量', aiLightCountController, '支'),
                            SizedBox(height: 8),
                            // 根據選擇顯示對應欄位
                            if (pricingMethod == '租賃') ...[
                              _buildReadOnlyFieldWithUnit('每月燈管租賃費用', monthlyRentalController, '元'),
                              SizedBox(height: 8),
                              _buildReadOnlyFieldWithUnit('每月總共可節省費用', totalMonthlySavingController, '元', isRed: true, titleRed: true, hasInfo: true),
                            ],
                            if (pricingMethod == '買斷') ...[
                              _buildReadOnlyFieldWithUnit('買斷總費用', buyoutTotalController, '元'),
                              SizedBox(height: 8),
                              _buildReadOnlyFieldWithUnit('多久時間攤提(月)', paybackPeriodController, '個月', isRed: true, titleRed: true, hasInfo: true),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 計算結果按鈕 - 置中
                Center(
                  child: Container(
                    width: isDesktop ? 300 : double.infinity,
                    child: ElevatedButton(
                      onPressed: _calculateResults,
                      child: Text('計算結果', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),

                // 狀態欄
                _buildStatusBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}