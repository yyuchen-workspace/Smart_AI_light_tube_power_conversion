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
  
  // 各步驟計算狀態
  bool step1Calculated = false; // 第一步(AI燈管)計算狀態
  bool step2Calculated = false; // 第二步(台電帳單)計算狀態  
  bool step3Calculated = false; // 第三步(攤提時間)計算狀態
  
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
    
    // 不再使用 addListener，改為在 TextField 中使用 onChanged
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

    // 驗證第一步輸入（必填）
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

    // 檢查第二步是否已填寫（選填）
    bool hasStep2Data = contractCapacityController.text.isNotEmpty && 
                       maxDemandController.text.isNotEmpty && 
                       billingUnitsController.text.isNotEmpty;
    
    // 如果第二步有填寫，則需要驗證
    if (hasStep2Data) {
      double? contractCapacity = double.tryParse(contractCapacityController.text);
      if (contractCapacity == null || contractCapacity <= 0) {
        errors.add('契約容量必須為正數');
      }
      double? maxDemand = double.tryParse(maxDemandController.text);
      if (maxDemand == null || maxDemand <= 0) {
        errors.add('最高需量必須為正數');
      }
      double? billingUnits = double.tryParse(billingUnitsController.text);
      if (billingUnits == null || billingUnits <= 0) {
        errors.add('計費度數必須為正數');
      }
    }

    // 檢查第三步是否已填寫（選填）
    bool hasStep3Data = false;
    if (pricingMethod == '租賃' && rentalPriceController.text.isNotEmpty) {
      hasStep3Data = true;
      double? value = double.tryParse(rentalPriceController.text);
      if (value == null || value <= 0) {
        errors.add('租賃價格必須為正數');
      }
    }
    if (pricingMethod == '買斷' && buyoutPriceController.text.isNotEmpty) {
      hasStep3Data = true;
      double? value = double.tryParse(buyoutPriceController.text);
      if (value == null || value <= 0) {
        errors.add('買斷價格必須為正數');
      }
    }

    if (errors.isNotEmpty) {
      _showErrorDialog(errors);
      return;
    }

    // 執行計算
    double currentLightWatt = double.parse(currentLightWattController.text);
    double lightCount = double.parse(lightCountController.text);
    
    // 根據時間種類決定電價（為了計算節省電費）
    double unitPrice = timeTypeSummer ? summerUnitPrice : nonSummerUnitPrice;

    // 第一步計算（AI燈管計算，始終執行）
    double monthlyConsumptionBefore = currentLightWatt * lightCount * 24 * 30 / 1000;
    double monthlyConsumptionAfter = aiLightWatt * lightCount * 8 * 30 / 1000;
    double savingUnits = monthlyConsumptionBefore - monthlyConsumptionAfter;
    backgroundSavingUnits = savingUnits;
    double savingPercent = (savingUnits / monthlyConsumptionBefore) * 100;

    // 第二步計算（台電帳單，條件性執行）
    double basicElectricity = 0.0;
    double excessDemand = 0.0;
    String excessText = '無超約';
    double flowElectricity = 0.0;
    double totalElectricity = 0.0;
    double nextBill = 0.0;
    double totalSaving = 0.0;
    
    if (hasStep2Data) {
      double contractCapacity = double.parse(contractCapacityController.text);
      double maxDemand = double.parse(maxDemandController.text);
      double billingUnits = double.parse(billingUnitsController.text);
      
      double capacityPrice = timeTypeSummer ? summerCapacityPrice : nonSummerCapacityPrice;
      
      basicElectricity = contractCapacity * capacityPrice;
      backgroundBasicElectricity = basicElectricity;

      if (maxDemand > contractCapacity) {
        excessDemand = (maxDemand - contractCapacity) * 1.5 * capacityPrice;
        excessText = _roundUpFirstDecimal(excessDemand).toStringAsFixed(1);
      }

      flowElectricity = billingUnits * unitPrice;
      backgroundFlowElectricity = flowElectricity;

      totalElectricity = basicElectricity + flowElectricity + excessDemand;
      backgroundTotalElectricity = totalElectricity;
      
      nextBill = totalElectricity - (savingUnits * unitPrice);
      
      if (nextBill < 0) {
        _showErrorDialog(['所輸入的燈管瓦數不合邏輯，無法計算']);
        return;
      }

      totalSaving = savingUnits * unitPrice;
      backgroundTotalSaving = totalSaving;
    }

    // 第三步計算（攤提時間，條件性執行）
    double monthlyRental = 0.0;
    double buyoutTotal = 0.0;
    double totalMonthlySaving = 0.0;
    double paybackPeriod = 0.0;

    if (hasStep3Data && hasStep2Data) {
      if (pricingMethod == '租賃' && rentalPriceController.text.isNotEmpty) {
        double rentalPrice = double.parse(rentalPriceController.text);
        monthlyRental = rentalPrice * lightCount;
        totalMonthlySaving = totalSaving - monthlyRental;
      } else if (pricingMethod == '買斷' && buyoutPriceController.text.isNotEmpty) {
        double buyoutPrice = double.parse(buyoutPriceController.text);
        buyoutTotal = buyoutPrice * lightCount;
        paybackPeriod = buyoutTotal / totalSaving;
      }
    }

    // 更新UI
    setState(() {
      isCalculated = true;
      needsRecalculation = false;
      
      // 更新各步驟計算狀態
      step1Calculated = true; // 第一步始終計算
      step2Calculated = hasStep2Data;
      step3Calculated = hasStep3Data && hasStep2Data;
      
      // 生成狀態訊息
      List<String> successSteps = [];
      if (step1Calculated) successSteps.add('第一步');
      if (step2Calculated) successSteps.add('第二步');
      if (step3Calculated) successSteps.add('第三步');
      statusController.text = '${successSteps.join('、')}計算成功！';

      // 第一步結果（AI燈管，始終顯示）
      monthlyConsumptionBeforeController.text = _roundUpFirstDecimal(monthlyConsumptionBefore).toStringAsFixed(1);
      monthlyConsumptionAfterController.text = _roundUpFirstDecimal(monthlyConsumptionAfter).toStringAsFixed(1);
      savingUnitsController.text = _roundUpFirstDecimal(savingUnits).toStringAsFixed(1);
      savingPercentController.text = _roundUpFirstDecimal(savingPercent).toStringAsFixed(1);

      // 第二步結果（台電帳單，條件性顯示）
      if (hasStep2Data) {
        basicElectricityController.text = _roundUpFirstDecimal(basicElectricity).toStringAsFixed(1);
        excessDemandController.text = excessText;
        flowElectricityController.text = _roundUpFirstDecimal(flowElectricity).toStringAsFixed(1);
        totalElectricityController.text = _roundUpFirstDecimal(totalElectricity).toStringAsFixed(1);
        nextBillController.text = _roundUpFirstDecimal(nextBill).toStringAsFixed(1);
        totalSavingController.text = _roundUpFirstDecimal(totalSaving).toStringAsFixed(1);
      } else {
        // 清空第二步相關結果
        basicElectricityController.text = '';
        excessDemandController.text = '';
        flowElectricityController.text = '';
        totalElectricityController.text = '';
        nextBillController.text = '電費帳單無填寫';
        totalSavingController.text = '電費帳單無填寫';
      }

      // 第三步結果（攤提時間，條件性顯示）
      if (hasStep3Data && hasStep2Data) {
        if (pricingMethod == '租賃') {
          monthlyRentalController.text = _roundUpFirstDecimal(monthlyRental).toStringAsFixed(1);
          totalMonthlySavingController.text = _roundUpFirstDecimal(totalMonthlySaving).toStringAsFixed(1);
        } else {
          buyoutTotalController.text = _roundUpFirstDecimal(buyoutTotal).toStringAsFixed(1);
          paybackPeriodController.text = _roundUpFirstDecimal(paybackPeriod).toStringAsFixed(1);
        }
      } else {
        // 清空第三步相關結果
        monthlyRentalController.text = '';
        buyoutTotalController.text = '';
        if (!hasStep2Data) {
          totalMonthlySavingController.text = '電費帳單無填寫';
          paybackPeriodController.text = '電費帳單無填寫';
        } else {
          totalMonthlySavingController.text = '';
          paybackPeriodController.text = '';
        }
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

  bool _shouldShowRedText(String fieldName) {
    // 判斷是否應該顯示紅字（當欄位內容包含"電費帳單無填寫"時）
    if (['共節省電費', '每月總共可節省費用', '多久時間攤提(月)'].contains(fieldName)) {
      bool hasStep2Data = contractCapacityController.text.isNotEmpty && 
                         maxDemandController.text.isNotEmpty && 
                         billingUnitsController.text.isNotEmpty;
      return !hasStep2Data;
    }
    return false;
  }

  List<String> _checkMissingFieldsForInfo(String fieldName) {
    List<String> missing = [];
    
    // 第一步相關欄位檢查
    if (['每月耗電(度)', 'AI燈管每月耗電(度)', '可節電（度）', '可節電（%）'].contains(fieldName)) {
      // 首先檢查相關欄位是否已填寫
      if (currentLightWattController.text.isEmpty) missing.add('目前使用燈管瓦數未填寫');
      if (lightCountController.text.isEmpty) missing.add('燈管數量未填寫');
      
      // 如果有欄位未填寫，直接返回
      if (missing.isNotEmpty) return missing;
      
      // 所有欄位都填寫了，才檢查是否已計算
      if (!isCalculated || needsRecalculation) {
        missing.add('請先點擊「計算結果」按鈕進行計算');
        return missing;
      }
      
      // 檢查第一步是否計算成功
      if (!step1Calculated) {
        missing.add('第一步未計算成功');
      }
      
      return missing;
    }
    
    // 第二步相關欄位檢查
    if (['基本電價(約定)', '最高需量有超用契約容量', '流動電價', '總電價'].contains(fieldName)) {
      // 首先檢查第二步相關欄位是否已填寫
      if (contractCapacityController.text.isEmpty) missing.add('契約容量未填寫');
      if (maxDemandController.text.isEmpty) missing.add('最高需量未填寫');
      if (billingUnitsController.text.isEmpty) missing.add('計費度數未填寫');
      
      // 如果有欄位未填寫，直接返回
      if (missing.isNotEmpty) return missing;
      
      // 所有欄位都填寫了，才檢查是否已計算
      if (!isCalculated || needsRecalculation) {
        missing.add('請先點擊「計算結果」按鈕進行計算');
        return missing;
      }
      
      // 檢查第二步是否計算成功
      if (!step2Calculated) {
        missing.add('第二步未計算成功');
      }
      
      return missing;
    }
    
    // 跨步驟關聯欄位檢查（需要第一步和第二步都計算成功）
    if (['預估下期帳單費用', '共節省電費'].contains(fieldName)) {
      // 首先檢查相關欄位是否已填寫
      if (currentLightWattController.text.isEmpty) missing.add('目前使用燈管瓦數未填寫');
      if (lightCountController.text.isEmpty) missing.add('燈管數量未填寫');
      if (contractCapacityController.text.isEmpty) missing.add('契約容量未填寫');
      if (maxDemandController.text.isEmpty) missing.add('最高需量未填寫');
      if (billingUnitsController.text.isEmpty) missing.add('計費度數未填寫');
      
      // 如果有欄位未填寫，直接返回
      if (missing.isNotEmpty) return missing;
      
      // 所有欄位都填寫了，才檢查是否已計算
      if (!isCalculated || needsRecalculation) {
        missing.add('請先點擊「計算結果」按鈕進行計算');
        return missing;
      }
      
      if (!step1Calculated) {
        missing.add('第一步未計算成功');
      }
      if (!step2Calculated) {
        missing.add('第二步未計算成功');
      }
      
      return missing;
    }
    
    // 第三步基本欄位檢查（只需要基本數據填寫）
    if (['每月燈管租賃費用', '買斷總費用'].contains(fieldName)) {
      // 檢查燈管數量
      if (lightCountController.text.isEmpty) missing.add('燈管數量未填寫');
      
      // 檢查對應的價格欄位
      if (fieldName == '每月燈管租賃費用' && rentalPriceController.text.isEmpty) {
        missing.add('租賃價格未填寫');
      } else if (fieldName == '買斷總費用' && buyoutPriceController.text.isEmpty) {
        missing.add('買斷價格未填寫');
      }
      
      // 如果有欄位未填寫，直接返回
      if (missing.isNotEmpty) return missing;
      
      // 所有欄位都填寫了，才檢查是否已計算
      if (!isCalculated || needsRecalculation) {
        missing.add('請先點擊「計算結果」按鈕進行計算');
        return missing;
      }
      
      // 檢查第三步是否計算成功
      if (!step3Calculated) {
        missing.add('第三步未計算成功');
      }
      
      return missing;
    }
    
    // 第三步相關欄位檢查（需要第一步、第二步和第三步都計算成功）
    if (['每月總共可節省費用', '多久時間攤提(月)'].contains(fieldName)) {
      // 首先檢查相關欄位是否已填寫
      if (contractCapacityController.text.isEmpty) missing.add('契約容量未填寫');
      if (maxDemandController.text.isEmpty) missing.add('最高需量未填寫');
      if (billingUnitsController.text.isEmpty) missing.add('計費度數未填寫');
      if (currentLightWattController.text.isEmpty) missing.add('目前使用燈管瓦數未填寫');
      if (lightCountController.text.isEmpty) missing.add('燈管數量未填寫');
      
      // 檢查第三步自己的數據
      if (pricingMethod == '租賃' && rentalPriceController.text.isEmpty) {
        missing.add('租賃價格未填寫');
      } else if (pricingMethod == '買斷' && buyoutPriceController.text.isEmpty) {
        missing.add('買斷價格未填寫');
      }
      
      // 如果有欄位未填寫，直接返回
      if (missing.isNotEmpty) return missing;
      
      // 所有欄位都填寫了，才檢查是否已計算
      if (!isCalculated || needsRecalculation) {
        missing.add('請先點擊「計算結果」按鈕進行計算');
        return missing;
      }
      
      // 檢查所有相關步驟是否都計算成功
      if (!step1Calculated) {
        missing.add('第一步未計算成功');
      }
      if (!step2Calculated) {
        missing.add('第二步未計算成功');
      }
      if (!step3Calculated) {
        missing.add('第三步未計算成功');
      }
      
      return missing;
    }
    
    return missing;
  }

  void _showFieldInfo(String fieldName, String info) {
    // 檢查相關欄位填寫狀態
    List<String> missingFields = _checkMissingFieldsForInfo(fieldName);
    
    if (missingFields.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('提醒', style: TextStyle(fontSize: 20, color: Colors.red)),
          content: Text('${missingFields.join('、')}', style: TextStyle(fontSize: 16)),
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
    String capacityPriceText = timeTypeSummer ? '236.2' : '173.2';
    String unitPriceText = timeTypeSummer ? '4.08' : '3.87';

    switch (fieldName) {
      case '基本電價(約定)':
        double result = contractCapacity * capacityPrice;
        String seasonText = timeTypeSummer ? '夏季' : '非夏季';
        return '''表示用電容量，同時間可用多少電，超過則罰款
夏季236.2\$/度，非夏季173.2\$/度
契約容量*$seasonText
＝$contractCapacity*$capacityPriceText=${_roundUpFirstDecimal(result).toStringAsFixed(1)}元''';

      case '最高需量有超用契約容量':
        if (contractCapacity >= maxDemand) {
          return '''契約容量>最高需量，顯示無超約
契約容量($contractCapacity)>最高需量($maxDemand)，顯示無超約''';
        } else {
          double excess = (maxDemand - contractCapacity) * 1.5 * capacityPrice;
          String seasonText = timeTypeSummer ? '夏季' : '非夏季';
          return '''契約容量<最高需量，計算如下
（最高需量-契約容量）*1.5*$seasonText
＝($maxDemand-$contractCapacity)*1.5*$capacityPriceText=${_roundUpFirstDecimal(excess).toStringAsFixed(1)}元''';
        }

      case '流動電價':
        double result = billingUnits * unitPrice;
        String seasonText = timeTypeSummer ? '夏季' : '非夏季';
        return '''夏季4.08\$，非夏季3.87\$
計費度數*$seasonText
=$billingUnits*$unitPriceText=${_roundUpFirstDecimal(result).toStringAsFixed(1)}元''';

      case '總電價':
        double basic = contractCapacity * capacityPrice;
        double flow = billingUnits * unitPrice;
        double excess = maxDemand > contractCapacity ? (maxDemand - contractCapacity) * 1.5 * capacityPrice : 0;
        double total = basic + flow + excess;
        return '''基本電價+流動電價+超約價格
=${_roundUpFirstDecimal(basic).toStringAsFixed(1)}+${_roundUpFirstDecimal(flow).toStringAsFixed(1)}+${_roundUpFirstDecimal(excess).toStringAsFixed(1)}=${_roundUpFirstDecimal(total).toStringAsFixed(1)}元''';

      case '每月耗電(度)':
        double result = currentLightWatt * lightCount * 24 * 30 / 1000;
        return '''燈管瓦數*燈管數量*24小時*30天/1000
=$currentLightWatt*${lightCount.toStringAsFixed(0)}*24*30/1000=${_roundUpFirstDecimal(result).toStringAsFixed(1)}度''';

      case 'AI燈管每月耗電(度)':
        double result = aiLightWatt * lightCount * 8 * 30 / 1000;
        return '''燈管瓦數*燈管數量*8小時*30天/1000
＝${aiLightWatt.toStringAsFixed(0)}*${lightCount.toStringAsFixed(0)}*8*30/1000=${_roundUpFirstDecimal(result).toStringAsFixed(1)}度''';

      case '可節電（度）':
        double before = currentLightWatt * lightCount * 24 * 30 / 1000;
        double after = aiLightWatt * lightCount * 8 * 30 / 1000;
        double saving = before - after;
        return '''更換前使用度數-更換後使用度數=共可節電(度)
＝${_roundUpFirstDecimal(before).toStringAsFixed(1)}度-${_roundUpFirstDecimal(after).toStringAsFixed(1)}度=${_roundUpFirstDecimal(saving).toStringAsFixed(1)}度''';

      case '可節電（%）':
        double before = currentLightWatt * lightCount * 24 * 30 / 1000;
        double after = aiLightWatt * lightCount * 8 * 30 / 1000;
        double saving = before - after;
        double percent = (saving / before) * 100;
        return '''可節電(度)/更換前使用度數*100%
＝${_roundUpFirstDecimal(saving).toStringAsFixed(1)}/${_roundUpFirstDecimal(before).toStringAsFixed(1)}*100%=${_roundUpFirstDecimal(percent).toStringAsFixed(1)}%''';

      case '預估下期帳單費用':
        double totalElectricity = backgroundTotalElectricity;
        double savingUnits = backgroundSavingUnits;
        double nextBill = totalElectricity - (savingUnits * unitPrice);
        String seasonText = timeTypeSummer ? '夏季每度電費' : '非夏季每度電費';
        return '''夏季4.08\$，非夏季3.87\$
總電價-(可節電度數*$seasonText)
=${_roundUpFirstDecimal(totalElectricity).toStringAsFixed(1)}-(${_roundUpFirstDecimal(savingUnits).toStringAsFixed(1)}*$unitPriceText)=${_roundUpFirstDecimal(nextBill).toStringAsFixed(1)}元''';

      case '共節省電費':
        double savingUnits = backgroundSavingUnits;
        double totalSaving = savingUnits * unitPrice;
        String seasonText = timeTypeSummer ? '夏季每度電費' : '非夏季每度電費';
        return '''夏季4.08\$，非夏季3.87\$
可節電度數*$seasonText
=${_roundUpFirstDecimal(savingUnits).toStringAsFixed(1)}*$unitPriceText=${_roundUpFirstDecimal(totalSaving).toStringAsFixed(1)}元''';

      case '每月總共可節省費用':
        double totalSaving = backgroundTotalSaving;
        double rentalFee = 0;
        if (pricingMethod == '租賃') {
          double rentalPrice = double.tryParse(rentalPriceController.text) ?? 0;
          rentalFee = rentalPrice * lightCount;
        }
        double netSaving = totalSaving - rentalFee;
        return '''共節省電費-每月燈管租賃費用
=${_roundUpFirstDecimal(totalSaving).toStringAsFixed(1)}-${_roundUpFirstDecimal(rentalFee).toStringAsFixed(1)}=${_roundUpFirstDecimal(netSaving).toStringAsFixed(1)}元''';

      case '每月燈管租賃費用':
        double rentalPrice = double.tryParse(rentalPriceController.text) ?? 0;
        double totalRental = rentalPrice * lightCount;
        return '''每支燈管租賃費*燈管支數
=${rentalPrice.toStringAsFixed(0)}*${lightCount.toStringAsFixed(0)}=${_roundUpFirstDecimal(totalRental).toStringAsFixed(1)}元''';

      case '買斷總費用':
        double buyoutPrice = double.tryParse(buyoutPriceController.text) ?? 0;
        double totalBuyout = buyoutPrice * lightCount;
        return '''每支燈管買斷費*燈管支數
=${buyoutPrice.toStringAsFixed(0)}*${lightCount.toStringAsFixed(0)}=${_roundUpFirstDecimal(totalBuyout).toStringAsFixed(1)}元''';

      case '多久時間攤提(月)':
        double totalSaving = backgroundTotalSaving;
        double buyoutTotal = 0;
        if (pricingMethod == '買斷') {
          double buyoutPrice = double.tryParse(buyoutPriceController.text) ?? 0;
          buyoutTotal = buyoutPrice * lightCount;
        }
        double paybackPeriod = buyoutTotal / totalSaving;
        return '''總費用/共節省電費
=${_roundUpFirstDecimal(buyoutTotal).toStringAsFixed(1)}/${_roundUpFirstDecimal(totalSaving).toStringAsFixed(1)}=${_roundUpFirstDecimal(paybackPeriod).toStringAsFixed(1)}個月''';

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
      padding: EdgeInsets.all(20), // 增加內邊距讓內容更透氣
      decoration: BoxDecoration(
        color: color ?? Colors.grey[50],
        borderRadius: BorderRadius.circular(12), // 增加圓角讓外觀更現代
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInputFieldWithUnit(String title, TextEditingController controller, String unit, {bool hasInfo = false, void Function(String)? onChanged, bool integerOnly = false}) {
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
        SizedBox(
          height: 56, // 固定高度
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: TextInputType.number,
            inputFormatters: [
              integerOnly 
                ? FilteringTextInputFormatter.digitsOnly
                : FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
            ],
            style: TextStyle(fontSize: 16),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              fillColor: Colors.white,
              filled: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              suffixText: unit,
              suffixStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
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
        SizedBox(
          height: 56, // 固定高度
          child: MouseRegion(
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
                fillColor: grayed ? Colors.grey[300] : Colors.white,
                filled: grayed,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                suffixText: unit,
                suffixStyle: TextStyle(fontSize: 14, color: grayed ? Colors.grey[500] : Colors.grey[600]),
              ),
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
                    onChanged: (_) => _updateNotification(),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
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
                    onChanged: (_) => _updateNotification(),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
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
            constraints: BoxConstraints(maxWidth: isDesktop ? 1400 : 600), // 調整最大寬度以適應三欄佈局
            child: Column(
              children: [
                // 第一步和第二步並排布局
                if (isDesktop) ...[
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 第一步：更換AI燈管後電力試算
                        Expanded(
                        flex: 1,
                        child: _buildSectionCard(
                          color: Colors.green[50],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text('第一步：更換AI燈管後電力試算', 
                                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                              SizedBox(height: 16),
                              
                              // 三欄分佈佈局
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 左邊：更換前區塊
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Text('原燈管', 
                                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        ),
                                        SizedBox(height: 12),
                                        
                                        Container(
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.green[25],
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.green[200]!, width: 1),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              _buildInputFieldWithUnit('目前使用燈管瓦數', currentLightWattController, 'W', onChanged: (_) => _updateNotification()),
                                              SizedBox(height: 12),
                                              _buildInputFieldWithUnit('燈管數量', lightCountController, '支', integerOnly: true, onChanged: (value) {
                                                _updateNotification();
                                                _syncLightCount();
                                              }),
                                              SizedBox(height: 12),
                                              _buildReadOnlyFieldWithUnit('每月耗電(度)', monthlyConsumptionBeforeController, '度', hasInfo: true),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  SizedBox(width: 12),
                                  
                                  // 右邊：更換後資訊與計算結果
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Text('更換AI燈管後 (僅供參考，亮燈策略將影響實際成果)', 
                                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        ),
                                        SizedBox(height: 12),
                                        
                                        Container(
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.green[25],
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.green[200]!, width: 1),
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // 左半部：AI燈管基本資訊
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    _buildReadOnlyFieldWithUnit('目前使用AI燈管瓦數', aiLightWattController, 'W'),
                                                    SizedBox(height: 12),
                                                    _buildReadOnlyFieldWithUnit('AI燈管數量', aiLightCountController, '支'),
                                                    SizedBox(height: 12),
                                                    _buildReadOnlyFieldWithUnit('AI燈管每月耗電(度)', monthlyConsumptionAfterController, '度', hasInfo: true),
                                                  ],
                                                ),
                                              ),
                                              
                                              SizedBox(width: 12),
                                              
                                              // 右半部：計算結果
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    _buildReadOnlyFieldWithUnit('可節電（度）', savingUnitsController, '度', isRed: true, titleRed: true, hasInfo: true),
                                                    SizedBox(height: 12),
                                                    _buildReadOnlyFieldWithUnit('可節電（%）', savingPercentController, '%', isRed: true, titleRed: true, hasInfo: true),
                                                    SizedBox(height: 12),
                                                    _buildReadOnlyFieldWithUnit('預估下期帳單費用', nextBillController, '元', hasInfo: true),
                                                    SizedBox(height: 12),
                                                    _buildReadOnlyFieldWithUnit('共節省電費', totalSavingController, '元', isRed: _shouldShowRedText('共節省電費') || true, titleRed: _shouldShowRedText('共節省電費') || true, hasInfo: true),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(width: 12),
                      
                      // 第二步：提供台電帳單資訊
                      Expanded(
                        flex: 1,
                        child: _buildSectionCard(
                          color: Colors.blue[50],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text('第二步：提供台電帳單資訊(選填)', 
                                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                              SizedBox(height: 16),
                              
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
                                          
                                          CheckboxListTile(
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
                                          
                                          CheckboxListTile(
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
                                          
                                          SizedBox(height: 12),
                                          _buildInputFieldWithUnit('契約容量', contractCapacityController, '瓩', onChanged: (_) => _updateNotification()),
                                          SizedBox(height: 12),
                                          _buildInputFieldWithUnit('最高需量', maxDemandController, '瓩', onChanged: (_) => _updateNotification()),
                                          SizedBox(height: 12),
                                          _buildInputFieldWithUnit('計費度數', billingUnitsController, '度', onChanged: (_) => _updateNotification()),
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
                                          _buildReadOnlyFieldWithUnit('基本電價(約定)', basicElectricityController, '元', hasInfo: true),
                                          SizedBox(height: 12),
                                          _buildReadOnlyFieldWithUnit('最高需量有超用契約容量', excessDemandController, '元', hasInfo: true),
                                          SizedBox(height: 12),
                                          _buildReadOnlyFieldWithUnit('流動電價', flowElectricityController, '元', hasInfo: true),
                                          SizedBox(height: 12),
                                          _buildReadOnlyFieldWithUnit('總電價', totalElectricityController, '元', hasInfo: true),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    ),
                  ),
                  
                  // 第三步：試算攤提時間 - 位於第一步之下，與第二步對齊
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2, // 改為與上方第一步和第二步相同的寬度
                        child: _buildSectionCard(
                          color: Colors.orange[50],
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 內容區塊：保持原來的寬度
                              Container(
                                width: 500, // 固定寬度，防止內容跟隨卡片拉長
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Text('第三步：試算攤提時間(選填)', 
                                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    ),
                                    SizedBox(height: 16),
                                    
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
                                          _buildReadOnlyFieldWithUnit('燈管數量', aiLightCountController, '支'),
                                          SizedBox(height: 12),
                                          // 根據選擇顯示對應欄位
                                          if (pricingMethod == '租賃') ...[
                                            _buildReadOnlyFieldWithUnit('每月燈管租賃費用', monthlyRentalController, '元', hasInfo: true),
                                            SizedBox(height: 12),
                                            _buildReadOnlyFieldWithUnit('每月總共可節省費用', totalMonthlySavingController, '元', isRed: _shouldShowRedText('每月總共可節省費用') || true, titleRed: _shouldShowRedText('每月總共可節省費用') || true, hasInfo: true),
                                          ],
                                          if (pricingMethod == '買斷') ...[
                                            _buildReadOnlyFieldWithUnit('買斷總費用', buyoutTotalController, '元', hasInfo: true),
                                            SizedBox(height: 12),
                                            _buildReadOnlyFieldWithUnit('多久時間攤提(月)', paybackPeriodController, '個月', isRed: _shouldShowRedText('多久時間攤提(月)') || true, titleRed: _shouldShowRedText('多久時間攤提(月)') || true, hasInfo: true),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 右邊保留空白區域，讓卡片延伸對齊
                              Expanded(child: Container()),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // 手機版保持原來的垂直布局
                  _buildSectionCard(
                    color: Colors.blue[50],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text('第一步：更換 AI 燈管後電力試算', 
                               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(height: 16),
                        
                        Center(
                          child: Text('原燈管', 
                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(height: 12),
                        
                        // 更換前區塊
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green[25],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green[200]!, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInputFieldWithUnit('目前使用燈管瓦數', currentLightWattController, 'W', onChanged: (_) => _updateNotification()),
                              SizedBox(height: 12),
                              _buildInputFieldWithUnit('燈管數量', lightCountController, '支', integerOnly: true, onChanged: (value) {
                                _updateNotification();
                                _syncLightCount();
                              }),
                              SizedBox(height: 12),
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
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green[25],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green[200]!, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildReadOnlyFieldWithUnit('目前使用AI燈管瓦數', aiLightWattController, 'W'),
                              SizedBox(height: 12),
                              _buildReadOnlyFieldWithUnit('AI燈管數量', aiLightCountController, '支'),
                              SizedBox(height: 12),
                              _buildReadOnlyFieldWithUnit('AI燈管每月耗電(度)', monthlyConsumptionAfterController, '度', hasInfo: true),
                              SizedBox(height: 12),
                              _buildReadOnlyFieldWithUnit('可節電（度）', savingUnitsController, '度', isRed: true, titleRed: true, hasInfo: true),
                              SizedBox(height: 12),
                              _buildReadOnlyFieldWithUnit('可節電（%）', savingPercentController, '%', isRed: true, titleRed: true, hasInfo: true),
                              SizedBox(height: 12),
                              _buildReadOnlyFieldWithUnit('預估下期帳單費用', nextBillController, '元', hasInfo: true),
                              SizedBox(height: 12),
                              _buildReadOnlyFieldWithUnit('共節省電費', totalSavingController, '元', isRed: _shouldShowRedText('共節省電費') || true, titleRed: _shouldShowRedText('共節省電費') || true, hasInfo: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 第二步：提供台電帳單資訊
                  _buildSectionCard(
                    color: Colors.blue[50],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text('第二步：提供台電帳單資訊(選填)', 
                               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(height: 16),
                        
                        // 輸入區塊
                        Container(
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
                              
                              SizedBox(height: 12),
                              _buildInputFieldWithUnit('契約容量', contractCapacityController, '瓩', onChanged: (_) => _updateNotification()),
                              SizedBox(height: 12),
                              _buildInputFieldWithUnit('最高需量', maxDemandController, '瓩', onChanged: (_) => _updateNotification()),
                              SizedBox(height: 12),
                              _buildInputFieldWithUnit('計費度數', billingUnitsController, '度', onChanged: (_) => _updateNotification()),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 16),
                        
                        // 結果區塊
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[25],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildReadOnlyFieldWithUnit('基本電價(約定)', basicElectricityController, '元', hasInfo: true),
                              SizedBox(height: 12),
                              _buildReadOnlyFieldWithUnit('最高需量有超用契約容量', excessDemandController, '元', hasInfo: true),
                              SizedBox(height: 12),
                              _buildReadOnlyFieldWithUnit('流動電價', flowElectricityController, '元', hasInfo: true),
                              SizedBox(height: 12),
                              _buildReadOnlyFieldWithUnit('總電價', totalElectricityController, '元', hasInfo: true),
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
                        Center(
                          child: Text('第三步：試算攤提時間(選填)', 
                               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(height: 16),
                        
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
                              _buildReadOnlyFieldWithUnit('燈管數量', aiLightCountController, '支'),
                              SizedBox(height: 12),
                              // 根據選擇顯示對應欄位
                              if (pricingMethod == '租賃') ...[
                                _buildReadOnlyFieldWithUnit('每月燈管租賃費用', monthlyRentalController, '元', hasInfo: true),
                                SizedBox(height: 12),
                                _buildReadOnlyFieldWithUnit('每月總共可節省費用', totalMonthlySavingController, '元', isRed: _shouldShowRedText('每月總共可節省費用') || true, titleRed: _shouldShowRedText('每月總共可節省費用') || true, hasInfo: true),
                              ],
                              if (pricingMethod == '買斷') ...[
                                _buildReadOnlyFieldWithUnit('買斷總費用', buyoutTotalController, '元', hasInfo: true),
                                SizedBox(height: 12),
                                _buildReadOnlyFieldWithUnit('多久時間攤提(月)', paybackPeriodController, '個月', isRed: _shouldShowRedText('多久時間攤提(月)') || true, titleRed: _shouldShowRedText('多久時間攤提(月)') || true, hasInfo: true),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // 狀態欄
                _buildStatusBar(),

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
              ],
            ),
          ),
        ),
      ),
    );
  }
}