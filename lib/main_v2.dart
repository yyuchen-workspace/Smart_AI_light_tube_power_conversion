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
import 'pages/step2_bill_info.dart';
import 'pages/step3_payback.dart';

// UI 元件
import 'widgets/step_indicator.dart';
import 'widgets/charts/electricity_cost_pie_chart.dart';
import 'widgets/charts/payback_trend_chart.dart';
import 'widgets/charts/power_saving_chart.dart';

// 計算工具
import 'utils/lighting_calculator.dart';
import 'utils/electricity_calculator.dart';
import 'models/lighting_strategy.dart';

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
  // 當前步驟 (0: Step1, 1: Step2, 2: Step3)
  int _currentStep = 0;

  // 是否已計算
  bool _hasCalculated = false;

  // ==================== State Variables ====================

  // 傳統燈管
  final TextEditingController traditionalWattController =
      TextEditingController(text: '0');
  final TextEditingController traditionalLightCountController =
      TextEditingController(text: '0');

  // 車道燈策略
  final TextEditingController drivewayCountController =
      TextEditingController(text: '0');
  bool drivewayAllDay = false;
  TimeOfDay drivewayDaytimeStart = TimeOfDay(hour: 6, minute: 0);
  TimeOfDay drivewayDaytimeEnd = TimeOfDay(hour: 0, minute: 0);
  int drivewayDayBrightnessBefore = 0;
  int drivewayDayBrightnessAfter = 0;
  int drivewayDaySensingTime = 10;
  TimeOfDay drivewayNighttimeStart = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay drivewayNighttimeEnd = TimeOfDay(hour: 6, minute: 0);
  int drivewayNightBrightnessBefore = 0;
  int drivewayNightBrightnessAfter = 0;
  int drivewayNightSensingTime = 10;

  // 車位燈策略
  final TextEditingController parkingCountController =
      TextEditingController(text: '0');
  bool parkingAllDay = false;
  TimeOfDay parkingDaytimeStart = TimeOfDay(hour: 6, minute: 0);
  TimeOfDay parkingDaytimeEnd = TimeOfDay(hour: 18, minute: 0);
  int parkingDayBrightnessBefore = 30;
  int parkingDayBrightnessAfter = 100;
  int parkingDaySensingTime = 30;
  TimeOfDay parkingNighttimeStart = TimeOfDay(hour: 18, minute: 0);
  TimeOfDay parkingNighttimeEnd = TimeOfDay(hour: 6, minute: 0);
  int parkingNightBrightnessBefore = 10;
  int parkingNightBrightnessAfter = 100;
  int parkingNightSensingTime = 30;

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
  bool step2Calculated = false;

  // Step 3: 攤提時間試算
  String? pricingMethod = '租賃'; // 預設租賃
  final TextEditingController rentalPriceController = TextEditingController();
  final TextEditingController buyoutPriceController = TextEditingController();
  final TextEditingController step3LightCountController =
      TextEditingController();
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

  // 圖表組件
  Widget? pieChart;
  Widget? trendChart;
  Widget? powerSavingChart;

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
    super.dispose();
  }

  // ==================== Methods ====================

  /// 時間選擇器
  Future<void> _selectTime(BuildContext context, TimeOfDay initialTime,
      Function(TimeOfDay) onTimeSelected) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        onTimeSelected(picked);
      });
    }
  }

  /// 資訊按鈕處理（暫時顯示簡單對話框）
  void _showFieldInfo(String fieldName) {
    // TODO: 整合完整的資訊顯示邏輯
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(fieldName),
        content: Text('$fieldName 的說明資訊'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('確定'),
          ),
        ],
      ),
    );
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

      // 計算AI燈管消耗
      double drivewayDailyWattage =
          LightingCalculator.calculateDrivewayWattage(drivewayStrategy);
      double parkingDailyWattage =
          LightingCalculator.calculateParkingWattage(parkingStrategy);

      aiMonthlyConsumption = LightingCalculator.calculateMonthlyConsumption(
              drivewayDailyWattage, drivewayCount) +
          LightingCalculator.calculateMonthlyConsumption(
              parkingDailyWattage, parkingCount);

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

      // 建立 Step 1 節電成果圖表
      powerSavingChart = PowerSavingChart(
        aiMonthlyConsumption: aiMonthlyConsumption!,
        monthlySavings: monthlySavings!,
        savingsRate: savingsRate!,
      );

      // Step 2: 台電帳單計算（條件性執行）
      bool hasStep2Data = contractCapacityController.text.isNotEmpty &&
          maxDemandController.text.isNotEmpty &&
          billingUnitsController.text.isNotEmpty;

      if (hasStep2Data) {
        double contractCapacity = double.parse(contractCapacityController.text);
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
        double flowElectricity = ElectricityCalculator.calculateFlowElectricity(
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

        // 建立圓餅圖
        pieChart = ElectricityCostPieChart(
          basicElectricity: basicElectricity,
          flowElectricity: flowElectricity,
          excessDemand: excessDemand > 0 ? excessDemand : 0,
        );

        // Step 3: 攤提時間計算（條件性執行，需要 Step2 數據）
        bool hasStep3Data = step3LightCountController.text.isNotEmpty &&
            ((pricingMethod == '租賃' && rentalPriceController.text.isNotEmpty) ||
                (pricingMethod == '買斷' &&
                    buyoutPriceController.text.isNotEmpty));

        if (hasStep3Data) {
          double step3LightCount = double.parse(step3LightCountController.text);

          // 計算總共節省費用（兩種模式都需要）
          double totalSaving = ElectricityCalculator.calculateSaving(
            savingUnits: savingUnits,
            isSummer: timeTypeSummer,
          );

          if (pricingMethod == '租賃' && rentalPriceController.text.isNotEmpty) {
            double rentalPrice = double.parse(rentalPriceController.text);
            double monthlyRental = rentalPrice * step3LightCount;
            double totalMonthlySaving = totalSaving - monthlyRental;

            monthlyRentalController.text =
                ElectricityCalculator.roundUpFirstDecimal(monthlyRental)
                    .toStringAsFixed(1);
            totalMonthlySavingController.text =
                ElectricityCalculator.roundUpFirstDecimal(totalMonthlySaving)
                    .toStringAsFixed(1);

            // 建立趨勢圖（租賃模式）
            trendChart = PaybackTrendChart(
              monthlySaving: totalSaving,
              buyoutTotal: null,
            );
          } else if (pricingMethod == '買斷' &&
              buyoutPriceController.text.isNotEmpty) {
            double buyoutPrice = double.parse(buyoutPriceController.text);
            double buyoutTotal = buyoutPrice * step3LightCount;
            double paybackPeriod = buyoutTotal / totalSaving;

            buyoutTotalController.text =
                ElectricityCalculator.roundUpFirstDecimal(buyoutTotal)
                    .toStringAsFixed(1);
            paybackPeriodController.text =
                ElectricityCalculator.roundUpFirstDecimal(paybackPeriod)
                    .toStringAsFixed(1);

            // 建立趨勢圖（買斷模式）
            trendChart = PaybackTrendChart(
              monthlySaving: totalSaving,
              buyoutTotal: buyoutTotal,
            );
          }

          step3Calculated = true;
        } else {
          // 清空 Step3 結果
          monthlyRentalController.text = '';
          totalMonthlySavingController.text = '';
          buyoutTotalController.text = '';
          paybackPeriodController.text = '';
          step3Calculated = false;
          trendChart = null;
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
        trendChart = null;
      }

      _hasCalculated = true;
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
          // 步驟進度指示器
          StepIndicator(
            currentStep: _currentStep,
            stepTitles: ['AI燈管設定', '台電帳單', '攤提時間'],
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

  /// 手機版佈局 (垂直堆疊)
  Widget _buildMobileLayout() {
    return _buildStepContent();
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '節電成果分析',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
                SizedBox(height: 16),
                powerSavingChart!,
              ],
            ),
          );
        } else {
          return _buildEmptySidebar('請完成 Step 1 計算以查看圖表');
        }
      case 1: // Step 2 - 顯示圓餅圖
        if (step2Calculated && pieChart != null) {
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
          return _buildEmptySidebar('請完成 Step 2 計算以查看圖表');
        }
      case 2: // Step 3 - 顯示趨勢圖
        if (step3Calculated && step2Calculated && trendChart != null) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '節電回本趨勢',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                SizedBox(height: 16),
                trendChart!,
              ],
            ),
          );
        } else {
          return _buildEmptySidebar('請完成 Step 2 和 Step 3 計算以查看圖表');
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
          onDrivewayDaytimeStartTap: () => _selectTime(context,
              drivewayDaytimeStart, (time) => drivewayDaytimeStart = time),
          onDrivewayDaytimeEndTap: () => _selectTime(
              context, drivewayDaytimeEnd, (time) => drivewayDaytimeEnd = time),
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
          onDrivewayNighttimeStartTap: () => _selectTime(context,
              drivewayNighttimeStart, (time) => drivewayNighttimeStart = time),
          onDrivewayNighttimeEndTap: () => _selectTime(context,
              drivewayNighttimeEnd, (time) => drivewayNighttimeEnd = time),
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
          parkingCountController: parkingCountController,
          parkingAllDay: parkingAllDay,
          onParkingAllDayChanged: (value) =>
              setState(() => parkingAllDay = value ?? false),
          parkingDaytimeStart: parkingDaytimeStart,
          parkingDaytimeEnd: parkingDaytimeEnd,
          onParkingDaytimeStartTap: () => _selectTime(context,
              parkingDaytimeStart, (time) => parkingDaytimeStart = time),
          onParkingDaytimeEndTap: () => _selectTime(
              context, parkingDaytimeEnd, (time) => parkingDaytimeEnd = time),
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
          onParkingNighttimeStartTap: () => _selectTime(context,
              parkingNighttimeStart, (time) => parkingNighttimeStart = time),
          onParkingNighttimeEndTap: () => _selectTime(context,
              parkingNighttimeEnd, (time) => parkingNighttimeEnd = time),
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
          onCalculate: _calculateResults,
          aiMonthlyConsumption: aiMonthlyConsumption,
          monthlySavings: monthlySavings,
          savingsRate: savingsRate,
          hasCalculated: _hasCalculated,
        ),

        // Step 2: 台電帳單
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
          onContractCapacityChanged: (_) => _calculateResults(),
          onMaxDemandChanged: (_) => _calculateResults(),
          onBillingUnitsChanged: (_) => _calculateResults(),
          basicElectricityController: basicElectricityController,
          excessDemandController: excessDemandController,
          flowElectricityController: flowElectricityController,
          totalElectricityController: totalElectricityController,
          onInfoTap: _showFieldInfo,
          step2Calculated: step2Calculated,
          step3Calculated: step3Calculated,
          totalMonthlySavingController: totalMonthlySavingController,
          pieChart: pieChart,
        ),

        // Step 3: 攤提時間
        Step3Payback(
          pricingMethod: pricingMethod,
          onPricingMethodChanged: (value) {
            setState(() {
              pricingMethod = value;
            });
            _calculateResults();
          },
          rentalPriceController: rentalPriceController,
          onRentalPriceChanged: (_) => _calculateResults(),
          buyoutPriceController: buyoutPriceController,
          onBuyoutPriceChanged: (_) => _calculateResults(),
          step3LightCountController: step3LightCountController,
          onLightCountChanged: (_) => _calculateResults(),
          monthlyRentalController: monthlyRentalController,
          totalMonthlySavingController: totalMonthlySavingController,
          buyoutTotalController: buyoutTotalController,
          paybackPeriodController: paybackPeriodController,
          onInfoTap: _showFieldInfo,
          step2Calculated: step2Calculated,
          step3Calculated: step3Calculated,
          trendChart: trendChart,
        ),
      ],
    );
  }

  /// 底部導航按鈕
  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
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
              },
              icon: Icon(Icons.arrow_back),
              label: Text('上一步'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black87,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),

          Spacer(),

          // 下一步按鈕
          if (_currentStep < 2)
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _currentStep++;
                });
              },
              icon: Icon(Icons.arrow_forward),
              label: Text('下一步'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),

          // 完成按鈕 (最後一步)
          if (_currentStep == 2)
            ElevatedButton.icon(
              onPressed: () {
                // TODO: 處理完成邏輯
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('計算完成！')),
                );
              },
              icon: Icon(Icons.check),
              label: Text('完成'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
        ],
      ),
    );
  }
}
