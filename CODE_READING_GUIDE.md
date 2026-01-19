# 程式碼閱讀指南 - 如何分辨內建函式庫與自訂功能

> 專為初學者設計,幫助你快速識別「哪些是 Flutter 提供的」、「哪些是你自己寫的」

---

## 🎨 顏色標記系統

我們用**四種顏色**來標記程式碼:

- 🟦 **藍色 = Flutter/Dart 內建** - 不需要自己實作,直接用
- 🟩 **綠色 = 外部套件** - 別人寫好的,透過 pubspec.yaml 安裝
- 🟧 **橘色 = 你的自訂程式碼** - 自己寫的類別、方法
- 🟪 **紫色 = 業務邏輯** - 你的計算邏輯、規則

---

## 📖 實戰範例:逐行解析

### 範例 1: import 語句

```dart
// 🟦 Flutter 內建套件 (藍色)
import 'package:flutter/material.dart';     // Flutter 的 Material Design UI 元件
import 'package:flutter/services.dart';     // Flutter 的系統服務 (輸入格式化等)

// 🟩 外部第三方套件 (綠色)
import 'package:fl_chart/fl_chart.dart';    // 圖表套件 (需要在 pubspec.yaml 安裝)

// 🟧 你的自訂元件 (橘色)
import 'widgets/charts/power_saving_chart.dart';      // 你自己寫的圖表元件
import 'widgets/common/input_field.dart';             // 你自己寫的輸入框元件

// 🟪 你的業務邏輯 (紫色)
import 'utils/electricity_calculator.dart';           // 你的電費計算邏輯
import 'constants/electricity_pricing.dart';          // 你的電價常數
```

**如何判斷?**
- ✅ `package:flutter/xxx` → 內建的 Flutter 框架
- ✅ `package:其他名稱/xxx` → 外部套件 (去 pubspec.yaml 可以看到)
- ✅ `widgets/xxx` 或 `utils/xxx` → 你自己寫的 (就在你的專案資料夾裡)

---

### 範例 2: 程式進入點

```dart
// 🟦 Flutter 內建函式
void main() {
  runApp(MyApp());  // 🟦 runApp() 是 Flutter 提供的,用來啟動應用程式
}

// 🟧 你自己定義的類別
class MyApp extends StatelessWidget {  // 🟦 StatelessWidget 是 Flutter 內建的父類別
  @override  // 🟦 Dart 語言的關鍵字
  Widget build(BuildContext context) {  // 🟦 build() 是 Flutter 要求實作的方法
    return MaterialApp(  // 🟦 MaterialApp 是 Flutter 內建元件
      title: '智慧AI燈管電力換算',  // 🟧 你填寫的內容
      home: CalculatorPage(),  // 🟧 你自己寫的頁面
    );
  }
}
```

**拆解說明:**

```dart
class MyApp extends StatelessWidget {
  ↑      ↑              ↑
  🟦     🟧              🟦
  Dart   你的類別名稱     Flutter提供的父類別
  關鍵字
```

---

### 範例 3: StatefulWidget (最容易混淆的部分)

```dart
// 🟧 你自己定義的類別名稱
class CalculatorPage extends StatefulWidget {
//    ↑ 橘色:你取的名字      ↑ 藍色:Flutter內建

  @override  // 🟦 Dart 關鍵字
  _CalculatorPageState createState() => _CalculatorPageState();
  // ↑ 橘色:你的State類別    ↑ 藍色:Flutter要求實作的方法
}

class _CalculatorPageState extends State<CalculatorPage> {
//    ↑ 橘色:你的類別             ↑ 藍色:Flutter內建
//                                      ↑ 橘色:對應上面的Widget

  // 🟦 Flutter 提供的控制器類別
  final TextEditingController myController = TextEditingController();
  //    ↑ 藍色:Flutter內建            ↑ 橘色:你的變數名稱

  // 🟧 你自己定義的變數
  bool isCalculated = false;
  // ↑ 藍色:Dart內建型別  ↑ 橘色:你的變數名稱

  // 🟦 Flutter 的生命週期方法
  @override
  void initState() {
    super.initState();  // 🟦 必須呼叫父類別的方法
    myController.text = '預設值';  // 🟧 你的初始化邏輯
  }

  // 🟧 你自己定義的方法
  void _calculateResults() {
    // 🟧 你的計算邏輯
    double result = 10 + 20;

    // 🟦 Flutter 提供的方法,用來更新畫面
    setState(() {
      // 🟧 你的狀態更新邏輯
      isCalculated = true;
    });
  }

  // 🟦 Flutter 要求實作的建構UI方法
  @override
  Widget build(BuildContext context) {
    return Scaffold(  // 🟦 Flutter 內建的頁面骨架元件
      appBar: AppBar(  // 🟦 Flutter 內建的標題列元件
        title: Text('我的計算器'),  // 🟦 Text 是 Flutter 內建 / 🟧 內容是你填的
      ),
      body: Column(  // 🟦 Flutter 內建的垂直排列元件
        children: [
          TextField(  // 🟦 Flutter 內建的輸入框元件
            controller: myController,  // 🟧 你的控制器
          ),
          ElevatedButton(  // 🟦 Flutter 內建的按鈕元件
            onPressed: _calculateResults,  // 🟧 你的方法
            child: Text('計算'),  // 🟦 Text 是內建 / 🟧 '計算' 是你填的
          ),
        ],
      ),
    );
  }
}
```

---

## 🔍 快速判斷技巧

### 技巧 1: 看「大寫開頭」還是「小寫開頭」

```dart
// 大寫開頭 → 通常是類別 (Class) 或元件 (Widget)
Widget                  // 🟦 Flutter 內建的基礎類別
MaterialApp             // 🟦 Flutter 內建元件
TextEditingController   // 🟦 Flutter 內建控制器類別
MyApp                   // 🟧 你自己定義的類別
CalculatorPage          // 🟧 你自己定義的類別
ElectricityCalculator   // 🟪 你自己寫的計算邏輯類別

// 小寫開頭 → 通常是方法、變數、關鍵字
runApp()                // 🟦 Flutter 內建函式
setState()              // 🟦 Flutter 內建方法
build()                 // 🟦 Flutter 要求實作的方法
_calculateResults()     // 🟧 你自己寫的方法
isCalculated            // 🟧 你自己定義的變數
```

### 技巧 2: 看是否在「你的專案資料夾」中

```dart
// 在你的專案中找得到原始碼 → 你自己寫的
import 'widgets/charts/power_saving_chart.dart';
//     ↑ 去 lib/widgets/charts/ 資料夾找得到這個檔案 → 🟧 你寫的

// 在你的專案中找不到原始碼 → Flutter/套件提供的
import 'package:flutter/material.dart';
//     ↑ 你的專案中沒有這個檔案,是 Flutter SDK 提供的 → 🟦 內建
```

### 技巧 3: 看「滑鼠游標停留」時的提示

在 VS Code 或 Android Studio 中:

```dart
// 游標停在 StatelessWidget 上
class MyApp extends StatelessWidget {
//                  ↑ 滑鼠停在這裡
}

// 提示會顯示:
// class StatelessWidget
// package:flutter/src/widgets/framework.dart
//         ↑ 顯示 flutter → 🟦 內建的!

// 游標停在自己的類別上
CalculatorPage()
// ↑ 滑鼠停在這裡

// 提示會顯示:
// class CalculatorPage
// lib/main.dart:87
//     ↑ 顯示 lib/ → 🟧 你自己寫的!
```

---

## 📊 視覺化對照表

### 你的 main.dart 完整分類

| 程式碼 | 類型 | 說明 |
|--------|------|------|
| `import 'package:flutter/material.dart'` | 🟦 內建 | Flutter 的 UI 元件庫 |
| `import 'package:fl_chart/fl_chart.dart'` | 🟩 套件 | 第三方圖表套件 |
| `import 'widgets/charts/power_saving_chart.dart'` | 🟧 自訂 | 你寫的圖表元件 |
| `import 'utils/electricity_calculator.dart'` | 🟪 邏輯 | 你的計算邏輯 |
| `void main()` | 🟦 內建 | Dart 程式進入點 |
| `runApp()` | 🟦 內建 | Flutter 啟動函式 |
| `MyApp` | 🟧 自訂 | 你的根元件 |
| `StatelessWidget` | 🟦 內建 | Flutter 基礎類別 |
| `MaterialApp` | 🟦 內建 | Flutter 應用程式框架 |
| `CalculatorPage` | 🟧 自訂 | 你的計算器頁面 |
| `StatefulWidget` | 🟦 內建 | Flutter 基礎類別 |
| `State` | 🟦 內建 | Flutter 狀態基礎類別 |
| `TextEditingController` | 🟦 內建 | Flutter 輸入控制器 |
| `contractCapacityController` | 🟧 自訂 | 你的變數名稱 |
| `electricityTypeNonBusiness` | 🟧 自訂 | 你的狀態變數 |
| `initState()` | 🟦 內建 | Flutter 生命週期方法 |
| `dispose()` | �� 內建 | Flutter 生命週期方法 |
| `setState()` | 🟦 內建 | Flutter 更新畫面的方法 |
| `_calculateResults()` | 🟧 自訂 | 你自己寫的計算方法 |
| `_updateNotification()` | 🟧 自訂 | 你自己寫的更新方法 |
| `build()` | 🟦 內建 | Flutter 要求實作的方法 |
| `Scaffold` | 🟦 內建 | Flutter 頁面骨架元件 |
| `AppBar` | 🟦 內建 | Flutter 標題列元件 |
| `Text` | 🟦 內建 | Flutter 文字元件 |
| `TextField` | 🟦 內建 | Flutter 輸入框元件 |
| `ElevatedButton` | 🟦 內建 | Flutter 按鈕元件 |
| `ElectricityCalculator.calculateBasicElectricity()` | 🟪 邏輯 | 你的計算邏輯 |
| `ElectricityPricing.aiLightWatt` | 🟪 邏輯 | 你的常數定義 |

---

## 🎯 實戰練習:彩色標記法

### 練習:標記以下程式碼

```dart
import 'package:flutter/material.dart';
import 'utils/calculator.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('計算器')),
        body: Calculator(),
      ),
    );
  }
}
```

**答案:**

```dart
// 🟦 Flutter內建
import 'package:flutter/material.dart';
// 🟪 你的邏輯
import 'utils/calculator.dart';

// 🟦 Dart關鍵字      🟦 Flutter函式
void main() => runApp(MyApp());
//                    ↑ 🟧 你的類別

// 🟦 Dart關鍵字  🟧 你的類別    🟦 Flutter類別
class MyApp extends StatelessWidget {
  @override  // 🟦 Dart關鍵字
  Widget build(BuildContext context) {  // 🟦 Flutter方法
    return MaterialApp(  // 🟦 Flutter元件
      home: Scaffold(  // 🟦 Flutter元件
        appBar: AppBar(title: Text('計算器')),  // 🟦 全部都是Flutter元件
        //                        ↑ 🟧 你填寫的文字內容
        body: Calculator(),  // 🟧 你自己寫的元件
      ),
    );
  }
}
```

---

## 📚 如何查詢「這是什麼」?

### 方法 1: 用 IDE 的「Go to Definition」功能

1. 把滑鼠游標放在想查詢的名稱上
2. 按 `Cmd + 點擊` (Mac) 或 `Ctrl + 點擊` (Windows)
3. 會跳到定義的地方:
   - 如果跳到 `lib/` 資料夾 → 🟧 你自己寫的
   - 如果跳到 SDK 或外部套件 → 🟦 內建或 🟩 套件

### 方法 2: 看檔案路徑

```dart
// 在 VS Code 中按 Cmd+P 搜尋檔案

// 搜尋: StatelessWidget
// 結果: .../flutter/packages/flutter/lib/src/widgets/framework.dart
//       ↑ 在 flutter SDK 裡 → 🟦 內建

// 搜尋: CalculatorPage
// 結果: lib/main.dart
//       ↑ 在你的專案裡 → 🟧 你寫的
```

### 方法 3: 查官方文件

**Flutter 內建元件/類別:**
- 網址: https://api.flutter.dev/
- 搜尋 `StatelessWidget`、`TextField` 等

**Dart 語言關鍵字:**
- 網址: https://dart.dev/guides/language/language-tour
- 查詢 `class`、`void`、`final` 等

**外部套件:**
- 網址: https://pub.dev/
- 搜尋套件名稱如 `fl_chart`

**你自己的程式碼:**
- 直接在專案中搜尋檔案!

---

## 🚀 給初學者的建議

### 1. 不要害怕「不知道這是什麼」

**這是正常的!** 連資深工程師也常常需要查文件。重點是:
- ✅ 知道**怎麼查**
- ✅ 知道**去哪裡查**
- ✅ 能**理解文件說明**

### 2. 建立「查詢反射」

遇到不認識的名稱,第一時間問自己:
1. 這是大寫還是小寫開頭? (類別 vs 方法/變數)
2. 我在專案中能找到這個檔案嗎? (自訂 vs 內建)
3. 滑鼠游標停在上面,提示顯示什麼? (查看來源)

### 3. 慢慢建立「內建清單」

**常見的 Flutter 內建元件** (看多了自然就記住):

**佈局元件:**
- `Column` (垂直排列)
- `Row` (水平排列)
- `Container` (容器)
- `Padding` (內邊距)
- `Center` (置中)

**基礎元件:**
- `Text` (文字)
- `TextField` (輸入框)
- `ElevatedButton` (按鈕)
- `Image` (圖片)
- `Icon` (圖示)

**頁面元件:**
- `Scaffold` (頁面骨架)
- `AppBar` (標題列)
- `BottomNavigationBar` (底部導航)
- `Drawer` (側邊選單)

**狀態管理:**
- `StatelessWidget` (無狀態元件)
- `StatefulWidget` (有狀態元件)
- `State` (狀態類別)
- `setState()` (更新狀態)

**輸入控制:**
- `TextEditingController` (輸入框控制器)
- `ScrollController` (滾動控制器)

### 4. 建立自己的「程式碼字典」

在學習過程中,把遇到的重要元件記錄下來:

```markdown
# 我的 Flutter 字典

## 已學會的內建元件
- `TextField`: 輸入框,可以讓使用者輸入文字
- `Text`: 顯示文字
- `ElevatedButton`: 按鈕

## 我的自訂元件
- `CalculatorPage`: 計算器主頁面
- `PowerSavingChart`: 節電圖表

## 我的工具類別
- `ElectricityCalculator`: 電費計算邏輯
- `ElectricityPricing`: 電價常數
```

---

## 📖 延伸閱讀

### 推薦資源

1. **Flutter Widget 目錄**
   - 網址: https://flutter.dev/docs/development/ui/widgets
   - 所有 Flutter 內建元件的完整清單

2. **Dart API 文件**
   - 網址: https://api.dart.dev/
   - Dart 語言的所有內建類別與函式

3. **Pub.dev (套件倉庫)**
   - 網址: https://pub.dev/
   - 尋找外部套件

4. **Flutter Cookbook (實作範例)**
   - 網址: https://flutter.dev/docs/cookbook
   - 常見功能的程式碼範例

---

## 💡 記憶口訣

```
看到不認識的程式碼,記住這個口訣:

🔵 藍色框架給你用 (Flutter/Dart 內建)
🟢 綠色套件別人寫 (pub.dev 安裝的)
🟠 橘色元件你來做 (widgets/ 自己寫的)
🟣 紫色邏輯在 utils (業務邏輯)

大寫開頭是類別,小寫開頭是方法
專案資料夾找得到,那就是你自己寫
找不到就是框架給,去官網文件查一查!
```

---

希望這份指南能幫助你快速區分「內建」與「自訂」程式碼! 🎉

如果還有任何疑問,隨時提出來!
