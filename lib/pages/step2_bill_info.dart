/*
 * ============================================================
 * 步驟二：台電帳單資訊頁面（選填）
 * ============================================================
 */

import 'package:flutter/material.dart';

class Step2BillInfo extends StatelessWidget {
  final Widget content; // 直接接收現有的 Step2 內容

  const Step2BillInfo({
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
            '台電帳單資訊',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
          SizedBox(height: 8),
          Text(
            '此為選填項目，可提供更精確的電費試算',
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
