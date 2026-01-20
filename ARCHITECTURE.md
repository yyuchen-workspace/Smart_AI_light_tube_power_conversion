# Smart AI Light Tube Power Conversion - 架構文檔

## 專案概述
智能燈管節電計算應用程式，提供三步驟的電費試算與節電回本分析。

---

## 📁 專案結構總覽

```
lib/
├── main.dart                          # 應用程式入口（舊版）
├── main_v2.dart                       # 主控制器（新版，當前使用）
├── constants/                         # 常數定義
│   ├── brightness_wattage_map.dart   # 亮度-瓦數對照表
│   └── electricity_pricing.dart      # 電價常數
├── models/                            # 資料模型
│   └── lighting_strategy.dart        # 亮燈策略模型
├── pages/                             # 頁面組件
│   ├── step1_ai_lights.dart          # 步驟一：AI智能燈管頁面
│   ├── step2_bill_info.dart          # 步驟二：台電帳單資訊頁面
│   └── step3_payback.dart            # 步驟三：節電回本頁面
├── utils/                             # 工具函數
│   ├── electricity_calculator.dart   # 電費計算邏輯
│   └── lighting_calculator.dart      # 燈管耗電計算邏輯
└── widgets/                           # UI組件
    ├── bill_info_form.dart           # 台電帳單表單
    ├── payback_form.dart             # 節電回本表單
    ├── result_sidebar.dart           # 結果側邊欄
    ├── input_components/             # 輸入組件
    │   ├── lighting_input_field.dart # 燈管輸入欄位
    │   └── time_slot_card.dart       # 時段設定卡片
    └── charts/                        # 圖表組件
        ├── electricity_cost_pie_chart.dart    # 電費組成圓餅圖
        └── payback_trend_chart.dart          # 回本趨勢折線圖

test/
└── utils/
    ├── lighting_calculator_test.dart        # 燈管計算測試
    └── lighting_calculator_smart_test.dart  # 智能診斷測試
```

---

## 🎯 核心檔案詳細說明

### 1. **lib/main_v2.dart** (主控制器)

**主要職責**：
- 應用程式狀態管理
- 計算流程協調
- UI佈局控制（桌面/手機響應式）

**狀態變數**：
```dart
// 導航狀態
int _currentStep = 0;                    // 當前步驟 (0=Step1, 1=Step2, 2=Step3)

// 計算狀態標記
bool _hasCalculated = false;             // Step 1 是否已計算
bool _step2Calculated = false;           // Step 2 是否已計算
bool _step3Calculated = false;           // Step 3 是否已計算

// Step 1 輸入控制器
TextEditingController _drivewayCountController;         // 車道燈數量
TextEditingController _parkingCountController;          // 車位燈數量
TextEditingController _oldLightWattageController;       // 舊燈管瓦數
TextEditingController _dailyUsageHoursController;       // 每日使用時數

// Step 1 結果控制器
TextEditingController _aiMonthlyConsumptionController;  // AI燈每月耗電
TextEditingController _oldMonthlyConsumptionController; // 舊燈每月耗電
TextEditingController _monthlySavingsController;        // 每月節電量
TextEditingController _savingsRateController;           // 節電率

// Step 2 輸入控制器
TextEditingController _contractCapacityController;      // 契約容量
TextEditingController _maxDemandController;             // 最高需量
TextEditingController _billingUnitsController;          // 計費度數

// Step 2 結果控制器
TextEditingController _basicElectricityController;      // 基本電價
TextEditingController _excessDemandController;          // 超約費用
TextEditingController _flowElectricityController;       // 流動電價
TextEditingController _totalElectricityController;      // 總電價

// Step 3 輸入控制器
TextEditingController _rentalPriceController;           // 租賃單價
TextEditingController _buyoutPriceController;           // 買斷單價
TextEditingController _step3LightCountController;       // 燈管數量

// Step 3 結果控制器
TextEditingController _monthlyRentalController;         // 每月租金
TextEditingController _totalMonthlySavingController;    // 每月總節省
TextEditingController _buyoutTotalController;           // 買斷總價
TextEditingController _paybackPeriodController;         // 回本期間

// 圖表組件
Widget? pieChart;                        // 圓餅圖
Widget? trendChart;                      // 趨勢圖

// 亮燈策略
LightingStrategy _drivewayStrategy;      // 車道燈策略
LightingStrategy _parkingStrategy;       // 車位燈策略

// UI狀態
bool _timeTypeSummer = true;             // 夏季
bool _timeTypeNonSummer = false;         // 非夏季
String? _pricingMethod;                  // 計價方式 ('租賃'/'買斷')
```

**關鍵方法**：

#### `void _calculateResults()`
- **位置**：Lines 250-430
- **觸發時機**：任一步驟的輸入改變時
- **功能**：
  1. **Step 1 計算**（Lines 252-340）：
     - 驗證輸入：車道燈數、車位燈數、舊燈管瓦數、使用時數
     - 計算 AI 燈管每日耗電：
       ```dart
       drivewayDaily = LightingCalculator.calculateDrivewayWattage(_drivewayStrategy)
       parkingDaily = LightingCalculator.calculateParkingWattage(_parkingStrategy)
       aiMonthlyConsumption = (drivewayDaily + parkingDaily) * 30 / 1000
       ```
     - 計算舊燈管每月耗電：
       ```dart
       oldMonthlyConsumption = totalLights * oldWattage * dailyHours * 30 / 1000
       ```
     - 計算節電量與節電率
     - 設定 `_hasCalculated = true`

  2. **Step 2 計算**（Lines 342-385）：
     - 驗證輸入：契約容量、最高需量、計費度數
     - 計算基本電價：`ElectricityCalculator.calculateBasicElectricity()`
     - 計算超約費用：`ElectricityCalculator.calculateExcessDemand()`
     - 計算流動電價：`ElectricityCalculator.calculateFlowElectricity()`
     - 建立圓餅圖：`ElectricityCostPieChart()`
     - 設定 `_step2Calculated = true`

  3. **Step 3 計算**（Lines 387-428）：
     - 驗證 Step 1 已完成
     - 驗證燈管數量輸入
     - **租賃模式**：
       ```dart
       monthlyRental = lightCount * rentalPrice
       totalMonthlySaving = monthlySavings - monthlyRental
       ```
     - **買斷模式**：
       ```dart
       buyoutTotal = lightCount * buyoutPrice
       paybackPeriod = buyoutTotal / monthlySavings
       ```
     - 建立折線圖：`PaybackTrendChart()`
     - 設定 `_step3Calculated = true`

#### `Widget _buildSidebar()`
- **位置**：Lines 498-603
- **功能**：根據當前步驟顯示不同內容
  - Step 1: `ResultSidebar` (結果摘要)
  - Step 2: `ElectricityCostPieChart` (電費組成圖)
  - Step 3: `PaybackTrendChart` (回本趨勢圖)

#### `Widget _buildDesktopLayout()`
- **位置**：Lines 605-645
- **功能**：桌面版雙欄佈局（主內容 + 側邊欄）

#### `Widget _buildMobileLayout()`
- **位置**：Lines 647-680
- **功能**：手機版單欄佈局

---

### 2. **lib/pages/step1_ai_lights.dart** (步驟一頁面)

**主要職責**：
- 顯示 AI 智能燈管輸入表單
- 顯示計算結果卡片

**接收參數**：
```dart
// 車道燈策略
LightingStrategy drivewayStrategy;
Function(LightingStrategy) onDrivewayStrategyChanged;

// 車位燈策略
LightingStrategy parkingStrategy;
Function(LightingStrategy) onParkingStrategyChanged;

// 輸入控制器
TextEditingController drivewayCountController;
TextEditingController parkingCountController;
TextEditingController oldLightWattageController;
TextEditingController dailyUsageHoursController;

// 輸入變更回調
ValueChanged<String>? onDrivewayCountChanged;
ValueChanged<String>? onParkingCountChanged;
ValueChanged<String>? onOldWattageChanged;
ValueChanged<String>? onDailyHoursChanged;

// 結果顯示（可選）
double? aiMonthlyConsumption;
double? monthlySavings;
double? savingsRate;
bool hasCalculated;
```

**UI 結構**：
1. **頁面標題**（Lines 76-91）
2. **舊燈管資訊輸入**（Lines 93-137）
3. **車道燈設定**（Lines 139-194）
4. **車位燈設定**（Lines 196-251）
5. **計算按鈕**（Lines 253-335）
6. **計算結果卡片**（Lines 337-487）：
   - AI 燈管每月耗電（綠色）
   - 每月節電量（藍色）
   - 節電率（橘色）

**關鍵子組件**：
- `LightingInputField`：輸入欄位組件
- `TimeSlotCard`：時段設定卡片

---

### 3. **lib/pages/step2_bill_info.dart** (步驟二頁面)

**主要職責**：
- 包裝 `BillInfoForm` 組件
- 傳遞參數給表單

**接收參數**：
```dart
// 季節選擇
bool timeTypeSummer;
bool timeTypeNonSummer;
ValueChanged<bool?> onSummerChanged;
ValueChanged<bool?> onNonSummerChanged;

// 輸入控制器
TextEditingController contractCapacityController;
TextEditingController maxDemandController;
TextEditingController billingUnitsController;

// 輸入變更回調
ValueChanged<String>? onContractCapacityChanged;
ValueChanged<String>? onMaxDemandChanged;
ValueChanged<String>? onBillingUnitsChanged;

// 結果控制器
TextEditingController basicElectricityController;
TextEditingController excessDemandController;
TextEditingController flowElectricityController;
TextEditingController totalElectricityController;

// 計算狀態
bool step2Calculated;
bool step3Calculated;

// 可選參數
TextEditingController? totalMonthlySavingController;
Widget? pieChart;

// 資訊按鈕回調
void Function(String fieldName) onInfoTap;
```

**UI 結構**：
- SingleChildScrollView
  - 頁面標題
  - `BillInfoForm` 組件

---

### 4. **lib/widgets/bill_info_form.dart** (台電帳單表單)

**主要職責**：
- 顯示台電帳單輸入欄位
- 顯示計算結果
- 顯示電費組成圓餅圖

**UI 結構**：

#### **輸入區塊**（Lines 79-205）
左右雙欄佈局：
- **左欄**：
  - 固定勾選：電力需量非營業用、非時間電價
  - 季節選擇：夏季、非夏季
  - 輸入欄位：契約容量、最高需量、計費度數
- **右欄**：
  - 結果欄位：基本電價、超約費用、流動電價、總電價

#### **計算結果摘要卡片**（Lines 207-314）
條件顯示（`if (step2Calculated)`）：
1. **本期電費總計卡片**（藍色）
   - 圖示：`Icons.receipt_long`
   - 數值：`totalElectricityController.text`
2. **與上期比較卡片**（綠色）
   - 條件：`step3Calculated && totalMonthlySavingController != null`
   - 圖示：`Icons.trending_down`
   - 數值：`totalMonthlySavingController.text`

#### **圓餅圖**（Lines 316-325）
條件顯示（`if (step2Calculated && pieChart != null)`）

**輔助方法**：
- `_buildInputFieldWithUnit()`：建立輸入欄位
- `_buildReadOnlyFieldWithUnit()`：建立唯讀結果欄位

---

### 5. **lib/pages/step3_payback.dart** (步驟三頁面)

**主要職責**：
- 包裝 `PaybackForm` 組件
- 傳遞參數給表單

**接收參數**：
```dart
// 計價方式
String? pricingMethod;
ValueChanged<String?> onPricingMethodChanged;

// 租賃價格
TextEditingController rentalPriceController;
ValueChanged<String>? onRentalPriceChanged;

// 買斷價格
TextEditingController buyoutPriceController;
ValueChanged<String>? onBuyoutPriceChanged;

// 燈管數量
TextEditingController step3LightCountController;
ValueChanged<String>? onLightCountChanged;

// 結果控制器
TextEditingController monthlyRentalController;
TextEditingController totalMonthlySavingController;
TextEditingController buyoutTotalController;
TextEditingController paybackPeriodController;

// 計算狀態
bool step2Calculated;
bool step3Calculated;

// 可選參數
Widget? trendChart;

// 資訊按鈕回調
void Function(String fieldName) onInfoTap;
```

---

### 6. **lib/widgets/payback_form.dart** (節電回本表單)

**主要職責**：
- 顯示計價方式選擇（租賃/買斷）
- 顯示燈管數量輸入
- 顯示計算結果
- 顯示回本趨勢折線圖

**UI 結構**：

#### **輸入區塊**（Lines 75-88）
- 計價方式選擇：`_buildPricingMethodSection()`

#### **結果區塊**（Lines 92-149）
- 燈管數量輸入
- **租賃模式欄位**：
  - 每月燈管租賃費用
  - 每月總共可節省費用
- **買斷模式欄位**：
  - 買斷總費用
  - 多久時間攤提

#### **計算結果摘要卡片**（Lines 151-374）
條件顯示（`if (step3Calculated && step2Calculated)`）：

**租賃模式結果**（Lines 161-266）：
- 左卡片：每月租金（橘色）
  - 圖示：`Icons.attach_money`
  - 數值：`monthlyRentalController.text`
- 右卡片：每月淨節省（綠色）
  - 圖示：`Icons.savings`
  - 數值：`totalMonthlySavingController.text`

**買斷模式結果**（Lines 268-373）：
- 左卡片：買斷總價（紫色）
  - 圖示：`Icons.shopping_cart`
  - 數值：`buyoutTotalController.text`
- 右卡片：回本期間（藍色）
  - 圖示：`Icons.event_available`
  - 數值：`paybackPeriodController.text`

#### **折線圖**（Lines 376-385）
條件顯示（`if (step3Calculated && step2Calculated && trendChart != null)`）

**輔助方法**：
- `_buildPricingMethodSection()`：建立計價方式選擇區塊
- `_buildInputFieldWithUnit()`：建立輸入欄位
- `_buildReadOnlyFieldWithUnit()`：建立唯讀結果欄位

---

### 7. **lib/utils/electricity_calculator.dart** (電費計算邏輯)

**主要職責**：
- 實作台電電費計算公式

**主要函數**：

#### `double calculateBasicElectricity(double contractCapacity, bool isSummer)`
- **功能**：計算基本電價（約定）
- **公式**：
  ```dart
  夏季：contractCapacity * ElectricityPricing.summerBasicRate
  非夏季：contractCapacity * ElectricityPricing.nonSummerBasicRate
  ```
- **回傳**：基本電價（元）

#### `double calculateExcessDemand(double maxDemand, double contractCapacity, bool isSummer)`
- **功能**：計算最高需量超約費用
- **公式**：
  ```dart
  if (maxDemand > contractCapacity) {
    excess = maxDemand - contractCapacity
    夏季：excess * ElectricityPricing.summerExcessRate * 2
    非夏季：excess * ElectricityPricing.nonSummerExcessRate * 2
  }
  ```
- **回傳**：超約費用（元）

#### `double calculateFlowElectricity(double billingUnits, bool isSummer)`
- **功能**：計算流動電價
- **公式**（分級累進）：
  ```dart
  夏季級距：
    0-330度：2.10元/度
    331-700度：2.89元/度
    701-1500度：3.94元/度
    1501度以上：5.17元/度

  非夏季級距：
    0-330度：2.10元/度
    331-700度：2.62元/度
    701-1500度：3.61元/度
    1501度以上：4.01元/度
  ```
- **回傳**：流動電價（元）

---

### 8. **lib/utils/lighting_calculator.dart** (燈管耗電計算邏輯)

**主要職責**：
- 計算車道燈/車位燈的每日耗電量
- 處理日夜分段與全天候模式
- 計算感應亮度變化

**主要函數**：

#### `double calculateDrivewayWattage(LightingStrategy strategy)`
- **功能**：計算車道燈每日耗電（Wh）
- **邏輯**：
  1. 判斷全天候或日夜分段模式
  2. 對每個時段：
     ```dart
     baseWattage = duration * beforeSensingWattage
     sensingWattage = sensingCount * sensingHours * (afterWattage - beforeWattage)
     totalWattage = baseWattage + sensingWattage
     ```
  3. 車道燈感應次數：
     - 日間：1440次/天
     - 夜間：885次/天
- **回傳**：每日耗電（Wh）

#### `double calculateParkingWattage(LightingStrategy strategy)`
- **功能**：計算車位燈每日耗電（Wh）
- **邏輯**：同車道燈，但感應次數不同
  - 日間：80次/天
  - 夜間：30次/天
- **回傳**：每日耗電（Wh）

**輔助函數**：
- `_calculateTimeSlotWattage()`：計算單一時段耗電
- `_getSensingCount()`：取得感應次數

---

### 9. **lib/models/lighting_strategy.dart** (亮燈策略模型)

**資料結構**：

#### `class TimeSlotConfig` (時段設定)
```dart
double startHour;              // 開始時間 (0-24)
double endHour;                // 結束時間 (0-24)
bool isAllDay;                 // 是否全天候
BrightnessConfig brightness;   // 亮度設定

// 計算時段長度
double get duration {
  if (isAllDay) return 24.0;
  double diff = endHour - startHour;
  return diff < 0 ? diff + 24 : diff;  // 處理跨午夜情況
}
```

#### `class BrightnessConfig` (亮度設定)
```dart
int brightnessBeforeSensing;   // 感應前亮度 (0-100%)
int brightnessAfterSensing;    // 感應後亮度 (0-100%)
int sensingDuration;           // 感應時間 (秒)
```

#### `class LightingStrategy` (燈管策略)
```dart
int count;                     // 燈管數量
TimeSlotConfig daytime;        // 日間時段
TimeSlotConfig? nighttime;     // 夜間時段 (可選)

bool get isAllDayMode => daytime.isAllDay;
```

---

### 10. **lib/constants/brightness_wattage_map.dart** (亮度-瓦數對照表)

**主要職責**：
- 提供亮度百分比與實際瓦數的對照關係

**關鍵方法**：

#### `static double getWattage(int brightnessPercent)`
- **功能**：根據亮度百分比取得對應瓦數
- **對照表**：
  ```dart
  0% → 0W
  10% → 1.3W
  20% → 2.6W
  30% → 3.9W
  40% → 5.2W
  50% → 6.5W
  60% → 7.8W
  70% → 9.1W
  80% → 10.4W
  90% → 11.7W
  100% → 13W
  ```
- **回傳**：瓦數（W）

---

### 11. **lib/constants/electricity_pricing.dart** (電價常數)

**主要職責**：
- 定義台電電價費率

**常數定義**：
```dart
// 基本電價（元/瓩）
static const double summerBasicRate = 233.0;        // 夏季
static const double nonSummerBasicRate = 170.1;     // 非夏季

// 超約費率（元/瓩）
static const double summerExcessRate = 466.0;       // 夏季
static const double nonSummerExcessRate = 340.2;    // 非夏季

// 流動電價級距（元/度）
// 夏季
static const List<double> summerFlowRates = [2.10, 2.89, 3.94, 5.17];
static const List<int> summerFlowThresholds = [330, 700, 1500];

// 非夏季
static const List<double> nonSummerFlowRates = [2.10, 2.62, 3.61, 4.01];
static const List<int> nonSummerFlowThresholds = [330, 700, 1500];
```

---

### 12. **lib/widgets/charts/electricity_cost_pie_chart.dart** (電費組成圓餅圖)

**主要職責**：
- 視覺化呈現電費組成比例

**接收參數**：
```dart
double basicElectricity;       // 基本電費
double flowElectricity;        // 流動電費
double excessDemand;           // 超約費用
```

**圖表配置**：
- **基本電費**：藍色 (`Colors.blue[400]`)
- **流動電費**：橘色 (`Colors.orange[400]`)
- **超約費用**：紅色 (`Colors.red[400]`)

**使用套件**：`fl_chart: ^0.69.0`

**關鍵功能**：
- 自動計算百分比
- 顯示圖例
- 互動式顯示（點擊突出顯示）

---

### 13. **lib/widgets/charts/payback_trend_chart.dart** (回本趨勢折線圖)

**主要職責**：
- 視覺化呈現 12 個月累積節電趨勢
- 顯示買斷模式的回本點

**接收參數**：
```dart
double monthlySaving;          // 每月節電金額
double? buyoutTotal;           // 買斷總價（可選）
```

**圖表配置**：
- X 軸：月份（1-12）
- Y 軸：累積節電金額（元）
- 線條顏色：綠色 (`Colors.green`)
- 回本點標記：紅色虛線（買斷模式）

**計算邏輯**：
```dart
累積節電[月份] = monthlySaving * 月份
回本月份 = buyoutTotal / monthlySaving
```

**使用套件**：`fl_chart: ^0.69.0`

---

### 14. **lib/widgets/result_sidebar.dart** (結果側邊欄)

**主要職責**：
- 在桌面版側邊欄顯示 Step 1 計算結果摘要

**接收參數**：
```dart
double? aiMonthlyConsumption;   // AI燈每月耗電
double? oldMonthlyConsumption;  // 舊燈每月耗電
double? monthlySavings;         // 每月節電量
double? savingsRate;            // 節電率
```

**UI 結構**：
1. **標題**：「計算結果」
2. **結果項目**（四項）：
   - AI 燈管每月耗電（度）
   - 舊燈管每月耗電（度）
   - 每月節電量（度）
   - 節電率（%）

---

### 15. **lib/widgets/input_components/lighting_input_field.dart** (燈管輸入欄位)

**主要職責**：
- 提供可重用的燈管數量/瓦數輸入欄位

**接收參數**：
```dart
String label;                  // 欄位標籤
TextEditingController controller;
String unit;                   // 單位（支/W）
ValueChanged<String>? onChanged;
bool integerOnly;              // 是否限制整數
```

**UI 特性**：
- 白色背景輸入框
- 右側顯示單位
- 數字鍵盤
- 可選的整數限制

---

### 16. **lib/widgets/input_components/time_slot_card.dart** (時段設定卡片)

**主要職責**：
- 提供時段設定 UI（開始時間、結束時間、亮度、感應時間）

**接收參數**：
```dart
String title;                  // 卡片標題（日間/夜間）
TimeSlotConfig config;         // 時段設定
Function(TimeSlotConfig) onChanged;
Color color;                   // 主題顏色
```

**UI 結構**：
1. **全天候開關**
2. **時間選擇器**（若非全天候）：
   - 開始時間滑桿
   - 結束時間滑桿
3. **亮度設定**：
   - 感應前亮度滑桿
   - 感應後亮度滑桿
4. **感應時間**：
   - 感應持續秒數滑桿

---

## 🧪 測試檔案

### **test/utils/lighting_calculator_smart_test.dart** (智能診斷測試)

**主要職責**：
- 自動驗證燈管計算邏輯正確性
- 診斷常見計算錯誤

**測試組**：

#### 1. `智能檢測 - 車道燈計算`
- **車道燈日夜分段模式測試**：
  - 獨立計算預期結果
  - 比對實際結果
  - 自動診斷錯誤類型

- **車位燈日夜分段模式測試**：
  - 同上

#### 2. `智能檢測 - 邊界情況`
- **跨午夜時段檢測**（23:00-1:00）：
  - 驗證跨午夜時段修正邏輯
  - 檢查 duration 計算是否正確

**診斷功能**：
1. **跨午夜問題診斷**：
   - 檢測 `endHour - startHour < 0` 情況
   - 提示應修正為 `diff + 24`
2. **感應次數錯誤診斷**：
   - 檢查是否使用錯誤的感應次數
3. **瓦數對照檢查**：
   - 驗證亮度-瓦數對照表使用正確

**執行方式**：
```bash
flutter test test/utils/lighting_calculator_smart_test.dart
```

---

## 📊 資料流動圖

```
[使用者輸入]
    ↓
[main_v2.dart - TextEditingController]
    ↓
[_calculateResults() 觸發]
    ↓
┌─────────────────────────────────────────────────────────────┐
│ Step 1: AI 燈管計算                                          │
│   ├─ LightingCalculator.calculateDrivewayWattage()         │
│   ├─ LightingCalculator.calculateParkingWattage()          │
│   └─ 設定 _hasCalculated = true                            │
├─────────────────────────────────────────────────────────────┤
│ Step 2: 台電電費計算                                         │
│   ├─ ElectricityCalculator.calculateBasicElectricity()     │
│   ├─ ElectricityCalculator.calculateExcessDemand()         │
│   ├─ ElectricityCalculator.calculateFlowElectricity()      │
│   ├─ 建立 ElectricityCostPieChart                          │
│   └─ 設定 _step2Calculated = true                          │
├─────────────────────────────────────────────────────────────┤
│ Step 3: 節電回本計算                                         │
│   ├─ 租賃：monthlyRental, totalMonthlySaving               │
│   ├─ 買斷：buyoutTotal, paybackPeriod                      │
│   ├─ 建立 PaybackTrendChart                               │
│   └─ 設定 _step3Calculated = true                          │
└─────────────────────────────────────────────────────────────┘
    ↓
[setState() 更新 UI]
    ↓
┌─────────────────────────────────────────────────────────────┐
│ 根據計算狀態顯示結果                                          │
│   ├─ Step1AILights: 顯示結果卡片                           │
│   ├─ BillInfoForm: 顯示結果卡片 + 圓餅圖                    │
│   ├─ PaybackForm: 顯示結果卡片 + 折線圖                     │
│   └─ Sidebar: 顯示對應圖表或結果                            │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔍 已知問題

### **問題：Step 2 和 Step 3 結果不顯示**

**症狀**：
- Step 2 的計算結果卡片和圓餅圖未顯示
- Step 3 的計算結果卡片和折線圖未顯示

**可能原因**：
1. `_calculateResults()` 未被觸發
2. 輸入驗證過於嚴格，導致計算被跳過
3. `step2Calculated` 或 `step3Calculated` 未正確設為 `true`
4. 圖表組件建立失敗但無錯誤訊息

**待調查**：
- 檢查 `onChanged` 回調是否正確連接
- 檢查輸入驗證邏輯
- 添加調試日誌追蹤計算流程

---

## 🎨 UI 設計模式

### **結果卡片樣式**

所有結果卡片遵循統一設計：

```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.{color}[50],        // 淺色背景
    borderRadius: BorderRadius.circular(8),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(Icons.{icon}, color: Colors.{color}[700], size: 20),
          SizedBox(width: 8),
          Text('{標題}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
      SizedBox(height: 8),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('{數值}', style: TextStyle(fontSize: 28-32, fontWeight: FontWeight.bold)),
          SizedBox(width: 8),
          Text('{單位}', style: TextStyle(fontSize: 14-16, color: Colors.grey[600])),
        ],
      ),
    ],
  ),
)
```

### **顏色配置**

| 用途             | 顏色        | 色調      |
|------------------|-------------|-----------|
| 基本電費         | Blue        | [400]     |
| 流動電費         | Orange      | [400]     |
| 超約費用         | Red         | [400]     |
| AI燈耗電         | Green       | [50]/[900]|
| 每月節電         | Blue        | [50]/[900]|
| 節電率           | Orange      | [50]/[900]|
| 租賃費用         | Orange      | [50]/[900]|
| 淨節省           | Green       | [50]/[900]|
| 買斷總價         | Purple      | [50]/[900]|
| 回本期間         | Blue        | [50]/[900]|

---

## 📦 依賴套件

```yaml
dependencies:
  flutter:
    sdk: flutter
  fl_chart: ^0.69.0                    # 圖表套件

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
```

---

## 🚀 執行流程

1. **應用啟動**：`main_v2.dart` 初始化狀態
2. **Step 1**：
   - 使用者輸入燈管資訊
   - 設定亮燈策略
   - 點擊計算按鈕 → `_calculateResults()`
   - 顯示結果卡片
3. **Step 2**：
   - 使用者輸入台電帳單資訊
   - 自動觸發 `_calculateResults()`
   - 顯示電費結果 + 圓餅圖
4. **Step 3**：
   - 選擇計價方式（租賃/買斷）
   - 輸入價格和燈管數量
   - 自動觸發 `_calculateResults()`
   - 顯示回本結果 + 折線圖

---

## 📝 命名慣例

- **檔案**：snake_case（例：`lighting_calculator.dart`）
- **類別**：PascalCase（例：`LightingStrategy`）
- **變數/函數**：camelCase（例：`calculateResults`）
- **私有成員**：以 `_` 開頭（例：`_currentStep`）
- **常數**：camelCase（例：`summerBasicRate`）

---

## 📄 授權

此為專案內部文檔，所有內容受專案授權約束。
