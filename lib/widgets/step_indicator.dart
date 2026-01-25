/*
 * ============================================================
 * 步驟進度指示器元件
 * ============================================================
 *
 * 顯示當前步驟進度，支援三個步驟的視覺化呈現
 */

import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep; // 當前步驟 (0, 1, 2)
  final List<String> stepTitles; // 步驟標題列表
  final Function(int) onStepTapped; // 點擊步驟的回調函數

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.stepTitles,
    required this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // 手機版大幅縮小垂直間距
    final verticalPadding = isMobile ? 3.0 : 6.0;

    return Container(
      padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 16),
      child: Row(
        children: [
          // 左側空白區 (1/6)
          Expanded(flex: 1, child: SizedBox()),

          // 步驟 1 (固定寬度，置中)
          SizedBox(
            width: 100,
            child: GestureDetector(
              onTap: () => onStepTapped(0),
              behavior: HitTestBehavior.opaque,
              child: _buildStep(
                context: context,
                index: 0,
                title: stepTitles[0],
                isActive: 0 == currentStep,
                isCompleted: 0 < currentStep,
              ),
            ),
          ),

          // 中間區域 (1/3) - 包含左側空白 + 連接線 + 右側空白
          Expanded(
            flex: 2,
            child: Container(
              height: 2,
              margin: EdgeInsets.only(bottom: 24), // 對齊圓圈中心
              color: 0 < currentStep ? Colors.green : Colors.grey[300],
            ),
          ),

          // 步驟 2 (固定寬度，置中)
          SizedBox(
            width: 100,
            child: GestureDetector(
              onTap: () => onStepTapped(1),
              behavior: HitTestBehavior.opaque,
              child: _buildStep(
                context: context,
                index: 1,
                title: stepTitles[1],
                isActive: 1 == currentStep,
                isCompleted: 1 < currentStep,
              ),
            ),
          ),

          // 右側空白區 (1/6)
          Expanded(flex: 1, child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildStep({
    required BuildContext context,
    required int index,
    required String title,
    required bool isActive,
    required bool isCompleted,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // 手機版縮小尺寸
    final circleSize = isMobile ? 20.0 : 24.0;
    final circleFontSize = isMobile ? 12.0 : 14.0;
    final titleFontSize = isMobile ? 12.0 : 14.0;
    final spacingHeight = isMobile ? 3.0 : 4.0;

    Color circleColor;
    Color textColor;
    Widget circleChild;

    // 已完成或當前步驟：藍色填滿 + 數字
    if (isCompleted || isActive) {
      circleColor = Colors.blue;
      textColor = Colors.blue[700]!;
      circleChild = Text(
        '${index + 1}',
        style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: circleFontSize),
      );
    } else {
      // 未完成步驟：灰色 + 數字
      circleColor = Colors.grey[300]!;
      textColor = Colors.grey[600]!;
      circleChild = Text(
        '${index + 1}',
        style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: circleFontSize),
      );
    }

    return Column(
      children: [
        // 圓點
        Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
          ),
          child: Center(child: circleChild),
        ),
        SizedBox(height: spacingHeight),

        // 標題
        Text(
          title,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
