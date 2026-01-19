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

  const StepIndicator({
    Key? key,
    required this.currentStep,
    required this.stepTitles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        children: List.generate(
          stepTitles.length,
          (index) => Expanded(
            child: Row(
              children: [
                // 步驟圓點和標題
                Expanded(
                  child: _buildStep(
                    index: index,
                    title: stepTitles[index],
                    isActive: index == currentStep,
                    isCompleted: index < currentStep,
                  ),
                ),

                // 連接線（最後一個步驟不顯示）
                if (index < stepTitles.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: index < currentStep
                          ? Colors.green
                          : Colors.grey[300],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep({
    required int index,
    required String title,
    required bool isActive,
    required bool isCompleted,
  }) {
    Color circleColor;
    Color textColor;
    Widget circleChild;

    if (isCompleted) {
      circleColor = Colors.green;
      textColor = Colors.green[700]!;
      circleChild = Icon(Icons.check, color: Colors.white, size: 16);
    } else if (isActive) {
      circleColor = Colors.blue;
      textColor = Colors.blue[700]!;
      circleChild = Text(
        '${index + 1}',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      );
    } else {
      circleColor = Colors.grey[300]!;
      textColor = Colors.grey[600]!;
      circleChild = Text(
        '${index + 1}',
        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
      );
    }

    return Column(
      children: [
        // 圓點
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
          ),
          child: Center(child: circleChild),
        ),
        SizedBox(height: 8),

        // 標題
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
