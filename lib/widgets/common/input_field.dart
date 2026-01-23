import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 帶單位的輸入欄位組件
///
/// 提供標題、輸入框、單位和可選的信息按鈕
/// 支持整數和小數輸入
class InputFieldWithUnit extends StatelessWidget {
  final String title;                          // 欄位標題
  final TextEditingController controller;      // 輸入控制器
  final String unit;                           // 單位文字
  final bool hasInfo;                          // 是否顯示信息按鈕
  final VoidCallback? onInfoTap;               // 信息按鈕點擊回調
  final void Function(String)? onChanged;      // 輸入變更回調
  final bool integerOnly;                      // 是否只允許整數
  final bool titleRed;                         // 標題是否為紅色

  const InputFieldWithUnit({
    Key? key,
    required this.title,
    required this.controller,
    required this.unit,
    this.hasInfo = false,
    this.onInfoTap,
    this.onChanged,
    this.integerOnly = false,
    this.titleRed = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 標題行（包含可選的信息按鈕）
        Row(
          children: [
            Flexible(child: _buildTitle()),
            if (hasInfo) ...[
              SizedBox(width: 8),
              _buildInfoButton(),
            ],
          ],
        ),
        // 輸入欄位
        SizedBox(
          height: 56,
          child: TextField(
            controller: controller,
            onTap: () {
              // 點擊時自動全選文字，方便用戶直接輸入覆蓋
              controller.selection = TextSelection(
                baseOffset: 0,
                extentOffset: controller.text.length,
              );
            },
            onChanged: onChanged,
            keyboardType: TextInputType.number,
            inputFormatters: [
              integerOnly
                  ? FilteringTextInputFormatter.digitsOnly
                  : FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
            ],
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              fillColor: Colors.white,
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              suffixText: unit,
              suffixStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
        ),
      ],
    );
  }

  /// 建構標題文字
  Widget _buildTitle() {
    return Padding(
      padding: EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: titleRed ? Colors.red : null,
        ),
      ),
    );
  }

  /// 建構信息按鈕（藍色圓形問號）
  Widget _buildInfoButton() {
    return GestureDetector(
      onTap: onInfoTap,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// 唯讀顯示欄位組件（用於結果展示）
///
/// 顯示計算結果，不可編輯
/// 支持紅色文字標示（需要重新計算）和灰色背景（未計算）
class ReadOnlyFieldWithUnit extends StatelessWidget {
  final String title;                          // 欄位標題
  final TextEditingController controller;      // 顯示控制器
  final String unit;                           // 單位文字
  final bool grayed;                           // 是否灰色背景（未計算狀態）
  final bool isRed;                            // 文字是否為紅色（需重算）
  final bool hasInfo;                          // 是否顯示信息按鈕
  final VoidCallback? onInfoTap;               // 信息按鈕點擊回調
  final bool titleRed;                         // 標題是否為紅色

  const ReadOnlyFieldWithUnit({
    Key? key,
    required this.title,
    required this.controller,
    required this.unit,
    this.grayed = false,
    this.isRed = false,
    this.hasInfo = false,
    this.onInfoTap,
    this.titleRed = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 標題行（包含可選的信息按鈕）
        Row(
          children: [
            Flexible(child: _buildTitle()),
            if (hasInfo) ...[
              SizedBox(width: 8),
              _buildInfoButton(),
            ],
          ],
        ),
        // 唯讀欄位
        SizedBox(
          height: 56,
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
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                suffixText: unit,
                suffixStyle: TextStyle(
                  fontSize: 14,
                  color: grayed ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 建構標題文字
  Widget _buildTitle() {
    return Padding(
      padding: EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: titleRed ? Colors.red : null,
        ),
      ),
    );
  }

  /// 建構信息按鈕（藍色圓形問號）
  Widget _buildInfoButton() {
    return GestureDetector(
      onTap: onInfoTap,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
