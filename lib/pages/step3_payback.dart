/*
 * ============================================================
 * 步驟三：試算攤提時間頁面（選填）
 * ============================================================
 */

import 'package:flutter/material.dart';

class Step3Payback extends StatelessWidget {
  final Widget content; // 直接接收現有的 Step3 內容

  const Step3Payback({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 頁面標題
          Text(
            '攤提計算',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange[900],
            ),
          ),
          SizedBox(height: 8),
          Text(
            '此為選填項目，可計算投資回本時間',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 32),

          // 原有內容
          content,
        ],
      ),
    );
  }
}
