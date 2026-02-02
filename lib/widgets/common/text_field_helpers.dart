import 'package:flutter/material.dart';

/// TextField 輔助函式集合
///
/// 提供常用的 TextField 互動功能，避免程式碼重複

/// 產生自動全選文字的 onTap 回調函式
///
/// 當用戶點擊 TextField 時，自動選取所有文字，方便用戶直接輸入覆蓋
///
/// 使用範例：
/// ```dart
/// TextField(
///   controller: myController,
///   onTap: autoSelectOnTap(myController),
///   // ... 其他屬性
/// )
/// ```
VoidCallback autoSelectOnTap(TextEditingController controller) {
  return () {
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );
  };
}
