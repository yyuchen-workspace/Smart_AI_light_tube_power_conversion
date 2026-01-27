import 'package:flutter/material.dart';

/// 攤提時間摘要圖表
///
/// 根據租賃/買斷模式顯示不同內容：
/// - 租賃模式：每月租賃費用 + 每月可節省費用
/// - 買斷模式：總費用 + 攤提時間 + 之後每月節省
class PaybackSummaryChart extends StatelessWidget {
  final bool isRental; // true: 租賃模式, false: 買斷模式
  final double? monthlyRental; // 每月租賃費用（租賃模式）
  final double? monthlySaving; // 每月淨利（租賃模式）
  final double? monthlyElectricitySavingRental; // 每月可節省電費（租賃模式）
  final double? buyoutTotal; // 總費用（買斷模式）
  final double? paybackMonths; // 攤提時間（買斷模式，月）
  final double? monthlyElectricitySaving; // 之後每月節省電費（買斷模式）

  const PaybackSummaryChart({
    Key? key,
    required this.isRental,
    this.monthlyRental,
    this.monthlySaving,
    this.monthlyElectricitySavingRental,
    this.buyoutTotal,
    this.paybackMonths,
    this.monthlyElectricitySaving,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isRental
              ? [Colors.blue[50]!, Colors.blue[100]!]
              : [Colors.purple[50]!, Colors.purple[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRental ? Colors.blue[400]! : Colors.purple[400]!,
          width: 2,
        ),
      ),
      child: isRental ? _buildRentalView() : _buildBuyoutView(),
    );
  }

  /// 租賃模式視圖
  Widget _buildRentalView() {
    return Column(
      children: [
        // 標題
        Text(
          '租賃方案',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
        SizedBox(height: 20),

        // 每月可節省電費卡片
        _buildInfoCard(
          iconColor: Colors.green[600]!,
          title: '每月可節省電費',
          value: monthlyElectricitySavingRental ?? 0,
          unit: '元/月',
          backgroundColor: Colors.green[50]!,
          emoji: '💰', // 省錢
        ),

        SizedBox(height: 12),

        // 每月租賃費用卡片
        _buildInfoCard(
          iconColor: Colors.red[600]!,
          title: '每月租賃費用',
          value: monthlyRental ?? 0,
          unit: '元/月',
          backgroundColor: Colors.red[50]!,
          emoji: '💸', // 鈔票飛走
        ),

        SizedBox(height: 12),

        // 每月淨利卡片
        _buildInfoCard(
          iconColor: Colors.green[600]!,
          title: '每月淨利',
          value: monthlySaving ?? 0,
          unit: '元/月',
          backgroundColor: Colors.green[50]!,
          emoji: '😊', // 省錢開心
          showCrown: true, // 顯示皇冠圖示
        ),
      ],
    );
  }

  /// 買斷模式視圖
  Widget _buildBuyoutView() {
    return Column(
      children: [
        // 標題
        Text(
          '買斷方案',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.purple[900],
          ),
        ),
        SizedBox(height: 20),

        // 總費用卡片
        _buildInfoCard(
          iconColor: Colors.red[600]!,
          title: '總費用',
          value: buyoutTotal ?? 0,
          unit: '元',
          backgroundColor: Colors.red[50]!,
          emoji: '💸', // 鈔票飛走
        ),

        SizedBox(height: 12),

        // 攤提時間卡片
        _buildInfoCard(
          iconColor: Colors.green[600]!,
          title: '攤提時間',
          value: paybackMonths ?? 0,
          unit: '個月',
          backgroundColor: Colors.green[50]!,
          emoji: '😊', // 省錢開心
        ),

        SizedBox(height: 16),

        // 說明文字
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: Colors.purple[700]),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '攤提期間過後，每月可節省 ${(monthlyElectricitySaving ?? 0).toStringAsFixed(0)} 元電費 💰',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 構建資訊卡片
  Widget _buildInfoCard({
    IconData? icon,
    required Color iconColor,
    required String title,
    required double value,
    required String unit,
    required Color backgroundColor,
    required String emoji,
    String? subtitle,
    bool showCrown = false,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 主卡片
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: iconColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              // Emoji (+ Icon 可選)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    emoji,
                    style: TextStyle(fontSize: 32),
                  ),
                  if (icon != null) ...[
                    SizedBox(width: 6),
                    Icon(icon, color: iconColor, size: 26),
                  ],
                ],
              ),
              SizedBox(height: 12),

              // 標題
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),

              // 數值
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                  children: [
                    TextSpan(text: value.toStringAsFixed(0)),
                    TextSpan(
                      text: ' $unit',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // 副標題（可選）
              if (subtitle != null) ...[
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),

        // 皇冠圖示（卡片外部右上角，斜向）
        if (showCrown)
          Positioned(
            top: -8,
            right: -8,
            child: Transform.rotate(
              angle: 0.35, // 約 20 度傾斜
              child: Text(
                '👑',
                style: TextStyle(fontSize: 28),
              ),
            ),
          ),
      ],
    );
  }
}
