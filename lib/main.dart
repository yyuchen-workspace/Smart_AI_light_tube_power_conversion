/*
 * ============================================================
 * 智慧AI燈管電力換算應用程式 v2.0
 * ============================================================
 *
 * 新版架構：步驟式流程 + 主欄側欄佈局
 */

import 'package:flutter/material.dart';

// 新版頁面元件
import 'pages/step1_ai_lights.dart';
// import 'pages/step2_bill_info.dart'; // 暫時隱藏 Step 2
import 'pages/step3_payback.dart';

// UI 元件
import 'widgets/step_indicator.dart';
import 'widgets/charts/electricity_cost_pie_chart.dart'; // 需保留（複雜計算模式用）
import 'widgets/charts/power_saving_chart.dart';
import 'widgets/charts/payback_summary_chart.dart';

// 計算工具與常數
import 'utils/lighting_calculator.dart';
import 'utils/electricity_calculator.dart';
import 'models/lighting_strategy.dart';
import 'constants/electricity_pricing.dart';
import 'constants/brightness_wattage_map.dart';

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
        useMaterial3: true,
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
  // ==================== 功能開關 ====================

  /// 【計算模式切換】
  /// true = 使用台電複雜計算（基本電價 + 流動電價 + 超約費用）
  /// false = 使用簡化計算（度數 × 平均電價）
  static const bool USE_COMPLEX_ELECTRICITY_CALCULATION = false;

  // ==================== 狀態變數 ====================

  // 當前步驟 (0: Step1, 1: Step2, 2: Step3)
  int _currentStep = 0;

  // 是否已計算
  bool _hasCalculated = false;

  // 手機版滾動控制器
  final ScrollController _mobileScrollController = ScrollController();

  // ==================== State Variables ====================

  // 傳統燈管
  final TextEditingController traditionalWattController =
      TextEditingController(text: '18');
  final TextEditingController traditionalLightCountController =
      TextEditingController(text: '0');

  // 車道燈策略
  final TextEditingController drivewayCountController =
      TextEditingController(text: '0');
  bool drivewayAllDay = false;
  TimeOfDay drivewayDaytimeStart = TimeOfDay(hour: 6, minute: 0);
  TimeOfDay drivewayDaytimeEnd = TimeOfDay(hour: 23, minute: 59);
  int drivewayDayBrightnessBefore = 30;
  int drivewayDayBrightnessAfter = 70;
  int drivewayDaySensingTime = 10;
  TimeOfDay drivewayNighttimeStart = TimeOfDay(hour: 23, minute: 59);
  TimeOfDay drivewayNighttimeEnd = TimeOfDay(hour: 6, minute: 0);
  int drivewayNightBrightnessBefore = 10;
  int drivewayNightBrightnessAfter = 70;
  int drivewayNightSensingTime = 10;
  final TextEditingController drivewayDaySensingCountController =
      TextEditingController(text: '2325');
  final TextEditingController drivewayNightSensingCountController =
      TextEditingController(text: '285');

  // 車位燈策略
  final TextEditingController parkingCountController =
      TextEditingController(text: '0');
  bool parkingAllDay = true;
  TimeOfDay parkingDaytimeStart = TimeOfDay(hour: 6, minute: 0);
  TimeOfDay parkingDaytimeEnd = TimeOfDay(hour: 23, minute: 59);
  int parkingDayBrightnessBefore = 0;
  int parkingDayBrightnessAfter = 50;
  int parkingDaySensingTime = 120;
  TimeOfDay parkingNighttimeStart = TimeOfDay(hour: 23, minute: 59);
  TimeOfDay parkingNighttimeEnd = TimeOfDay(hour: 6, minute: 0);
  int parkingNightBrightnessBefore = 0;
  int parkingNightBrightnessAfter = 50;
  int parkingNightSensingTime = 120;
  final TextEditingController parkingDaySensingCountController =
      TextEditingController(text: '35');
  final TextEditingController parkingNightSensingCountController =
      TextEditingController(text: '5');

  // Step 2: 台電帳單資訊
  bool timeTypeSummer = true; // 預設夏季
  bool timeTypeNonSummer = false;
  final TextEditingController contractCapacityController =
      TextEditingController();
  final TextEditingController maxDemandController = TextEditingController();
  final TextEditingController billingUnitsController = TextEditingController();
  final TextEditingController basicElectricityController =
      TextEditingController();
  final TextEditingController excessDemandController = TextEditingController();
  final TextEditingController flowElectricityController =
      TextEditingController();
  final TextEditingController totalElectricityController =
      TextEditingController();
  bool step1Calculated = false;
  bool step2Calculated = false;

  // Step 3: 攤提時間試算
  String? pricingMethod = '租賃'; // 預設租賃
  final TextEditingController rentalPriceController =
      TextEditingController(text: '0');
  final TextEditingController buyoutPriceController =
      TextEditingController(text: '0');
  final TextEditingController step3LightCountController =
      TextEditingController(text: '0');
  final TextEditingController monthlyRentalController = TextEditingController();
  final TextEditingController totalMonthlySavingController =
      TextEditingController();
  final TextEditingController buyoutTotalController = TextEditingController();
  final TextEditingController paybackPeriodController = TextEditingController();
  bool step3Calculated = false;

  // 計算結果
  double? aiMonthlyConsumption;
  double? traditionalMonthlyConsumption;
  double? monthlySavings;
  double? savingsRate;

  // 日間/夜間計算結果
  double? drivewayDaytimeConsumption;
  double? drivewayNighttimeConsumption;
  double? parkingDaytimeConsumption;
  double? parkingNighttimeConsumption;

  // 圖表組件
  Widget? pieChart;
  Widget? powerSavingChart;
  Widget? paybackSummaryChart;

  @override
  void dispose() {
    traditionalWattController.dispose();
    traditionalLightCountController.dispose();
    drivewayCountController.dispose();
    parkingCountController.dispose();
    contractCapacityController.dispose();
    maxDemandController.dispose();
    billingUnitsController.dispose();
    basicElectricityController.dispose();
    excessDemandController.dispose();
    flowElectricityController.dispose();
    totalElectricityController.dispose();
    rentalPriceController.dispose();
    buyoutPriceController.dispose();
    step3LightCountController.dispose();
    monthlyRentalController.dispose();
    totalMonthlySavingController.dispose();
    buyoutTotalController.dispose();
    paybackPeriodController.dispose();
    _mobileScrollController.dispose();
    super.dispose();
  }

  // ==================== Methods ====================

  // ==================== 錯誤處理與備註功能 ====================

  /// 顯示錯誤對話框
  void _showErrorDialog(List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('錯誤', style: TextStyle(fontSize: 24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: errors
              .map((error) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Text('• $error', style: TextStyle(fontSize: 20)),
                  ))
              .toList(),
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

  /// 顯示計算成功對話框
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('計算成功',
                style: TextStyle(fontSize: 24, color: Colors.green[700])),
          ],
        ),
        content: Text(
          '所有計算已完成！',
          style: TextStyle(fontSize: 20),
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

  /// 顯示欄位計算說明
  void _showFieldInfo(String fieldName) {
    String info = _generateDynamicInfo(fieldName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$fieldName - 計算說明', style: TextStyle(fontSize: 20)),
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(info, style: TextStyle(fontSize: 16)),
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

  /// 動態生成計算說明內容
  String _generateDynamicInfo(String fieldName) {
    // 獲取用戶輸入的實際數字
    double traditionalWatt =
        double.tryParse(traditionalWattController.text) ?? 0;
    double traditionalCount =
        double.tryParse(traditionalLightCountController.text) ?? 0;
    int drivewayCount = int.tryParse(drivewayCountController.text) ?? 0;
    int parkingCount = int.tryParse(parkingCountController.text) ?? 0;
    double contractCapacity =
        double.tryParse(contractCapacityController.text) ?? 0;
    double maxDemand = double.tryParse(maxDemandController.text) ?? 0;
    double billingUnits = double.tryParse(billingUnitsController.text) ?? 0;

    // 根據時間種類決定電價
    double capacityPrice =
        ElectricityCalculator.getCapacityPrice(timeTypeSummer);
    double unitPrice = ElectricityCalculator.getUnitPrice(timeTypeSummer);
    String capacityPriceText = timeTypeSummer ? '236.2' : '173.2';
    String unitPriceText = timeTypeSummer ? '4.08' : '3.87';
    String seasonText = timeTypeSummer ? '夏季' : '非夏季';

    switch (fieldName) {
      // ========== Step 1 備註 ==========
      case '每月耗電(度)':
      case '傳統燈管每月耗電':
        double result = traditionalWatt * traditionalCount * 24 * 30 / 1000;
        return '''燈管瓦數*燈管數量*24小時*30天/1000
=$traditionalWatt*${traditionalCount.toStringAsFixed(0)}*24*30/1000=${result.toStringAsFixed(1)}度''';

      case 'AI燈管每月耗電(度)':
      case 'AI燈管每月耗電':
        double drivewayTotal =
            ElectricityPricing.drivewayLightWatt * drivewayCount;
        double parkingTotal =
            ElectricityPricing.parkingLightWatt * parkingCount;
        double result = (drivewayTotal + parkingTotal) * 30 / 1000;
        return '''車道燈：
尖峰7小時:感應前亮30%，感應後亮70%
離峰11小時:感應前亮20%，感應後亮60%
凌晨6小時:感應前0%，感應後50%
車道燈平均每日消耗瓦數:${ElectricityPricing.drivewayLightWatt}W
故${ElectricityPricing.drivewayLightWatt}W*${drivewayCount}支燈管=${drivewayTotal}W

車位燈：
全天候:感應前亮0%，感應後亮50%
車位燈平均消耗瓦數:${ElectricityPricing.parkingLightWatt}W
故${ElectricityPricing.parkingLightWatt}W*${parkingCount}支燈管=${parkingTotal}W

($drivewayTotal+$parkingTotal)*30天/1000=${result.toStringAsFixed(1)}度(kwh)''';

      case '車道燈數量':
        return '''尖峰7小時:感應前亮30%，感應後亮70%
離峰11小時:感應前亮20%，感應後亮60%
凌晨6小時:感應前0%，感應後50%
車道燈平均每日消耗瓦數:${ElectricityPricing.drivewayLightWatt}W''';

      case '車位燈數量':
        return '''全天候:感應前亮0%，感應後亮50%
車位燈平均消耗瓦數:${ElectricityPricing.parkingLightWatt}W''';

      // ========== 車道燈日間/夜間時段資訊 ==========
      case '車道燈-日間時段':
        return _generateDrivewayDaytimeInfo();

      case '車道燈-夜間時段':
        return _generateDrivewayNighttimeInfo();

      // ========== 車位燈日間/夜間時段資訊 ==========
      case '車位燈-日間時段':
        return _generateParkingDaytimeInfo();

      case '車位燈-夜間時段':
        return _generateParkingNighttimeInfo();

      case '每月節電量':
      case '可節電（度）':
        double before = traditionalWatt * traditionalCount * 24 * 30 / 1000;
        double after = aiMonthlyConsumption ?? 0;
        double saving = before - after;
        return '''更換前使用度數-更換後使用度數=共可節電(度)
＝${before.toStringAsFixed(1)}度-${after.toStringAsFixed(1)}度=${saving.toStringAsFixed(1)}度''';

      case '節電率':
      case '可節電（%）':
        double before = traditionalWatt * traditionalCount * 24 * 30 / 1000;
        double after = aiMonthlyConsumption ?? 0;
        double saving = before - after;
        double percent = before > 0 ? (saving / before) * 100 : 0;
        return '''可節電(度)/更換前使用度數*100%
＝${saving.toStringAsFixed(1)}/${before.toStringAsFixed(1)}*100%=${percent.toStringAsFixed(1)}%''';

      // ========== Step 2 備註 ==========
      case '基本電價(約定)':
        double result = contractCapacity * capacityPrice;
        return '''表示用電容量，同時間可用多少電，超過則罰款
夏季236.2\$/度，非夏季173.2\$/度
契約容量*$seasonText
＝$contractCapacity*$capacityPriceText=${result.toStringAsFixed(1)}元''';

      case '最高需量有超用契約容量':
        if (contractCapacity >= maxDemand) {
          return '''契約容量>最高需量，顯示無超約
契約容量($contractCapacity)>最高需量($maxDemand)，顯示無超約''';
        } else {
          double excess = (maxDemand - contractCapacity) * 1.5 * capacityPrice;
          return '''契約容量<最高需量，計算如下
（最高需量-契約容量）*1.5*$seasonText
＝($maxDemand-$contractCapacity)*1.5*$capacityPriceText=${excess.toStringAsFixed(1)}元''';
        }

      case '流動電價':
        double result = billingUnits * unitPrice;
        return '''夏季4.08\$，非夏季3.87\$
計費度數*$seasonText
=$billingUnits*$unitPriceText=${result.toStringAsFixed(1)}元''';

      case '總電價':
        double basic = contractCapacity * capacityPrice;
        double flow = billingUnits * unitPrice;
        double excess = maxDemand > contractCapacity
            ? (maxDemand - contractCapacity) * 1.5 * capacityPrice
            : 0;
        double total = basic + flow + excess;
        return '''基本電價+流動電價+超約價格
=${basic.toStringAsFixed(1)}+${flow.toStringAsFixed(1)}+${excess.toStringAsFixed(1)}=${total.toStringAsFixed(1)}元''';

      case '預估下期帳單費用':
        double totalElectricity =
            double.tryParse(totalElectricityController.text) ?? 0;
        double savingUnits = monthlySavings ?? 0;
        double nextBill = totalElectricity - (savingUnits * unitPrice);
        return '''夏季4.08\$，非夏季3.87\$
總電價-(可節電度數*$seasonText每度電費)
=${totalElectricity.toStringAsFixed(1)}-(${savingUnits.toStringAsFixed(1)}*$unitPriceText)=${nextBill.toStringAsFixed(1)}元''';

      case '共節省電費':
      case '可節省電費':
        double savingUnits = monthlySavings ?? 0;
        double totalSaving = savingUnits * unitPrice;
        return '''夏季4.08\$，非夏季3.87\$
可節電度數*$seasonText每度電費
=${savingUnits.toStringAsFixed(1)}*$unitPriceText=${totalSaving.toStringAsFixed(1)}元''';

      // ========== Step 3 備註 ==========
      case '每月燈管租賃費用':
        double rentalPrice = double.tryParse(rentalPriceController.text) ?? 0;
        double step3LightCount =
            double.tryParse(step3LightCountController.text) ?? 0;
        double totalRental = rentalPrice * step3LightCount;
        return '''每支燈管租賃費*燈管支數
=${rentalPrice.toStringAsFixed(0)}*${step3LightCount.toStringAsFixed(0)}=${totalRental.toStringAsFixed(1)}元''';

      case '每月總共可節省費用':
        double savingUnits = monthlySavings ?? 0;
        double totalSaving = savingUnits * unitPrice;
        double rentalFee = 0;
        if (pricingMethod == '租賃') {
          double rentalPrice = double.tryParse(rentalPriceController.text) ?? 0;
          double step3LightCount =
              double.tryParse(step3LightCountController.text) ?? 0;
          rentalFee = rentalPrice * step3LightCount;
        }
        double netSaving = totalSaving - rentalFee;
        return '''共節省電費-每月燈管租賃費用
=${totalSaving.toStringAsFixed(1)}-${rentalFee.toStringAsFixed(1)}=${netSaving.toStringAsFixed(1)}元''';

      case '買斷總費用':
        double buyoutPrice = double.tryParse(buyoutPriceController.text) ?? 0;
        double step3LightCount =
            double.tryParse(step3LightCountController.text) ?? 0;
        double totalBuyout = buyoutPrice * step3LightCount;
        return '''每支燈管買斷費*燈管支數
=${buyoutPrice.toStringAsFixed(0)}*${step3LightCount.toStringAsFixed(0)}=${totalBuyout.toStringAsFixed(1)}元''';

      case '多久時間攤提(月)':
        double savingUnits = monthlySavings ?? 0;
        double totalSaving = savingUnits * unitPrice;
        double buyoutTotal = 0;
        if (pricingMethod == '買斷') {
          double buyoutPrice = double.tryParse(buyoutPriceController.text) ?? 0;
          double step3LightCount =
              double.tryParse(step3LightCountController.text) ?? 0;
          buyoutTotal = buyoutPrice * step3LightCount;
        }
        double paybackPeriod = totalSaving > 0 ? buyoutTotal / totalSaving : 0;
        return '''總費用/共節省電費
=${buyoutTotal.toStringAsFixed(1)}/${totalSaving.toStringAsFixed(1)}=${paybackPeriod.toStringAsFixed(1)}個月''';

      default:
        return '此欄位暫無說明';
    }
  }

  /// 生成車道燈日間時段資訊
  String _generateDrivewayDaytimeInfo() {
    int count = int.tryParse(drivewayCountController.text) ?? 0;
    double startHour =
        drivewayDaytimeStart.hour + drivewayDaytimeStart.minute / 60.0;
    double endHour = drivewayDaytimeEnd.hour + drivewayDaytimeEnd.minute / 60.0;
    double duration =
        endHour > startHour ? endHour - startHour : 24 - startHour + endHour;

    int brightnessBefore = drivewayDayBrightnessBefore;
    int brightnessAfter = drivewayDayBrightnessAfter;
    int sensingTime = drivewayDaySensingTime;

    double wattBefore = BrightnessWattageMap.getWattage(brightnessBefore);
    double wattAfter = BrightnessWattageMap.getWattage(brightnessAfter);

    // 使用使用者輸入的感應次數
    int sensingCount = int.tryParse(drivewayDaySensingCountController.text) ??
        LightingCalculator.drivewayDaytimeSensing;
    double sensingDurationInHours = sensingCount * sensingTime / 3600.0;

    double perLightWattage = duration * wattBefore +
        sensingDurationInHours * (wattAfter - wattBefore);
    double monthlyConsumption = perLightWattage * count * 30 / 1000;

    return '''車道燈日間
時間：${duration.toStringAsFixed(2)}小時
感應前：$brightnessBefore%（${wattBefore.toStringAsFixed(1)}W）
感應後：$brightnessAfter%（${wattAfter.toStringAsFixed(1)}W）
持續時間：$sensingTime 秒
模擬人車感應次數$sensingCount次

每支車道燈消耗瓦數
${duration.toStringAsFixed(2)}小時*$brightnessBefore%亮度瓦數(${wattBefore.toStringAsFixed(1)}W)+${sensingDurationInHours.toStringAsFixed(2)}小時($sensingCount*$sensingTime 秒）*$brightnessAfter%亮度瓦數（${wattAfter.toStringAsFixed(1)}W-${wattBefore.toStringAsFixed(1)}W）=${perLightWattage.toStringAsFixed(2)}W

總共車道燈日間月消耗度數
${perLightWattage.toStringAsFixed(2)}W *$count支燈管*30天/1000=${monthlyConsumption.toStringAsFixed(2)} 度''';
  }

  /// 生成車道燈夜間時段資訊
  String _generateDrivewayNighttimeInfo() {
    if (drivewayAllDay) {
      return '目前為全天候模式，無夜間時段設定';
    }

    int count = int.tryParse(drivewayCountController.text) ?? 0;
    double startHour =
        drivewayNighttimeStart.hour + drivewayNighttimeStart.minute / 60.0;
    double endHour =
        drivewayNighttimeEnd.hour + drivewayNighttimeEnd.minute / 60.0;
    double duration =
        endHour > startHour ? endHour - startHour : 24 - startHour + endHour;

    int brightnessBefore = drivewayNightBrightnessBefore;
    int brightnessAfter = drivewayNightBrightnessAfter;
    int sensingTime = drivewayNightSensingTime;

    double wattBefore = BrightnessWattageMap.getWattage(brightnessBefore);
    double wattAfter = BrightnessWattageMap.getWattage(brightnessAfter);

    // 使用使用者輸入的感應次數
    int sensingCount = int.tryParse(drivewayNightSensingCountController.text) ??
        LightingCalculator.drivewayNighttimeSensing;
    double sensingDurationInHours = sensingCount * sensingTime / 3600.0;

    double perLightWattage = duration * wattBefore +
        sensingDurationInHours * (wattAfter - wattBefore);
    double monthlyConsumption = perLightWattage * count * 30 / 1000;

    return '''車道燈夜間
時間：${duration.toStringAsFixed(2)}小時
感應前：$brightnessBefore%（${wattBefore.toStringAsFixed(1)}W）
感應後：$brightnessAfter%（${wattAfter.toStringAsFixed(1)}W）
持續時間：$sensingTime 秒
模擬人車感應次數$sensingCount次

每支車道燈消耗瓦數
${duration.toStringAsFixed(2)}小時*$brightnessBefore%亮度瓦數(${wattBefore.toStringAsFixed(1)}W)+${sensingDurationInHours.toStringAsFixed(2)}小時($sensingCount*$sensingTime 秒）*$brightnessAfter%亮度瓦數（${wattAfter.toStringAsFixed(1)}W-${wattBefore.toStringAsFixed(1)}W）=${perLightWattage.toStringAsFixed(2)}W

總共車道燈夜間月消耗度數
${perLightWattage.toStringAsFixed(2)}W *$count支燈管*30天/1000=${monthlyConsumption.toStringAsFixed(2)} 度''';
  }

  /// 生成車位燈日間時段資訊
  String _generateParkingDaytimeInfo() {
    int count = int.tryParse(parkingCountController.text) ?? 0;
    double startHour =
        parkingDaytimeStart.hour + parkingDaytimeStart.minute / 60.0;
    double endHour = parkingDaytimeEnd.hour + parkingDaytimeEnd.minute / 60.0;
    double duration =
        endHour > startHour ? endHour - startHour : 24 - startHour + endHour;

    int brightnessBefore = parkingDayBrightnessBefore;
    int brightnessAfter = parkingDayBrightnessAfter;
    int sensingTime = parkingDaySensingTime;

    double wattBefore = BrightnessWattageMap.getWattage(brightnessBefore);
    double wattAfter = BrightnessWattageMap.getWattage(brightnessAfter);

    // 使用使用者輸入的感應次數
    int sensingCount = int.tryParse(parkingDaySensingCountController.text) ??
        LightingCalculator.parkingDaytimeSensing;
    double sensingDurationInHours = sensingCount * sensingTime / 3600.0;

    double perLightWattage = duration * wattBefore +
        sensingDurationInHours * (wattAfter - wattBefore);
    double monthlyConsumption = perLightWattage * count * 30 / 1000;

    return '''車位燈日間
時間：${duration.toStringAsFixed(2)}小時
感應前：$brightnessBefore%（${wattBefore.toStringAsFixed(1)}W）
感應後：$brightnessAfter%（${wattAfter.toStringAsFixed(1)}W）
持續時間：$sensingTime 秒
模擬人車感應次數$sensingCount次

每支車位燈消耗瓦數
${duration.toStringAsFixed(2)}小時*$brightnessBefore%亮度瓦數(${wattBefore.toStringAsFixed(1)}W)+${sensingDurationInHours.toStringAsFixed(2)}小時($sensingCount*$sensingTime 秒）*$brightnessAfter%亮度瓦數（${wattAfter.toStringAsFixed(1)}W-${wattBefore.toStringAsFixed(1)}W）=${perLightWattage.toStringAsFixed(2)}W

總共車位燈日間月消耗度數
${perLightWattage.toStringAsFixed(2)}W *$count支燈管*30天/1000=${monthlyConsumption.toStringAsFixed(2)} 度''';
  }

  /// 生成車位燈夜間時段資訊
  String _generateParkingNighttimeInfo() {
    if (parkingAllDay) {
      return '目前為全天候模式，無夜間時段設定';
    }

    int count = int.tryParse(parkingCountController.text) ?? 0;
    double startHour =
        parkingNighttimeStart.hour + parkingNighttimeStart.minute / 60.0;
    double endHour =
        parkingNighttimeEnd.hour + parkingNighttimeEnd.minute / 60.0;
    double duration =
        endHour > startHour ? endHour - startHour : 24 - startHour + endHour;

    int brightnessBefore = parkingNightBrightnessBefore;
    int brightnessAfter = parkingNightBrightnessAfter;
    int sensingTime = parkingNightSensingTime;

    double wattBefore = BrightnessWattageMap.getWattage(brightnessBefore);
    double wattAfter = BrightnessWattageMap.getWattage(brightnessAfter);

    // 使用使用者輸入的感應次數
    int sensingCount = int.tryParse(parkingNightSensingCountController.text) ??
        LightingCalculator.parkingNighttimeSensing;
    double sensingDurationInHours = sensingCount * sensingTime / 3600.0;

    double perLightWattage = duration * wattBefore +
        sensingDurationInHours * (wattAfter - wattBefore);
    double monthlyConsumption = perLightWattage * count * 30 / 1000;

    return '''車位燈夜間
時間：${duration.toStringAsFixed(2)}小時
感應前：$brightnessBefore%（${wattBefore.toStringAsFixed(1)}W）
感應後：$brightnessAfter%（${wattAfter.toStringAsFixed(1)}W）
持續時間：$sensingTime 秒
模擬人車感應次數$sensingCount次

每支車位燈消耗瓦數
${duration.toStringAsFixed(2)}小時*$brightnessBefore%亮度瓦數(${wattBefore.toStringAsFixed(1)}W)+${sensingDurationInHours.toStringAsFixed(2)}小時($sensingCount*$sensingTime 秒）*$brightnessAfter%亮度瓦數（${wattAfter.toStringAsFixed(1)}W-${wattBefore.toStringAsFixed(1)}W）=${perLightWattage.toStringAsFixed(2)}W

總共車位燈夜間月消耗度數
${perLightWattage.toStringAsFixed(2)}W *$count支燈管*30天/1000=${monthlyConsumption.toStringAsFixed(2)} 度''';
  }

  // ==================== 計算方法 ====================

  /// Step 2 驗證與計算
  /* Step 2 計算方法（暫時隱藏）
  void _calculateStep2() {
    List<String> errors = [];

    // 驗證契約容量
    if (contractCapacityController.text.isEmpty) {
      errors.add('請填寫契約容量');
    } else {
      double? value = double.tryParse(contractCapacityController.text);
      if (value == null || value == 0) {
        errors.add('契約容量不可為 0');
      }
    }

    // 驗證最高需量
    if (maxDemandController.text.isEmpty) {
      errors.add('請填寫最高需量');
    } else {
      double? value = double.tryParse(maxDemandController.text);
      if (value == null || value == 0) {
        errors.add('最高需量不可為 0');
      }
    }

    // 驗證計費度數
    if (billingUnitsController.text.isEmpty) {
      errors.add('請填寫計費度數');
    } else {
      double? value = double.tryParse(billingUnitsController.text);
      if (value == null || value == 0) {
        errors.add('計費度數不可為 0');
      }
    }

    // 檢查 Step 1 是否已計算
    if (monthlySavings == null) {
      errors.add('請先完成 Step 1 計算');
    }

    // 如果有錯誤，顯示錯誤對話框
    if (errors.isNotEmpty) {
      _showErrorDialog(errors);
      return;
    }

    // 驗證通過，執行計算
    _calculateResults();
  }
  */

  /// Step 3 驗證與計算
  void _calculateStep3() {
    List<String> errors = [];

    // 驗證燈管數量
    if (step3LightCountController.text.isEmpty) {
      errors.add('請填寫燈管數量');
    } else {
      double? value = double.tryParse(step3LightCountController.text);
      if (value == null || value == 0) {
        errors.add('燈管數量不可為 0');
      }
    }

    // 驗證計價方式
    if (pricingMethod == null) {
      errors.add('請選擇計價方式（租賃或買斷）');
    } else {
      // 驗證租賃價格
      if (pricingMethod == '租賃' && rentalPriceController.text.isEmpty) {
        errors.add('請填寫租賃價格');
      } else if (pricingMethod == '租賃') {
        double? value = double.tryParse(rentalPriceController.text);
        if (value == null || value == 0) {
          errors.add('租賃價格不可為 0');
        }
      }

      // 驗證買斷價格
      if (pricingMethod == '買斷' && buyoutPriceController.text.isEmpty) {
        errors.add('請填寫買斷價格');
      } else if (pricingMethod == '買斷') {
        double? value = double.tryParse(buyoutPriceController.text);
        if (value == null || value == 0) {
          errors.add('買斷價格不可為 0');
        }
      }
    }

    // 檢查前置步驟是否已計算
    // 簡化模式：檢查 Step 1；複雜模式：檢查 Step 2
    if (USE_COMPLEX_ELECTRICITY_CALCULATION) {
      if (!step2Calculated) {
        errors.add('請先完成 Step 2 計算');
      }
    } else {
      if (!step1Calculated) {
        errors.add('請先完成 Step 1 計算');
      }
    }

    // 如果有錯誤，顯示錯誤對話框
    if (errors.isNotEmpty) {
      _showErrorDialog(errors);
      return;
    }

    // 驗證通過，執行計算
    _calculateResults();
  }

  /// 滾動到頂部（手機版）
  void _scrollToTop() {
    // 使用 WidgetsBinding 確保在 UI 更新後執行滾動
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mobileScrollController.hasClients) {
        _mobileScrollController.animateTo(
          0.0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Step 1 計算（只計算 Step 1 的結果）
  void _calculateStep1Only() {
    setState(() {
      // 建立車道燈策略
      int drivewayCount = int.tryParse(drivewayCountController.text) ?? 0;
      var drivewayStrategy = LightingStrategy(
        count: drivewayCount,
        daytime: TimeSlotConfig(
          startHour:
              drivewayDaytimeStart.hour + drivewayDaytimeStart.minute / 60.0,
          endHour: drivewayDaytimeEnd.hour + drivewayDaytimeEnd.minute / 60.0,
          isAllDay: drivewayAllDay,
          brightness: BrightnessConfig(
            brightnessBeforeSensing: drivewayDayBrightnessBefore,
            brightnessAfterSensing: drivewayDayBrightnessAfter,
            sensingDuration: drivewayDaySensingTime,
          ),
        ),
        nighttime: drivewayAllDay
            ? null
            : TimeSlotConfig(
                startHour: drivewayNighttimeStart.hour +
                    drivewayNighttimeStart.minute / 60.0,
                endHour: drivewayNighttimeEnd.hour +
                    drivewayNighttimeEnd.minute / 60.0,
                isAllDay: false,
                brightness: BrightnessConfig(
                  brightnessBeforeSensing: drivewayNightBrightnessBefore,
                  brightnessAfterSensing: drivewayNightBrightnessAfter,
                  sensingDuration: drivewayNightSensingTime,
                ),
              ),
      );

      // 建立車位燈策略
      int parkingCount = int.tryParse(parkingCountController.text) ?? 0;
      var parkingStrategy = LightingStrategy(
        count: parkingCount,
        daytime: TimeSlotConfig(
          startHour:
              parkingDaytimeStart.hour + parkingDaytimeStart.minute / 60.0,
          endHour: parkingDaytimeEnd.hour + parkingDaytimeEnd.minute / 60.0,
          isAllDay: parkingAllDay,
          brightness: BrightnessConfig(
            brightnessBeforeSensing: parkingDayBrightnessBefore,
            brightnessAfterSensing: parkingDayBrightnessAfter,
            sensingDuration: parkingDaySensingTime,
          ),
        ),
        nighttime: parkingAllDay
            ? null
            : TimeSlotConfig(
                startHour: parkingNighttimeStart.hour +
                    parkingNighttimeStart.minute / 60.0,
                endHour: parkingNighttimeEnd.hour +
                    parkingNighttimeEnd.minute / 60.0,
                isAllDay: false,
                brightness: BrightnessConfig(
                  brightnessBeforeSensing: parkingNightBrightnessBefore,
                  brightnessAfterSensing: parkingNightBrightnessAfter,
                  sensingDuration: parkingNightSensingTime,
                ),
              ),
      );

      // 解析使用者輸入的感應次數
      int drivewayDayCount = int.tryParse(drivewayDaySensingCountController.text) ??
          LightingCalculator.drivewayDaytimeSensing;
      int drivewayNightCount = int.tryParse(drivewayNightSensingCountController.text) ??
          LightingCalculator.drivewayNighttimeSensing;
      int parkingDayCount = int.tryParse(parkingDaySensingCountController.text) ??
          LightingCalculator.parkingDaytimeSensing;
      int parkingNightCount = int.tryParse(parkingNightSensingCountController.text) ??
          LightingCalculator.parkingNighttimeSensing;

      // 計算AI燈管消耗
      double drivewayDailyWattage =
          LightingCalculator.calculateDrivewayWattage(
            drivewayStrategy,
            daySensingCount: drivewayDayCount,
            nightSensingCount: drivewayNightCount,
          );
      double parkingDailyWattage =
          LightingCalculator.calculateParkingWattage(
            parkingStrategy,
            daySensingCount: parkingDayCount,
            nightSensingCount: parkingNightCount,
          );

      aiMonthlyConsumption = LightingCalculator.calculateMonthlyConsumption(
              drivewayDailyWattage, drivewayCount) +
          LightingCalculator.calculateMonthlyConsumption(
              parkingDailyWattage, parkingCount);

      // 計算日間/夜間單獨的耗電量
      if (drivewayAllDay) {
        // 車道燈全天候模式
        drivewayDaytimeConsumption = LightingCalculator.calculateMonthlyConsumption(
            drivewayDailyWattage, drivewayCount);
        drivewayNighttimeConsumption = null;
      } else {
        // 車道燈分時段模式 - 需要分別計算日間和夜間
        double drivewayDayWattage = _calculateTimeSlotWattage(
            drivewayStrategy.daytime, drivewayDayCount);
        double drivewayNightWattage = _calculateTimeSlotWattage(
            drivewayStrategy.nighttime!, drivewayNightCount);
        drivewayDaytimeConsumption = LightingCalculator.calculateMonthlyConsumption(
            drivewayDayWattage, drivewayCount);
        drivewayNighttimeConsumption = LightingCalculator.calculateMonthlyConsumption(
            drivewayNightWattage, drivewayCount);
      }

      if (parkingAllDay) {
        // 車位燈全天候模式
        parkingDaytimeConsumption = LightingCalculator.calculateMonthlyConsumption(
            parkingDailyWattage, parkingCount);
        parkingNighttimeConsumption = null;
      } else {
        // 車位燈分時段模式 - 需要分別計算日間和夜間
        double parkingDayWattage = _calculateTimeSlotWattage(
            parkingStrategy.daytime, parkingDayCount);
        double parkingNightWattage = _calculateTimeSlotWattage(
            parkingStrategy.nighttime!, parkingNightCount);
        parkingDaytimeConsumption = LightingCalculator.calculateMonthlyConsumption(
            parkingDayWattage, parkingCount);
        parkingNighttimeConsumption = LightingCalculator.calculateMonthlyConsumption(
            parkingNightWattage, parkingCount);
      }

      // 計算傳統燈管消耗
      double traditionalWatt =
          double.tryParse(traditionalWattController.text) ?? 18.0;
      int traditionalCount =
          int.tryParse(traditionalLightCountController.text) ?? 0;
      traditionalMonthlyConsumption =
          ElectricityCalculator.calculateTraditionalConsumption(
        watt: traditionalWatt,
        count: traditionalCount.toDouble(),
      );

      // 計算節電量和節電率
      double savingUnits =
          traditionalMonthlyConsumption! - aiMonthlyConsumption!;
      monthlySavings = savingUnits;
      savingsRate = (monthlySavings! / traditionalMonthlyConsumption!) * 100;

      // 計算電費（簡化模式）
      double oldMonthlyCost = traditionalMonthlyConsumption! *
          (timeTypeSummer
              ? ElectricityPricing.summerAveragePrice
              : ElectricityPricing.nonSummerAveragePrice);

      double newMonthlyCost = aiMonthlyConsumption! *
          (timeTypeSummer
              ? ElectricityPricing.summerAveragePrice
              : ElectricityPricing.nonSummerAveragePrice);

      // 建立 Step 1 節電成果圖表
      powerSavingChart = PowerSavingChart(
        traditionalMonthlyConsumption: traditionalMonthlyConsumption!,
        aiMonthlyConsumption: aiMonthlyConsumption!,
        monthlySavings: monthlySavings!,
        savingsRate: savingsRate!,
        oldMonthlyCost: oldMonthlyCost,
        newMonthlyCost: newMonthlyCost,
      );

      // Step 1 計算完成
      step1Calculated = true;
      _hasCalculated = true;
    });

    // 顯示計算成功對話框
    Future.delayed(Duration(milliseconds: 100), () {
      _showSuccessDialog();
    });
  }

  /// 完成按鈕驗證與計算（只驗證 Step 3，然後計算所有步驟）
  void _validateAndCalculateAll() {
    List<String> errors = [];

    // 驗證燈管數量
    if (step3LightCountController.text.isEmpty) {
      errors.add('請填寫燈管數量');
    } else {
      double? value = double.tryParse(step3LightCountController.text);
      if (value == null || value == 0) {
        errors.add('燈管數量不可為 0');
      }
    }

    // 驗證計價方式
    if (pricingMethod == null) {
      errors.add('請選擇計價方式（租賃或買斷）');
    } else {
      // 驗證租賃價格
      if (pricingMethod == '租賃' && rentalPriceController.text.isEmpty) {
        errors.add('請填寫租賃價格');
      } else if (pricingMethod == '租賃') {
        double? value = double.tryParse(rentalPriceController.text);
        if (value == null || value == 0) {
          errors.add('租賃價格不可為 0');
        }
      }

      // 驗證買斷價格
      if (pricingMethod == '買斷' && buyoutPriceController.text.isEmpty) {
        errors.add('請填寫買斷價格');
      } else if (pricingMethod == '買斷') {
        double? value = double.tryParse(buyoutPriceController.text);
        if (value == null || value == 0) {
          errors.add('買斷價格不可為 0');
        }
      }
    }

    // 如果有錯誤，顯示錯誤對話框
    if (errors.isNotEmpty) {
      _showErrorDialog(errors);
      return;
    }

    // 驗證通過，直接計算所有步驟（不檢查前置步驟是否已計算）
    _calculateResults();
  }

  /// 計算單一時段的瓦數消耗
  double _calculateTimeSlotWattage(TimeSlotConfig timeSlot, int sensingCount) {
    double wattBefore = BrightnessWattageMap.getWattage(
      timeSlot.brightness.brightnessBeforeSensing,
    );
    double wattAfter = BrightnessWattageMap.getWattage(
      timeSlot.brightness.brightnessAfterSensing,
    );

    double duration = timeSlot.duration;
    double sensingDurationInHours =
        sensingCount * timeSlot.brightness.sensingDuration / 3600.0;

    double baseWattage = duration * wattBefore;
    double sensingWattage = sensingDurationInHours * (wattAfter - wattBefore);

    return baseWattage + sensingWattage;
  }

  /// 計算結果
  void _calculateResults() {
    setState(() {
      // 建立車道燈策略
      int drivewayCount = int.tryParse(drivewayCountController.text) ?? 0;
      var drivewayStrategy = LightingStrategy(
        count: drivewayCount,
        daytime: TimeSlotConfig(
          startHour:
              drivewayDaytimeStart.hour + drivewayDaytimeStart.minute / 60.0,
          endHour: drivewayDaytimeEnd.hour + drivewayDaytimeEnd.minute / 60.0,
          isAllDay: drivewayAllDay,
          brightness: BrightnessConfig(
            brightnessBeforeSensing: drivewayDayBrightnessBefore,
            brightnessAfterSensing: drivewayDayBrightnessAfter,
            sensingDuration: drivewayDaySensingTime,
          ),
        ),
        nighttime: drivewayAllDay
            ? null
            : TimeSlotConfig(
                startHour: drivewayNighttimeStart.hour +
                    drivewayNighttimeStart.minute / 60.0,
                endHour: drivewayNighttimeEnd.hour +
                    drivewayNighttimeEnd.minute / 60.0,
                isAllDay: false,
                brightness: BrightnessConfig(
                  brightnessBeforeSensing: drivewayNightBrightnessBefore,
                  brightnessAfterSensing: drivewayNightBrightnessAfter,
                  sensingDuration: drivewayNightSensingTime,
                ),
              ),
      );

      // 建立車位燈策略
      int parkingCount = int.tryParse(parkingCountController.text) ?? 0;
      var parkingStrategy = LightingStrategy(
        count: parkingCount,
        daytime: TimeSlotConfig(
          startHour:
              parkingDaytimeStart.hour + parkingDaytimeStart.minute / 60.0,
          endHour: parkingDaytimeEnd.hour + parkingDaytimeEnd.minute / 60.0,
          isAllDay: parkingAllDay,
          brightness: BrightnessConfig(
            brightnessBeforeSensing: parkingDayBrightnessBefore,
            brightnessAfterSensing: parkingDayBrightnessAfter,
            sensingDuration: parkingDaySensingTime,
          ),
        ),
        nighttime: parkingAllDay
            ? null
            : TimeSlotConfig(
                startHour: parkingNighttimeStart.hour +
                    parkingNighttimeStart.minute / 60.0,
                endHour: parkingNighttimeEnd.hour +
                    parkingNighttimeEnd.minute / 60.0,
                isAllDay: false,
                brightness: BrightnessConfig(
                  brightnessBeforeSensing: parkingNightBrightnessBefore,
                  brightnessAfterSensing: parkingNightBrightnessAfter,
                  sensingDuration: parkingNightSensingTime,
                ),
              ),
      );

      // 解析使用者輸入的感應次數
      int drivewayDayCount = int.tryParse(drivewayDaySensingCountController.text) ??
          LightingCalculator.drivewayDaytimeSensing;
      int drivewayNightCount = int.tryParse(drivewayNightSensingCountController.text) ??
          LightingCalculator.drivewayNighttimeSensing;
      int parkingDayCount = int.tryParse(parkingDaySensingCountController.text) ??
          LightingCalculator.parkingDaytimeSensing;
      int parkingNightCount = int.tryParse(parkingNightSensingCountController.text) ??
          LightingCalculator.parkingNighttimeSensing;

      // 計算AI燈管消耗
      double drivewayDailyWattage =
          LightingCalculator.calculateDrivewayWattage(
            drivewayStrategy,
            daySensingCount: drivewayDayCount,
            nightSensingCount: drivewayNightCount,
          );
      double parkingDailyWattage =
          LightingCalculator.calculateParkingWattage(
            parkingStrategy,
            daySensingCount: parkingDayCount,
            nightSensingCount: parkingNightCount,
          );

      aiMonthlyConsumption = LightingCalculator.calculateMonthlyConsumption(
              drivewayDailyWattage, drivewayCount) +
          LightingCalculator.calculateMonthlyConsumption(
              parkingDailyWattage, parkingCount);

      // 計算日間/夜間單獨的耗電量
      if (drivewayAllDay) {
        // 車道燈全天候模式
        drivewayDaytimeConsumption = LightingCalculator.calculateMonthlyConsumption(
            drivewayDailyWattage, drivewayCount);
        drivewayNighttimeConsumption = null;
      } else {
        // 車道燈分時段模式 - 需要分別計算日間和夜間
        double drivewayDayWattage = _calculateTimeSlotWattage(
            drivewayStrategy.daytime, drivewayDayCount);
        double drivewayNightWattage = _calculateTimeSlotWattage(
            drivewayStrategy.nighttime!, drivewayNightCount);
        drivewayDaytimeConsumption = LightingCalculator.calculateMonthlyConsumption(
            drivewayDayWattage, drivewayCount);
        drivewayNighttimeConsumption = LightingCalculator.calculateMonthlyConsumption(
            drivewayNightWattage, drivewayCount);
      }

      if (parkingAllDay) {
        // 車位燈全天候模式
        parkingDaytimeConsumption = LightingCalculator.calculateMonthlyConsumption(
            parkingDailyWattage, parkingCount);
        parkingNighttimeConsumption = null;
      } else {
        // 車位燈分時段模式 - 需要分別計算日間和夜間
        double parkingDayWattage = _calculateTimeSlotWattage(
            parkingStrategy.daytime, parkingDayCount);
        double parkingNightWattage = _calculateTimeSlotWattage(
            parkingStrategy.nighttime!, parkingNightCount);
        parkingDaytimeConsumption = LightingCalculator.calculateMonthlyConsumption(
            parkingDayWattage, parkingCount);
        parkingNighttimeConsumption = LightingCalculator.calculateMonthlyConsumption(
            parkingNightWattage, parkingCount);
      }

      // 計算傳統燈管消耗
      double traditionalWatt =
          double.tryParse(traditionalWattController.text) ?? 18.0;
      int traditionalCount =
          int.tryParse(traditionalLightCountController.text) ?? 0;
      traditionalMonthlyConsumption =
          ElectricityCalculator.calculateTraditionalConsumption(
        watt: traditionalWatt,
        count: traditionalCount.toDouble(),
      );

      // 計算節電量和節電率
      double savingUnits =
          traditionalMonthlyConsumption! - aiMonthlyConsumption!;
      monthlySavings = savingUnits;
      savingsRate = (monthlySavings! / traditionalMonthlyConsumption!) * 100;

      // ========================================
      // 電費計算模式（根據開關決定）
      // ========================================

      if (!USE_COMPLEX_ELECTRICITY_CALCULATION) {
        // ========================================
        // 【模式 A】簡化電費計算（度數 × 平均電價）
        // ========================================
        // 計算更換前每月電費（舊燈管）
        double oldMonthlyCost = traditionalMonthlyConsumption! *
            (timeTypeSummer
                ? ElectricityPricing.summerAveragePrice
                : ElectricityPricing.nonSummerAveragePrice);

        // 計算更換後每月電費（AI燈管）
        double newMonthlyCost = aiMonthlyConsumption! *
            (timeTypeSummer
                ? ElectricityPricing.summerAveragePrice
                : ElectricityPricing.nonSummerAveragePrice);

        // 建立 Step 1 節電成果圖表（使用簡化電費計算）
        powerSavingChart = PowerSavingChart(
          traditionalMonthlyConsumption:
              traditionalMonthlyConsumption!, // 節電前度數
          aiMonthlyConsumption: aiMonthlyConsumption!, // AI燈管耗電
          monthlySavings: monthlySavings!, // 每月節電量
          savingsRate: savingsRate!, // 節電率
          oldMonthlyCost: oldMonthlyCost, // 更換前每月電費
          newMonthlyCost: newMonthlyCost, // 更換後每月電費
        );

        // Step 1 計算完成
        step1Calculated = true;

        // Step 2 在簡化模式下自動標記為已計算
        step2Calculated = true;

        // Step 3: 攤提時間計算（簡化模式：使用 Step 1 的電費差額）
        bool hasStep3Data = step3LightCountController.text.isNotEmpty &&
            ((pricingMethod == '租賃' && rentalPriceController.text.isNotEmpty) ||
                (pricingMethod == '買斷' &&
                    buyoutPriceController.text.isNotEmpty));

        if (hasStep3Data) {
          double step3LightCount = double.parse(step3LightCountController.text);

          // 計算每月總共可節省費用（使用簡化模式：更換前電費 - 更換後電費）
          double totalMonthlySavingAmount = oldMonthlyCost - newMonthlyCost;

          if (pricingMethod == '租賃' && rentalPriceController.text.isNotEmpty) {
            double rentalPrice = double.parse(rentalPriceController.text);
            double monthlyRental = rentalPrice * step3LightCount;
            double totalMonthlySaving =
                totalMonthlySavingAmount - monthlyRental;

            monthlyRentalController.text =
                ElectricityCalculator.roundUpFirstDecimal(monthlyRental)
                    .toStringAsFixed(1);
            totalMonthlySavingController.text =
                ElectricityCalculator.roundUpFirstDecimal(totalMonthlySaving)
                    .toStringAsFixed(1);

            // 建立租賃模式圖表
            paybackSummaryChart = PaybackSummaryChart(
              isRental: true,
              monthlyRental: monthlyRental,
              monthlySaving: totalMonthlySaving,
            );
          } else if (pricingMethod == '買斷' &&
              buyoutPriceController.text.isNotEmpty) {
            double buyoutPrice = double.parse(buyoutPriceController.text);
            double buyoutTotal = buyoutPrice * step3LightCount;
            double paybackPeriod = buyoutTotal / totalMonthlySavingAmount;

            buyoutTotalController.text =
                ElectricityCalculator.roundUpFirstDecimal(buyoutTotal)
                    .toStringAsFixed(1);
            paybackPeriodController.text =
                ElectricityCalculator.roundUpFirstDecimal(paybackPeriod)
                    .toStringAsFixed(1);

            // 建立買斷模式圖表
            paybackSummaryChart = PaybackSummaryChart(
              isRental: false,
              buyoutTotal: buyoutTotal,
              paybackMonths: paybackPeriod,
              monthlyElectricitySaving: totalMonthlySavingAmount,
            );
          }

          step3Calculated = true;
        } else {
          // 清空 Step3 結果
          monthlyRentalController.text = '';
          totalMonthlySavingController.text = '';
          buyoutTotalController.text = '';
          paybackPeriodController.text = '';
          paybackSummaryChart = null;
          step3Calculated = false;
        }
      } else {
        // ========================================
        // 【模式 B】台電複雜計算（基本電價 + 流動電價 + 超約費用）
        // ========================================
        // Step 2: 台電帳單計算（條件性執行）
        bool hasStep2Data = contractCapacityController.text.isNotEmpty &&
            maxDemandController.text.isNotEmpty &&
            billingUnitsController.text.isNotEmpty;

        if (hasStep2Data) {
          double contractCapacity =
              double.parse(contractCapacityController.text);
          double maxDemand = double.parse(maxDemandController.text);
          double billingUnits = double.parse(billingUnitsController.text);

          // 計算基本電價
          double basicElectricity =
              ElectricityCalculator.calculateBasicElectricity(
            contractCapacity: contractCapacity,
            isSummer: timeTypeSummer,
          );

          // 計算超約費用
          double excessDemand = ElectricityCalculator.calculateExcessDemand(
            maxDemand: maxDemand,
            contractCapacity: contractCapacity,
            isSummer: timeTypeSummer,
          );
          String excessText = excessDemand > 0
              ? ElectricityCalculator.roundUpFirstDecimal(excessDemand)
                  .toStringAsFixed(1)
              : '無超約';

          // 計算流動電價
          double flowElectricity =
              ElectricityCalculator.calculateFlowElectricity(
            billingUnits: billingUnits,
            isSummer: timeTypeSummer,
          );

          // 計算總電價
          double totalElectricity =
              ElectricityCalculator.calculateTotalElectricity(
            basicElectricity: basicElectricity,
            flowElectricity: flowElectricity,
            excessDemand: excessDemand,
          );

          // 更新 Step2 結果
          basicElectricityController.text =
              ElectricityCalculator.roundUpFirstDecimal(basicElectricity)
                  .toStringAsFixed(1);
          excessDemandController.text = excessText;
          flowElectricityController.text =
              ElectricityCalculator.roundUpFirstDecimal(flowElectricity)
                  .toStringAsFixed(1);
          totalElectricityController.text =
              ElectricityCalculator.roundUpFirstDecimal(totalElectricity)
                  .toStringAsFixed(1);

          step2Calculated = true;

          // 計算電費（複雜模式：使用流動電價計算）
          double oldMonthlyCost = traditionalMonthlyConsumption! *
              (timeTypeSummer
                  ? ElectricityPricing.summerUnitPrice
                  : ElectricityPricing.nonSummerUnitPrice);
          double newMonthlyCost = aiMonthlyConsumption! *
              (timeTypeSummer
                  ? ElectricityPricing.summerUnitPrice
                  : ElectricityPricing.nonSummerUnitPrice);

          // 建立 Step 1 節電成果圖表（複雜模式也需要顯示）
          powerSavingChart = PowerSavingChart(
            traditionalMonthlyConsumption: traditionalMonthlyConsumption!,
            aiMonthlyConsumption: aiMonthlyConsumption!,
            monthlySavings: monthlySavings!,
            savingsRate: savingsRate!,
            oldMonthlyCost: oldMonthlyCost,
            newMonthlyCost: newMonthlyCost,
          );

          // Step 1 計算完成
          step1Calculated = true;

          // 建立圓餅圖
          pieChart = ElectricityCostPieChart(
            basicElectricity: basicElectricity,
            flowElectricity: flowElectricity,
            excessDemand: excessDemand > 0 ? excessDemand : 0,
          );

          // Step 3: 攤提時間計算（條件性執行，需要 Step2 數據）
          bool hasStep3Data = step3LightCountController.text.isNotEmpty &&
              ((pricingMethod == '租賃' &&
                      rentalPriceController.text.isNotEmpty) ||
                  (pricingMethod == '買斷' &&
                      buyoutPriceController.text.isNotEmpty));

          if (hasStep3Data) {
            double step3LightCount =
                double.parse(step3LightCountController.text);

            // 計算每月總共可節省費用（使用 Step 1 的電費差額）
            double totalMonthlySavingAmount = oldMonthlyCost - newMonthlyCost;

            if (pricingMethod == '租賃' &&
                rentalPriceController.text.isNotEmpty) {
              double rentalPrice = double.parse(rentalPriceController.text);
              double monthlyRental = rentalPrice * step3LightCount;
              double totalMonthlySaving =
                  totalMonthlySavingAmount - monthlyRental;

              monthlyRentalController.text =
                  ElectricityCalculator.roundUpFirstDecimal(monthlyRental)
                      .toStringAsFixed(1);
              totalMonthlySavingController.text =
                  ElectricityCalculator.roundUpFirstDecimal(totalMonthlySaving)
                      .toStringAsFixed(1);

              // 建立租賃模式圖表（複雜模式）
              paybackSummaryChart = PaybackSummaryChart(
                isRental: true,
                monthlyRental: monthlyRental,
                monthlySaving: totalMonthlySaving,
              );
            } else if (pricingMethod == '買斷' &&
                buyoutPriceController.text.isNotEmpty) {
              double buyoutPrice = double.parse(buyoutPriceController.text);
              double buyoutTotal = buyoutPrice * step3LightCount;
              double paybackPeriod = buyoutTotal / totalMonthlySavingAmount;

              buyoutTotalController.text =
                  ElectricityCalculator.roundUpFirstDecimal(buyoutTotal)
                      .toStringAsFixed(1);
              paybackPeriodController.text =
                  ElectricityCalculator.roundUpFirstDecimal(paybackPeriod)
                      .toStringAsFixed(1);

              // 建立買斷模式圖表（複雜模式）
              paybackSummaryChart = PaybackSummaryChart(
                isRental: false,
                buyoutTotal: buyoutTotal,
                paybackMonths: paybackPeriod,
                monthlyElectricitySaving: totalMonthlySavingAmount,
              );
            }

            step3Calculated = true;
          } else {
            // 清空 Step3 結果
            monthlyRentalController.text = '';
            totalMonthlySavingController.text = '';
            buyoutTotalController.text = '';
            paybackPeriodController.text = '';
            paybackSummaryChart = null;
            step3Calculated = false;
          }
        } else {
          // 清空 Step2 結果
          basicElectricityController.text = '';
          excessDemandController.text = '';
          flowElectricityController.text = '';
          totalElectricityController.text = '';
          step2Calculated = false;
          pieChart = null;

          // 清空 Step3 結果
          monthlyRentalController.text = '';
          totalMonthlySavingController.text = '';
          buyoutTotalController.text = '';
          paybackPeriodController.text = '';
          step3Calculated = false;
        }
      } // End of USE_COMPLEX_ELECTRICITY_CALCULATION

      _hasCalculated = true;
    });

    // 顯示計算成功對話框
    Future.delayed(Duration(milliseconds: 100), () {
      _showSuccessDialog();
    });
  }

  // ==================== UI Build ====================

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('智慧AI燈管電力換算'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 步驟進度指示器（暫時移除 Step 2）
          StepIndicator(
            currentStep: _currentStep,
            stepTitles: ['AI燈管設定', /* '台電帳單', */ '攤提時間'],
            onStepTapped: (index) {
              setState(() {
                _currentStep = index; // 更新目前的步驟索引
              });
            },
          ),

          Expanded(
            child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
          ),

          // 底部導航按鈕
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  /// 桌面版佈局 (主欄 70% + 側欄 30%)
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 主內容區 (70%)
        Expanded(
          flex: 7,
          child: _buildStepContent(),
        ),

        // 側欄 (30%)
        Expanded(
          flex: 3,
          child: Container(
            margin: EdgeInsets.all(24),
            child: _buildSidebar(),
          ),
        ),
      ],
    );
  }

  /// 手機版佈局 (垂直堆疊：步驟內容 + 圖表)
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      controller: _mobileScrollController,
      physics: const ClampingScrollPhysics(), // 使用原生滾動物理效果
      child: Column(
        children: [
          // 步驟內容（直接顯示當前步驟，不使用 IndexedStack）
          RepaintBoundary(
            child: Container(
              padding: const EdgeInsets.all(12), // 從 16 縮小到 12
              child: _buildCurrentStepContent(),
            ),
          ),

          // 圖表區域（在內容下方）
          if (_hasCalculated)
            RepaintBoundary(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // 從 16/8 縮小到 12/6
                child: _buildSidebar(),
              ),
            ),
        ],
      ),
    );
  }

  /// 獲取當前步驟的內容組件（用於手機版）
  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Widget();
      case 1:
        return _buildStep3Widget();
      default:
        return Container();
    }
  }

  /// 建立 Step 1 組件
  Widget _buildStep1Widget() {
    return Step1AILights(
      isSummer: timeTypeSummer,
      onSeasonChanged: (value) => setState(() => timeTypeSummer = value ?? true),
      traditionalWattController: traditionalWattController,
      traditionalLightCountController: traditionalLightCountController,
      onTraditionalWattChanged: (_) => setState(() {}),
      onTraditionalCountChanged: (_) => setState(() {}),
      traditionalMonthlyConsumption:
          '${traditionalMonthlyConsumption?.toStringAsFixed(2) ?? '0.00'} 度',
      drivewayCountController: drivewayCountController,
      drivewayAllDay: drivewayAllDay,
      onDrivewayAllDayChanged: (value) =>
          setState(() => drivewayAllDay = value ?? false),
      drivewayDaytimeStart: drivewayDaytimeStart,
      drivewayDaytimeEnd: drivewayDaytimeEnd,
      onDrivewayDaytimeStartChanged: (TimeOfDay time) {
        setState(() {
          drivewayDaytimeStart = time;
        });
      },
      onDrivewayDaytimeEndChanged: (TimeOfDay time) {
        setState(() {
          drivewayDaytimeEnd = time;
        });
      },
      drivewayDayBrightnessBefore: drivewayDayBrightnessBefore,
      drivewayDayBrightnessAfter: drivewayDayBrightnessAfter,
      drivewayDaySensingTime: drivewayDaySensingTime,
      onDrivewayDayBrightnessBeforeChanged: (value) =>
          setState(() => drivewayDayBrightnessBefore = value ?? 30),
      onDrivewayDayBrightnessAfterChanged: (value) =>
          setState(() => drivewayDayBrightnessAfter = value ?? 100),
      onDrivewayDaySensingTimeChanged: (value) =>
          setState(() => drivewayDaySensingTime = value ?? 30),
      drivewayNighttimeStart: drivewayNighttimeStart,
      drivewayNighttimeEnd: drivewayNighttimeEnd,
      onDrivewayNighttimeStartChanged: (TimeOfDay time) {
        setState(() {
          drivewayNighttimeStart = time;
        });
      },
      onDrivewayNighttimeEndChanged: (TimeOfDay time) {
        setState(() {
          drivewayNighttimeEnd = time;
        });
      },
      drivewayNightBrightnessBefore: drivewayNightBrightnessBefore,
      drivewayNightBrightnessAfter: drivewayNightBrightnessAfter,
      drivewayNightSensingTime: drivewayNightSensingTime,
      onDrivewayNightBrightnessBeforeChanged: (value) =>
          setState(() => drivewayNightBrightnessBefore = value ?? 10),
      onDrivewayNightBrightnessAfterChanged: (value) =>
          setState(() => drivewayNightBrightnessAfter = value ?? 100),
      onDrivewayNightSensingTimeChanged: (value) =>
          setState(() => drivewayNightSensingTime = value ?? 30),
      onDrivewayCountChanged: (_) => setState(() {}),
      drivewayDaySensingCountController: drivewayDaySensingCountController,
      drivewayNightSensingCountController: drivewayNightSensingCountController,
      onDrivewayDaySensingCountChanged: (_) => setState(() {}),
      onDrivewayNightSensingCountChanged: (_) => setState(() {}),
      parkingCountController: parkingCountController,
      parkingAllDay: parkingAllDay,
      onParkingAllDayChanged: (value) =>
          setState(() => parkingAllDay = value ?? false),
      parkingDaytimeStart: parkingDaytimeStart,
      parkingDaytimeEnd: parkingDaytimeEnd,
      onParkingDaytimeStartChanged: (TimeOfDay time) {
        setState(() {
          parkingDaytimeStart = time;
        });
      },
      onParkingDaytimeEndChanged: (TimeOfDay time) {
        setState(() {
          parkingDaytimeEnd = time;
        });
      },
      parkingDayBrightnessBefore: parkingDayBrightnessBefore,
      parkingDayBrightnessAfter: parkingDayBrightnessAfter,
      parkingDaySensingTime: parkingDaySensingTime,
      onParkingDayBrightnessBeforeChanged: (value) =>
          setState(() => parkingDayBrightnessBefore = value ?? 30),
      onParkingDayBrightnessAfterChanged: (value) =>
          setState(() => parkingDayBrightnessAfter = value ?? 100),
      onParkingDaySensingTimeChanged: (value) =>
          setState(() => parkingDaySensingTime = value ?? 30),
      parkingNighttimeStart: parkingNighttimeStart,
      parkingNighttimeEnd: parkingNighttimeEnd,
      onParkingNighttimeStartChanged: (TimeOfDay time) {
        setState(() {
          parkingNighttimeStart = time;
        });
      },
      onParkingNighttimeEndChanged: (TimeOfDay time) {
        setState(() {
          parkingNighttimeEnd = time;
        });
      },
      parkingNightBrightnessBefore: parkingNightBrightnessBefore,
      parkingNightBrightnessAfter: parkingNightBrightnessAfter,
      parkingNightSensingTime: parkingNightSensingTime,
      onParkingNightBrightnessBeforeChanged: (value) =>
          setState(() => parkingNightBrightnessBefore = value ?? 10),
      onParkingNightBrightnessAfterChanged: (value) =>
          setState(() => parkingNightBrightnessAfter = value ?? 100),
      onParkingNightSensingTimeChanged: (value) =>
          setState(() => parkingNightSensingTime = value ?? 30),
      onParkingCountChanged: (_) => setState(() {}),
      parkingDaySensingCountController: parkingDaySensingCountController,
      parkingNightSensingCountController: parkingNightSensingCountController,
      onParkingDaySensingCountChanged: (_) => setState(() {}),
      onParkingNightSensingCountChanged: (_) => setState(() {}),
      onDrivewayDaytimeInfoTap: () => _showFieldInfo('車道燈-日間時段'),
      onDrivewayNighttimeInfoTap: () => _showFieldInfo('車道燈-夜間時段'),
      onParkingDaytimeInfoTap: () => _showFieldInfo('車位燈-日間時段'),
      onParkingNighttimeInfoTap: () => _showFieldInfo('車位燈-夜間時段'),
      drivewayDaytimeConsumption: drivewayDaytimeConsumption != null
          ? '${drivewayDaytimeConsumption!.toStringAsFixed(2)} 度'
          : null,
      drivewayNighttimeConsumption: drivewayNighttimeConsumption != null
          ? '${drivewayNighttimeConsumption!.toStringAsFixed(2)} 度'
          : null,
      drivewayDaytimeTitle: '車道燈日間每月耗電',
      drivewayNighttimeTitle: '車道燈夜間每月耗電',
      parkingDaytimeConsumption: parkingDaytimeConsumption != null
          ? '${parkingDaytimeConsumption!.toStringAsFixed(2)} 度'
          : null,
      parkingNighttimeConsumption: parkingNighttimeConsumption != null
          ? '${parkingNighttimeConsumption!.toStringAsFixed(2)} 度'
          : null,
      parkingDaytimeTitle: '車位燈日間每月耗電',
      parkingNighttimeTitle: '車位燈夜間每月耗電',
      onCalculate: _calculateStep1Only,
    );
  }

  /// 建立 Step 3 組件
  Widget _buildStep3Widget() {
    return Step3Payback(
      pricingMethod: pricingMethod,
      onPricingMethodChanged: (value) {
        setState(() {
          pricingMethod = value;
        });
      },
      rentalPriceController: rentalPriceController,
      onRentalPriceChanged: (_) => setState(() {}),
      buyoutPriceController: buyoutPriceController,
      onBuyoutPriceChanged: (_) => setState(() {}),
      step3LightCountController: step3LightCountController,
      onLightCountChanged: (_) => setState(() {}),
      monthlyRentalController: monthlyRentalController,
      totalMonthlySavingController: totalMonthlySavingController,
      buyoutTotalController: buyoutTotalController,
      paybackPeriodController: paybackPeriodController,
      onInfoTap: _showFieldInfo,
      onCalculateStep3: _calculateStep3,
      step1Calculated: step1Calculated,
      step2Calculated: step2Calculated,
      step3Calculated: step3Calculated,
      useSimplifiedMode: !USE_COMPLEX_ELECTRICITY_CALCULATION,
    );
  }

  /// 側邊欄內容（根據當前步驟顯示）
  Widget _buildSidebar() {
    if (!_hasCalculated) {
      // 未計算時顯示提示
      return Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              '請先完成 Step 1 計算',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // 根據當前步驟顯示對應圖表或結果
    switch (_currentStep) {
      case 0: // Step 1 - 顯示節電成果圖表
        if (powerSavingChart != null) {
          return SingleChildScrollView(
            child: powerSavingChart!,
          );
        } else {
          return _buildEmptySidebar('請完成 Step 1 計算以查看圖表');
        }
      case 1: // Step 2（攤提時間）- 顯示攤提摘要圖表
        if (paybackSummaryChart != null) {
          return SingleChildScrollView(
            child: paybackSummaryChart!,
          );
        } else {
          return _buildEmptySidebar('請完成攤提時間計算以查看圖表');
        }
      case 2: // Step 3（台電帳單）- 顯示圓餅圖（僅複雜計算模式，目前已隱藏）
        if (USE_COMPLEX_ELECTRICITY_CALCULATION &&
            step2Calculated &&
            pieChart != null) {
          // 複雜計算模式：顯示台電電費組成圓餅圖
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '電費組成分析',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                SizedBox(height: 16),
                pieChart!,
              ],
            ),
          );
        } else {
          // 簡化計算模式：提示用戶電費已在 Step 1 顯示
          return _buildEmptySidebar(USE_COMPLEX_ELECTRICITY_CALCULATION
              ? '請完成台電帳單計算以查看圖表'
              : '目前使用簡化計算模式\n電費資訊已顯示於 Step 1');
        }
      default:
        return _buildEmptySidebar('未知步驟');
    }
  }

  /// 空側邊欄提示
  Widget _buildEmptySidebar(String message) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 48, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 步驟內容 (使用 IndexedStack 瞬間切換)
  Widget _buildStepContent() {
    return IndexedStack(
      index: _currentStep,
      children: [
        // Step 1: AI 燈管設定
        Step1AILights(
          isSummer: timeTypeSummer,
          onSeasonChanged: (value) => setState(() => timeTypeSummer = value ?? true),
          traditionalWattController: traditionalWattController,
          traditionalLightCountController: traditionalLightCountController,
          onTraditionalWattChanged: (_) => setState(() {}),
          onTraditionalCountChanged: (_) => setState(() {}),
          traditionalMonthlyConsumption:
              '${traditionalMonthlyConsumption?.toStringAsFixed(2) ?? '0.00'} 度',
          drivewayCountController: drivewayCountController,
          drivewayAllDay: drivewayAllDay,
          onDrivewayAllDayChanged: (value) =>
              setState(() => drivewayAllDay = value ?? false),
          drivewayDaytimeStart: drivewayDaytimeStart,
          drivewayDaytimeEnd: drivewayDaytimeEnd,
          onDrivewayDaytimeStartChanged: (TimeOfDay time) {
            setState(() {
              drivewayDaytimeStart = time;
            });
          },
          onDrivewayDaytimeEndChanged: (TimeOfDay time) {
            setState(() {
              drivewayDaytimeEnd = time;
            });
          },
          drivewayDayBrightnessBefore: drivewayDayBrightnessBefore,
          drivewayDayBrightnessAfter: drivewayDayBrightnessAfter,
          drivewayDaySensingTime: drivewayDaySensingTime,
          onDrivewayDayBrightnessBeforeChanged: (value) =>
              setState(() => drivewayDayBrightnessBefore = value ?? 30),
          onDrivewayDayBrightnessAfterChanged: (value) =>
              setState(() => drivewayDayBrightnessAfter = value ?? 100),
          onDrivewayDaySensingTimeChanged: (value) =>
              setState(() => drivewayDaySensingTime = value ?? 30),
          drivewayNighttimeStart: drivewayNighttimeStart,
          drivewayNighttimeEnd: drivewayNighttimeEnd,
          onDrivewayNighttimeStartChanged: (TimeOfDay time) {
            setState(() {
              drivewayNighttimeStart = time;
            });
          },
          onDrivewayNighttimeEndChanged: (TimeOfDay time) {
            setState(() {
              drivewayNighttimeEnd = time;
            });
          },
          drivewayNightBrightnessBefore: drivewayNightBrightnessBefore,
          drivewayNightBrightnessAfter: drivewayNightBrightnessAfter,
          drivewayNightSensingTime: drivewayNightSensingTime,
          onDrivewayNightBrightnessBeforeChanged: (value) =>
              setState(() => drivewayNightBrightnessBefore = value ?? 10),
          onDrivewayNightBrightnessAfterChanged: (value) =>
              setState(() => drivewayNightBrightnessAfter = value ?? 100),
          onDrivewayNightSensingTimeChanged: (value) =>
              setState(() => drivewayNightSensingTime = value ?? 30),
          onDrivewayCountChanged: (_) => setState(() {}),
          drivewayDaySensingCountController: drivewayDaySensingCountController,
          drivewayNightSensingCountController: drivewayNightSensingCountController,
          onDrivewayDaySensingCountChanged: (_) => setState(() {}),
          onDrivewayNightSensingCountChanged: (_) => setState(() {}),
          parkingCountController: parkingCountController,
          parkingAllDay: parkingAllDay,
          onParkingAllDayChanged: (value) =>
              setState(() => parkingAllDay = value ?? false),
          parkingDaytimeStart: parkingDaytimeStart,
          parkingDaytimeEnd: parkingDaytimeEnd,
          onParkingDaytimeStartChanged: (TimeOfDay time) {
            setState(() {
              parkingDaytimeStart = time;
            });
          },
          onParkingDaytimeEndChanged: (TimeOfDay time) {
            setState(() {
              parkingDaytimeEnd = time;
            });
          },
          parkingDayBrightnessBefore: parkingDayBrightnessBefore,
          parkingDayBrightnessAfter: parkingDayBrightnessAfter,
          parkingDaySensingTime: parkingDaySensingTime,
          onParkingDayBrightnessBeforeChanged: (value) =>
              setState(() => parkingDayBrightnessBefore = value ?? 30),
          onParkingDayBrightnessAfterChanged: (value) =>
              setState(() => parkingDayBrightnessAfter = value ?? 100),
          onParkingDaySensingTimeChanged: (value) =>
              setState(() => parkingDaySensingTime = value ?? 30),
          parkingNighttimeStart: parkingNighttimeStart,
          parkingNighttimeEnd: parkingNighttimeEnd,
          onParkingNighttimeStartChanged: (TimeOfDay time) {
            setState(() {
              parkingNighttimeStart = time;
            });
          },
          onParkingNighttimeEndChanged: (TimeOfDay time) {
            setState(() {
              parkingNighttimeEnd = time;
            });
          },
          parkingNightBrightnessBefore: parkingNightBrightnessBefore,
          parkingNightBrightnessAfter: parkingNightBrightnessAfter,
          parkingNightSensingTime: parkingNightSensingTime,
          onParkingNightBrightnessBeforeChanged: (value) =>
              setState(() => parkingNightBrightnessBefore = value ?? 10),
          onParkingNightBrightnessAfterChanged: (value) =>
              setState(() => parkingNightBrightnessAfter = value ?? 100),
          onParkingNightSensingTimeChanged: (value) =>
              setState(() => parkingNightSensingTime = value ?? 30),
          onParkingCountChanged: (_) => setState(() {}),
          parkingDaySensingCountController: parkingDaySensingCountController,
          parkingNightSensingCountController: parkingNightSensingCountController,
          onParkingDaySensingCountChanged: (_) => setState(() {}),
          onParkingNightSensingCountChanged: (_) => setState(() {}),
          onDrivewayDaytimeInfoTap: () => _showFieldInfo('車道燈-日間時段'),
          onDrivewayNighttimeInfoTap: () => _showFieldInfo('車道燈-夜間時段'),
          onParkingDaytimeInfoTap: () => _showFieldInfo('車位燈-日間時段'),
          onParkingNighttimeInfoTap: () => _showFieldInfo('車位燈-夜間時段'),
          drivewayDaytimeConsumption: drivewayDaytimeConsumption != null
              ? '${drivewayDaytimeConsumption!.toStringAsFixed(2)} 度'
              : null,
          drivewayNighttimeConsumption: drivewayNighttimeConsumption != null
              ? '${drivewayNighttimeConsumption!.toStringAsFixed(2)} 度'
              : null,
          drivewayDaytimeTitle: '車道燈日間每月耗電',
          drivewayNighttimeTitle: '車道燈夜間每月耗電',
          parkingDaytimeConsumption: parkingDaytimeConsumption != null
              ? '${parkingDaytimeConsumption!.toStringAsFixed(2)} 度'
              : null,
          parkingNighttimeConsumption: parkingNighttimeConsumption != null
              ? '${parkingNighttimeConsumption!.toStringAsFixed(2)} 度'
              : null,
          parkingDaytimeTitle: '車位燈日間每月耗電',
          parkingNighttimeTitle: '車位燈夜間每月耗電',
          onCalculate: _calculateStep1Only,
        ),

        // Step 2（攤提時間）- 原 Step 3
        Step3Payback(
          pricingMethod: pricingMethod,
          onPricingMethodChanged: (value) {
            setState(() {
              pricingMethod = value;
            });
          },
          rentalPriceController: rentalPriceController,
          onRentalPriceChanged: (_) => setState(() {}),
          buyoutPriceController: buyoutPriceController,
          onBuyoutPriceChanged: (_) => setState(() {}),
          step3LightCountController: step3LightCountController,
          onLightCountChanged: (_) => setState(() {}),
          monthlyRentalController: monthlyRentalController,
          totalMonthlySavingController: totalMonthlySavingController,
          buyoutTotalController: buyoutTotalController,
          paybackPeriodController: paybackPeriodController,
          onInfoTap: _showFieldInfo,
          onCalculateStep3: _calculateStep3,
          step1Calculated: step1Calculated,
          step2Calculated: step2Calculated,
          step3Calculated: step3Calculated,
          useSimplifiedMode: !USE_COMPLEX_ELECTRICITY_CALCULATION,
        ),

        /* Step 3（台電帳單）- 原 Step 2（暫時隱藏）
        Step2BillInfo(
          timeTypeSummer: timeTypeSummer,
          timeTypeNonSummer: timeTypeNonSummer,
          onSummerChanged: (value) {
            setState(() {
              timeTypeSummer = value ?? false;
              if (value == true) timeTypeNonSummer = false;
            });
            _calculateResults();
          },
          onNonSummerChanged: (value) {
            setState(() {
              timeTypeNonSummer = value ?? false;
              if (value == true) timeTypeSummer = false;
            });
            _calculateResults();
          },
          contractCapacityController: contractCapacityController,
          maxDemandController: maxDemandController,
          billingUnitsController: billingUnitsController,
          onContractCapacityChanged: (_) => setState(() {}),
          onMaxDemandChanged: (_) => setState(() {}),
          onBillingUnitsChanged: (_) => setState(() {}),
          basicElectricityController: basicElectricityController,
          excessDemandController: excessDemandController,
          flowElectricityController: flowElectricityController,
          totalElectricityController: totalElectricityController,
          onInfoTap: _showFieldInfo,
          onCalculateStep2: _calculateStep2,
          step2Calculated: step2Calculated,
          step3Calculated: step3Calculated,
          totalMonthlySavingController: totalMonthlySavingController,
          pieChart: pieChart,
        ),
        */
      ],
    );
  }

  /// 底部導航按鈕
  Widget _buildNavigationButtons() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // 手機版大幅縮小 padding
    final containerPadding = isMobile ? 6.0 : 24.0;
    final buttonHorizontalPadding = isMobile ? 12.0 : 24.0;
    final buttonVerticalPadding = isMobile ? 8.0 : 16.0;

    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 上一步按鈕
          if (_currentStep > 0)
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _currentStep--;
                });
                // 滾動到頂部（手機版）
                _scrollToTop();
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('上一步'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black87,
                padding: EdgeInsets.symmetric(
                    horizontal: buttonHorizontalPadding,
                    vertical: buttonVerticalPadding),
              ),
            ),

          const Spacer(),

          // 下一步按鈕（目前只有 2 步：AI燈管設定 → 攤提時間）
          if (_currentStep < 1)
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _currentStep++;
                });
                // 滾動到頂部（手機版）
                _scrollToTop();
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('下一步'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                    horizontal: buttonHorizontalPadding,
                    vertical: buttonVerticalPadding),
              ),
            ),

          // 完成按鈕 (最後一步)
          if (_currentStep == 1)
            ElevatedButton.icon(
              onPressed: () {
                // 只驗證 Step 3，然後計算所有步驟
                _validateAndCalculateAll();
              },
              icon: const Icon(Icons.check),
              label: const Text('完成'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                    horizontal: buttonHorizontalPadding,
                    vertical: buttonVerticalPadding),
              ),
            ),
        ],
      ),
    );
  }
}
