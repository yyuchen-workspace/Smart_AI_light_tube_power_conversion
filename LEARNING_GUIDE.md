# 智慧AI燈管電力換算 - 學習指南

> 這份文件幫助你深入理解 main.dart 的設計理念與實作細節

---

## 📚 目錄

1. [專案架構概覽](#專案架構概覽)
2. [重要概念解析](#重要概念解析)
3. [程式碼結構說明](#程式碼結構說明)
4. [常見問題解答](#常見問題解答)

---

## 🏗️ 專案架構概覽

```
專案分層結構:
┌─────────────────────────────────────┐
│   UI層 (main.dart)                  │
│   - 使用者介面                       │
│   - 事件處理                         │
│   - 狀態管理                         │
├─────────────────────────────────────┤
│   元件層 (widgets/)                  │
│   - 圖表元件 (charts/)               │
│   - 共用元件 (common/)               │
├─────────────────────────────────────┤
│   邏輯層 (utils/)                    │
│   - 電費計算                         │
│   - 業務規則                         │
├─────────────────────────────────────┤
│   資料層 (constants/)                │
│   - 電價常數                         │
│   - 固定設定值                       │
└─────────────────────────────────────┘
```

### 為什麼要分層？

✅ **分離關注點** - 每一層專注做一件事
✅ **容易測試** - 邏輯層可以獨立測試
✅ **容易維護** - 修改計算邏輯不影響 UI
✅ **可重用** - 元件可以在其他專案使用

---

## 🔑 重要概念解析

### 1. StatelessWidget vs StatefulWidget

#### StatelessWidget (無狀態元件)

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(...);
  }
}
```

**特性:**
- 創建後不會改變
- 沒有內部狀態
- 適合靜態內容

**使用時機:**
- 純展示型元件 (Logo、標題)
- 配置型元件 (應用程式設定)

#### StatefulWidget (有狀態元件)

```dart
class CalculatorPage extends StatefulWidget {
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  int counter = 0;  // 這是「狀態」

  void increment() {
    setState(() {
      counter++;  // 修改狀態
    });
  }
}
```

**特性:**
- 可以改變內部資料
- 有生命週期方法
- 適合互動元件

**使用時機:**
- 需要回應使用者操作
- 需要顯示動態資料
- 需要執行非同步操作

### 為什麼要分成兩個類別？

```dart
// Widget 類別 (不可變)
class CalculatorPage extends StatefulWidget {
  final String title;  // 元件的「身份」資料

  CalculatorPage({required this.title});

  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

// State 類別 (可變)
class _CalculatorPageState extends State<CalculatorPage> {
  int counter = 0;  // 元件的「狀態」資料

  void increment() {
    setState(() => counter++);
  }
}
```

**好處:**
1. 當狀態改變時，只重建 State，不重建 Widget
2. Widget 保留身份，效能更好
3. 符合 Flutter 的響應式設計理念

---

### 2. TextEditingController 的作用

```dart
// 創建控制器
final controller = TextEditingController();

// 讀取輸入框的值
String value = controller.text;

// 設定輸入框的值
controller.text = '新的值';

// 監聽變化
controller.addListener(() {
  print('輸入框內容: ${controller.text}');
});

// ⚠️ 使用完必須釋放資源！
@override
void dispose() {
  controller.dispose();
  super.dispose();
}
```

**為什麼需要 Controller？**

❌ **沒有 Controller 的問題:**
```dart
TextField(
  onChanged: (value) {
    // 只能讀取，無法主動設定值
    print(value);
  },
)
```

✅ **使用 Controller 的好處:**
```dart
final controller = TextEditingController();

TextField(
  controller: controller,
  onChanged: (value) {
    // 既可以讀取，也可以設定
    if (value.length > 10) {
      controller.text = value.substring(0, 10);  // 限制長度
    }
  },
)
```

---

### 3. setState() 的運作原理

```dart
void updateValue() {
  // ❌ 錯誤：直接修改狀態，Flutter 不知道要重新繪製
  counter = 10;

  // ✅ 正確：用 setState() 包裹，Flutter 會重新執行 build()
  setState(() {
    counter = 10;
  });
}
```

**執行流程:**
```
使用者點擊按鈕
    ↓
呼叫 setState()
    ↓
標記元件為 dirty (需要重繪)
    ↓
在下一個畫面幀執行 build()
    ↓
產生新的 Widget 樹
    ↓
Flutter 比較新舊 Widget 樹
    ↓
只更新有變化的部分
    ↓
畫面顯示新內容
```

**注意事項:**
```dart
// ⚠️ 不要在 setState() 中執行耗時操作
setState(() {
  // ❌ 錯誤：可能會阻塞 UI
  for (int i = 0; i < 1000000; i++) {
    // 大量計算...
  }
});

// ✅ 正確：先計算，再 setState
var result = 0;
for (int i = 0; i < 1000000; i++) {
  result += i;
}
setState(() {
  counter = result;  // 只在這裡更新狀態
});
```

---

### 4. Widget 生命週期

```dart
class _MyWidgetState extends State<MyWidget> {
  // 1. 建構子 (Constructor)
  _MyWidgetState() {
    print('1. 建構子被呼叫');
  }

  // 2. initState - 初始化
  @override
  void initState() {
    super.initState();
    print('2. initState 被呼叫');
    // 在這裡初始化資料、訂閱事件
  }

  // 3. didChangeDependencies - 依賴改變
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('3. didChangeDependencies 被呼叫');
    // 當依賴的 InheritedWidget 改變時會呼叫
  }

  // 4. build - 建構 UI
  @override
  Widget build(BuildContext context) {
    print('4. build 被呼叫');
    return Container();
  }

  // 5. didUpdateWidget - 元件更新
  @override
  void didUpdateWidget(MyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('5. didUpdateWidget 被呼叫');
    // 當父元件重建且傳入新參數時呼叫
  }

  // 6. setState - 觸發重建
  void updateState() {
    setState(() {
      print('6. setState 被呼叫');
      // 修改狀態，會觸發 build() 重新執行
    });
  }

  // 7. deactivate - 元件暫時移除
  @override
  void deactivate() {
    print('7. deactivate 被呼叫');
    super.deactivate();
    // 元件從 Widget 樹移除時呼叫(但可能重新插入)
  }

  // 8. dispose - 元件永久銷毀
  @override
  void dispose() {
    print('8. dispose 被呼叫');
    // 釋放資源：關閉串流、取消訂閱、dispose controllers
    super.dispose();
  }
}
```

**常見的生命週期順序:**

**初次載入:**
```
Constructor → initState → didChangeDependencies → build
```

**使用者互動:**
```
setState → build
```

**元件銷毀:**
```
deactivate → dispose
```

---

## 📝 程式碼結構說明

### main.dart 的整體結構

```dart
// ===== 第一部分：導入套件 =====
import 'package:flutter/material.dart';
import ...

// ===== 第二部分：進入點 =====
void main() => runApp(MyApp());

// ===== 第三部分：根元件 (StatelessWidget) =====
class MyApp extends StatelessWidget { ... }

// ===== 第四部分：計算器頁面 (StatefulWidget) =====
class CalculatorPage extends StatefulWidget { ... }

// ===== 第五部分：狀態類別 =====
class _CalculatorPageState extends State<CalculatorPage> {

  // 5.1 成員變數 (Controllers、狀態變數)
  final TextEditingController controller = ...;
  bool isCalculated = false;

  // 5.2 生命週期方法
  @override
  void initState() { ... }

  @override
  void dispose() { ... }

  // 5.3 業務邏輯方法
  void _calculateResults() { ... }
  void _updateNotification() { ... }

  // 5.4 UI輔助方法
  Widget _buildInputField() { ... }
  Widget _buildSectionCard() { ... }

  // 5.5 建構UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(...);
  }
}
```

### 變數命名規則

```dart
// 私有變數/方法：前綴 _
void _calculateResults() { ... }
int _counter = 0;

// 公開變數/方法：無前綴
void calculateResults() { ... }
int counter = 0;

// 常數：全大寫+底線
const int MAX_VALUE = 100;

// final 變數：駝峰式
final TextEditingController myController = ...;

// 類別名稱：大駝峰 (PascalCase)
class CalculatorPage { ... }

// 方法/變數名稱：小駝峰 (camelCase)
void updateNotification() { ... }
int itemCount = 0;
```

---

## ❓ 常見問題解答

### Q1: 為什麼有這麼多 Controller？

**A:** 每個輸入框都需要獨立的 Controller 來管理其內容。想像每個 Controller 是一個「遙控器」,控制一個特定的輸入框。

```dart
// 如果只用一個 Controller
final controller = TextEditingController();

TextField(controller: controller);  // 輸入框 A
TextField(controller: controller);  // 輸入框 B
// 問題：A 和 B 會顯示相同內容！

// 正確做法：每個輸入框有自己的 Controller
final controllerA = TextEditingController();
final controllerB = TextEditingController();

TextField(controller: controllerA);  // 獨立控制
TextField(controller: controllerB);  // 獨立控制
```

### Q2: final vs const 有什麼區別？

```dart
// const：編譯時常數，值永遠不變
const int MAX_VALUE = 100;
const list = [1, 2, 3];

// final：執行時常數，賦值後不能改變變數本身
final controller = TextEditingController();
final list = [1, 2, 3];

// 差異：
controller = TextEditingController();  // ❌ 錯誤：final 不能重新賦值
controller.text = 'Hello';  // ✅ 可以：物件內部可以修改

list = [4, 5, 6];  // ❌ 錯誤：final 不能重新賦值
list.add(4);  // ✅ 可以：List 內容可以修改

// const list 完全不可變
const constList = [1, 2, 3];
constList.add(4);  // ❌ 錯誤：編譯時常數不能修改
```

### Q3: 為什麼要用 double.tryParse() 而不是 double.parse()？

```dart
// double.parse() - 解析失敗會拋出異常
try {
  double value = double.parse('abc');  // 💥 拋出 FormatException
} catch (e) {
  print('錯誤: $e');
}

// double.tryParse() - 解析失敗回傳 null (更安全)
double? value = double.tryParse('abc');  // 回傳 null，不會崩潰
if (value == null) {
  print('輸入無效');
}

// 實際應用
String input = textController.text;
double? value = double.tryParse(input);
if (value == null || value <= 0) {
  errors.add('請輸入有效的正數');
}
```

### Q4: 什麼時候用 StatelessWidget，什麼時候用 StatefulWidget？

**使用 StatelessWidget 的時機:**
- ✅ 純展示內容，不需要互動
- ✅ 資料從外部傳入，不會改變
- ✅ 例如：標題、圖標、靜態文字

**使用 StatefulWidget 的時機:**
- ✅ 需要回應使用者輸入
- ✅ 內部資料會隨時間改變
- ✅ 需要執行動畫
- ✅ 需要載入非同步資料

**範例:**
```dart
// StatelessWidget - 靜態標題
class AppTitle extends StatelessWidget {
  final String title;

  AppTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title);  // 只顯示，不改變
  }
}

// StatefulWidget - 計數器
class Counter extends StatefulWidget {
  @override
  _CounterState createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int count = 0;  // 會改變的狀態

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('計數: $count'),
        ElevatedButton(
          onPressed: () => setState(() => count++),
          child: Text('增加'),
        ),
      ],
    );
  }
}
```

### Q5: 為什麼 Controller 要在 dispose() 中釋放？

**A:** TextEditingController 內部會建立監聽器和緩衝區，佔用記憶體。如果不釋放，即使 Widget 被銷毀，這些資源仍會存在，造成記憶體洩漏。

```dart
// 記憶體洩漏範例
class BadWidget extends StatefulWidget {
  @override
  _BadWidgetState createState() => _BadWidgetState();
}

class _BadWidgetState extends State<BadWidget> {
  final controller = TextEditingController();

  // ❌ 沒有 dispose，記憶體洩漏！
  // 每次創建 BadWidget，都會留下無法釋放的 controller
}

// 正確做法
class GoodWidget extends StatefulWidget {
  @override
  _GoodWidgetState createState() => _GoodWidgetState();
}

class _GoodWidgetState extends State<GoodWidget> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();  // ✅ 正確釋放資源
    super.dispose();
  }
}
```

**記憶口訣:** 有 `new` 就要有 `dispose`，有 `create` 就要有 `close`

---

## 🎓 進階學習建議

### 接下來可以學習的主題

1. **狀態管理進階**
   - Provider
   - Riverpod
   - Bloc Pattern

2. **非同步程式設計**
   - Future 和 async/await
   - Stream
   - 錯誤處理

3. **測試**
   - Unit Test
   - Widget Test
   - Integration Test

4. **效能優化**
   - const 建構子
   - ListView.builder
   - RepaintBoundary

---

## 📖 推薦資源

- [Flutter 官方文件](https://flutter.dev/docs)
- [Dart 語言導覽](https://dart.dev/guides/language/language-tour)
- [Flutter Widget 目錄](https://flutter.dev/docs/development/ui/widgets)

---

**祝你學習愉快! 🚀**
