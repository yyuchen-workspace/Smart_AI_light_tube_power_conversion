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
import 'widgets/result_sidebar.dart';

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
      TextEditingController(text: '18');
  final TextEditingController traditionalLightCountController =
      TextEditingController(text: '0');

  // 車道燈策略
  final TextEditingController drivewayCountController =
      TextEditingController(text: '0');
  bool drivewayAllDay = false;
  TimeOfDay drivewayDaytimeStart = TimeOfDay(hour: 6, minute: 0);
  TimeOfDay drivewayDaytimeEnd = TimeOfDay(hour: 18, minute: 0);
  int drivewayDayBrightnessBefore = 30;
  int drivewayDayBrightnessAfter = 100;
  int drivewayDaySensingTime = 30;
  TimeOfDay drivewayNighttimeStart = TimeOfDay(hour: 18, minute: 0);
  TimeOfDay drivewayNighttimeEnd = TimeOfDay(hour: 6, minute: 0);
  int drivewayNightBrightnessBefore = 10;
  int drivewayNightBrightnessAfter = 100;
  int drivewayNightSensingTime = 30;

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

  // 計算結果
  double? aiMonthlyConsumption;
  double? traditionalMonthlyConsumption;
  double? monthlySavings;
  double? savingsRate;

  @override
  void dispose() {
    traditionalWattController.dispose();
    traditionalLightCountController.dispose();
    drivewayCountController.dispose();
    parkingCountController.dispose();
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
          endHour:
              drivewayDaytimeEnd.hour + drivewayDaytimeEnd.minute / 60.0,
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

      aiMonthlyConsumption =
          LightingCalculator.calculateMonthlyConsumption(
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
      monthlySavings =
          traditionalMonthlyConsumption! - aiMonthlyConsumption!;
      savingsRate =
          (monthlySavings! / traditionalMonthlyConsumption!) * 100;

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
            child: isDesktop
                ? _buildDesktopLayout()
                : _buildMobileLayout(),
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
            child: ResultSidebar(
              aiMonthlyConsumption: aiMonthlyConsumption,
              traditionalMonthlyConsumption: traditionalMonthlyConsumption,
              monthlySavings: monthlySavings,
              savingsRate: savingsRate,
              hasCalculated: _hasCalculated,
            ),
          ),
        ),
      ],
    );
  }

  /// 手機版佈局 (垂直堆疊)
  Widget _buildMobileLayout() {
    return _buildStepContent();
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
          onDrivewayDaytimeStartTap: () => _selectTime(
              context, drivewayDaytimeStart,
              (time) => drivewayDaytimeStart = time),
          onDrivewayDaytimeEndTap: () => _selectTime(
              context, drivewayDaytimeEnd,
              (time) => drivewayDaytimeEnd = time),
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
          onDrivewayNighttimeStartTap: () => _selectTime(
              context, drivewayNighttimeStart,
              (time) => drivewayNighttimeStart = time),
          onDrivewayNighttimeEndTap: () => _selectTime(
              context, drivewayNighttimeEnd,
              (time) => drivewayNighttimeEnd = time),
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
          onParkingDaytimeStartTap: () => _selectTime(
              context, parkingDaytimeStart,
              (time) => parkingDaytimeStart = time),
          onParkingDaytimeEndTap: () => _selectTime(
              context, parkingDaytimeEnd,
              (time) => parkingDaytimeEnd = time),
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
          onParkingNighttimeStartTap: () => _selectTime(
              context, parkingNighttimeStart,
              (time) => parkingNighttimeStart = time),
          onParkingNighttimeEndTap: () => _selectTime(
              context, parkingNighttimeEnd,
              (time) => parkingNighttimeEnd = time),
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
        ),

        // Step 2: 台電帳單 (暫時使用佔位符)
        Step2BillInfo(
          content: Center(
            child: Text('台電帳單內容（待整合）'),
          ),
        ),

        // Step 3: 攤提時間 (暫時使用佔位符)
        Step3Payback(
          content: Center(
            child: Text('攤提時間內容（待整合）'),
          ),
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
