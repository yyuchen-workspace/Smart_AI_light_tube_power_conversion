/*
 * ============================================================
 * PDF 生成服務 - 版本 13.0
 * ============================================================
 *
 * 功能：將計算結果匯出為 PDF 評估報告
 * 格式：評估表格式（非報告式）
 *
 * 結構：
 * - 標題區：AI燈管節電效能評估 + 專案名稱 + 製表時間
 * - 第一區域：電費估算（黑字白底表格）
 * - 第二區域：費用攤提（白字黑底表格）
 * - 第三區域：圖表（未來實作）
 *
 * 中文字型：使用本地載入的 Noto Sans TC 字型
 */

import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;

class PdfGenerator {
  /// 載入中文字型（從本地 assets）
  static Future<pw.Font> _loadChineseFont() async {
    try {
      final fontData =
          await rootBundle.load('assets/fonts/NotoSansTC-Regular.ttf');
      return pw.Font.ttf(fontData);
    } catch (e) {
      print('Error loading Chinese font: $e');
      rethrow;
    }
  }

  /// 生成並下載 PDF 報告（版本 13.1 - 新格式）
  static Future<void> generateAndDownloadReport({
    // 專案資訊
    required String projectName,

    // Step 1 數據 (AI 燈管設定)
    required String drivewayCount,
    required String parkingCount,
    required String oldLightCount, // 原燈管數量
    required String oldLightWattage,
    required String oldMonthlyConsumption, // 原燈管每月耗電(度/月)
    required double drivewayConsumption, // 車道耗電(度/月)
    required double parkingConsumption, // 車位耗電(度/月)
    required String monthlySavings,
    required String oldMonthlyCost,
    required String newMonthlyCost,

    // 亮燈策略百分比與時段（版本 13.1 更新 - 分日間/夜間）
    required int drivewayDayBrightnessBefore,    // 車道日間感應前亮度 %
    required int drivewayDayBrightnessAfter,     // 車道日間感應後亮度 %
    required int drivewayNightBrightnessBefore,  // 車道夜間感應前亮度 %
    required int drivewayNightBrightnessAfter,   // 車道夜間感應後亮度 %
    required int parkingDayBrightnessBefore,     // 車位日間感應前亮度 %
    required int parkingDayBrightnessAfter,      // 車位日間感應後亮度 %
    required int parkingNightBrightnessBefore,   // 車位夜間感應前亮度 %
    required int parkingNightBrightnessAfter,    // 車位夜間感應後亮度 %
    required double drivewayDayHours,            // 車道日間時段長度(小時)
    required double drivewayNightHours,          // 車道夜間時段長度(小時)
    required double parkingDayHours,             // 車位日間時段長度(小時)
    required double parkingNightHours,           // 車位夜間時段長度(小時)
    required double drivewayDayConsumption,      // 車道日間耗電(度/月)
    required double drivewayNightConsumption,    // 車道夜間耗電(度/月)
    required double parkingDayConsumption,       // 車位日間耗電(度/月)
    required double parkingNightConsumption,     // 車位夜間耗電(度/月)

    // Step 3 數據 (攤提計算) - 版本 14.0 支援租賃/買斷
    required String step3LightCount,
    required String lightUnitPrice,
    required String gatewayCount,
    required String gatewayUnitPrice,
    required bool isRentalMode, // 是否為租賃模式（版本 14.0 新增）

    // 租賃模式專用參數
    required String monthlyRental, // 每月租賃費用
    required String monthlySaving, // 每月淨利

    // 買斷模式專用參數
    required String buyoutTotal, // 買斷總費用
    required String paybackPeriod, // 攤提時間(月)

    // 圖表圖片（可選，未來實作）
    Uint8List? chart1Image,
    Uint8List? chart2Image,
  }) async {
    // 載入中文字型
    final font = await _loadChineseFont();

    final pdf = pw.Document();

    // 計算節省電費
    final double monthlyCostSaving = (double.tryParse(oldMonthlyCost) ?? 0) -
        (double.tryParse(newMonthlyCost) ?? 0);
    final double yearlyCostSaving = monthlyCostSaving * 12;

    // 計算淨利
    final double monthlySavingValue = double.tryParse(monthlySaving) ?? 0;
    final double yearlySavingValue = monthlySavingValue * 12;

    // 生成 PDF 內容
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: font,
          bold: font,
          italic: font,
          boldItalic: font,
        ),
        build: (pw.Context context) {
          return [
            // 標題區
            _buildHeader(projectName),
            pw.SizedBox(height: 30),

            // 第一區域：電費估算
            _buildElectricitySection(
              drivewayCount: drivewayCount,
              parkingCount: parkingCount,
              oldLightCount: oldLightCount,
              oldLightWattage: oldLightWattage,
              oldMonthlyConsumption: oldMonthlyConsumption,
              monthlySavings: monthlySavings,
              monthlyCostSaving: monthlyCostSaving,
              yearlyCostSaving: yearlyCostSaving,
              drivewayDayBrightnessBefore: drivewayDayBrightnessBefore,
              drivewayDayBrightnessAfter: drivewayDayBrightnessAfter,
              drivewayNightBrightnessBefore: drivewayNightBrightnessBefore,
              drivewayNightBrightnessAfter: drivewayNightBrightnessAfter,
              parkingDayBrightnessBefore: parkingDayBrightnessBefore,
              parkingDayBrightnessAfter: parkingDayBrightnessAfter,
              parkingNightBrightnessBefore: parkingNightBrightnessBefore,
              parkingNightBrightnessAfter: parkingNightBrightnessAfter,
              drivewayDayHours: drivewayDayHours,
              drivewayNightHours: drivewayNightHours,
              parkingDayHours: parkingDayHours,
              parkingNightHours: parkingNightHours,
              drivewayDayConsumption: drivewayDayConsumption,
              drivewayNightConsumption: drivewayNightConsumption,
              parkingDayConsumption: parkingDayConsumption,
              parkingNightConsumption: parkingNightConsumption,
            ),

            // 強制換頁，確保「費用攤提」從新頁開始
            pw.NewPage(),

            // 第二區域：費用攤提（版本 14.0 - 支援租賃/買斷）
            _buildPaybackSection(
              step3LightCount: step3LightCount,
              lightUnitPrice: lightUnitPrice,
              gatewayCount: gatewayCount,
              gatewayUnitPrice: gatewayUnitPrice,
              isRentalMode: isRentalMode,
              monthlyRental: monthlyRental,
              monthlySaving: monthlySavingValue,
              yearlySaving: yearlySavingValue,
              buyoutTotal: buyoutTotal,
              paybackPeriod: paybackPeriod,
            ),

            // 第三區域：圖表
            if (chart1Image != null || chart2Image != null) ...[
              pw.SizedBox(height: 30),
              _buildChartsSection(chart1Image, chart2Image),
            ],
          ];
        },
      ),
    );

    // 生成 PDF 位元組
    final Uint8List pdfBytes = await pdf.save();

    // 在瀏覽器中下載
    _downloadPdf(pdfBytes, projectName);
  }

  /// 建立 PDF 標題區
  static pw.Widget _buildHeader(String projectName) {
    final now = DateTime.now();
    final dateString =
        '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        // 主標題 - 置中
        pw.Text(
          'AI燈管節電效能評估',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),

        // 專案名稱與製表時間 - 靠左對齊
        pw.Container(
          alignment: pw.Alignment.centerLeft,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '專案名：${projectName.isEmpty ? '（未命名）' : projectName}',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                '製表時間：$dateString',
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Divider(thickness: 2),
      ],
    );
  }

  /// 建立第一區域：電費估算（黑字白底表格）
  static pw.Widget _buildElectricitySection({
    required String drivewayCount,
    required String parkingCount,
    required String oldLightCount,
    required String oldLightWattage,
    required String oldMonthlyConsumption,
    required String monthlySavings,
    required double monthlyCostSaving,
    required double yearlyCostSaving,
    required int drivewayDayBrightnessBefore,
    required int drivewayDayBrightnessAfter,
    required int drivewayNightBrightnessBefore,
    required int drivewayNightBrightnessAfter,
    required int parkingDayBrightnessBefore,
    required int parkingDayBrightnessAfter,
    required int parkingNightBrightnessBefore,
    required int parkingNightBrightnessAfter,
    required double drivewayDayHours,
    required double drivewayNightHours,
    required double parkingDayHours,
    required double parkingNightHours,
    required double drivewayDayConsumption,
    required double drivewayNightConsumption,
    required double parkingDayConsumption,
    required double parkingNightConsumption,
  }) {
    // 使用 Column 包裝標題和表格，標題無框線，只有表格有框線
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // 標題（無框線）
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Text(
            '電費估算',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),

        // 表格（有框線）
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.black, width: 1),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(1.5),
            3: const pw.FlexColumnWidth(2),
            4: const pw.FlexColumnWidth(2),
          },
          children: [
            // 表頭
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.black),
              children: [
                _buildTableHeaderCell('燈具'),
                _buildTableHeaderCell('耗電瓦數'),
                _buildTableHeaderCell('數量'),
                _buildTableHeaderCell('亮燈時間'),
                _buildTableHeaderCell('耗電度數/月'),
              ],
            ),

            // 原燈管
            _buildElectricityRow(
              '原燈管',
              '$oldLightWattage W',
              '$oldLightCount 支',
              '24小時',
              '$oldMonthlyConsumption 度',
              isRed: false,
            ),

            // 車道日間 AI T8節電燈管
            _buildElectricityRow(
              '(車道)\n日間AI T8節電燈管',
              '感應前:$drivewayDayBrightnessBefore%\n感應後:$drivewayDayBrightnessAfter%',
              '$drivewayCount 支',
              '${drivewayDayHours.toStringAsFixed(1)}小時',
              '${drivewayDayConsumption.toStringAsFixed(1)} 度',
              isRed: false,
            ),

            // 車道夜間 AI T8節電燈管
            _buildElectricityRow(
              '(車道)\n夜間AI T8節電燈管',
              '感應前:$drivewayNightBrightnessBefore%\n感應後:$drivewayNightBrightnessAfter%',
              '$drivewayCount 支',
              '${drivewayNightHours.toStringAsFixed(1)}小時',
              '${drivewayNightConsumption.toStringAsFixed(1)} 度',
              isRed: false,
            ),

            // 車位日間 AI T8節電燈管
            _buildElectricityRow(
              '(車位)\n日間AI T8節電燈管',
              '感應前:$parkingDayBrightnessBefore%\n感應後:$parkingDayBrightnessAfter%',
              '$parkingCount 支',
              '${parkingDayHours.toStringAsFixed(1)}小時',
              '${parkingDayConsumption.toStringAsFixed(1)} 度',
              isRed: false,
            ),

            // 車位夜間 AI T8節電燈管
            _buildElectricityRow(
              '(車位)\n夜間AI T8節電燈管',
              '感應前:$parkingNightBrightnessBefore%\n感應後:$parkingNightBrightnessAfter%',
              '$parkingCount 支',
              '${parkingNightHours.toStringAsFixed(1)}小時',
              '${parkingNightConsumption.toStringAsFixed(1)} 度',
              isRed: false,
            ),

            // 節電度數(月) - 新增為表格行（加大字體）
            _buildElectricityRow(
              '節電度數(月)',
              '',
              '',
              '',
              '$monthlySavings 度',
              isRed: false,
              isImportant: true,
            ),

            // 節省電費(月) - 新增為表格行（紅色、加大字體）
            _buildElectricityRow(
              '節省電費(月)',
              '',
              '',
              '',
              '${monthlyCostSaving.toStringAsFixed(1)}\$',
              isRed: true,
              isImportant: true,
            ),

            // 節省電費(年) - 新增為表格行（紅色、加大字體）
            _buildElectricityRow(
              '節省電費(年)',
              '',
              '',
              '',
              '${yearlyCostSaving.toStringAsFixed(1)}\$',
              isRed: true,
              isImportant: true,
            ),
          ],
        ),
      ],
    );
  }

  /// 建立電費估算表格的資料列
  static pw.TableRow _buildElectricityRow(
    String light,
    String wattage,
    String count,
    String hours,
    String consumption, {
    required bool isRed,
    bool isImportant = false,
  }) {
    return pw.TableRow(
      children: [
        _buildTableCell(light, isImportant: isImportant),
        _buildTableCell(wattage, isImportant: isImportant),
        _buildTableCell(count, isImportant: isImportant),
        _buildTableCell(hours,
            isRed: isRed && hours == '不亮燈', isImportant: isImportant),
        _buildTableCell(consumption, isRed: isRed, isImportant: isImportant),
      ],
    );
  }

  /// 建立第二區域：費用攤提（黑字白底表格）- 版本 14.0 支援租賃/買斷
  static pw.Widget _buildPaybackSection({
    required String step3LightCount,
    required String lightUnitPrice,
    required String gatewayCount,
    required String gatewayUnitPrice,
    required bool isRentalMode, // 是否為租賃模式
    required String monthlyRental, // 租賃模式專用
    required double monthlySaving, // 租賃模式專用
    required double yearlySaving, // 租賃模式專用
    required String buyoutTotal, // 買斷模式專用
    required String paybackPeriod, // 買斷模式專用
  }) {
    // 計算金額
    final lightAmount = (double.tryParse(step3LightCount) ?? 0) *
        (double.tryParse(lightUnitPrice) ?? 0);
    final gatewayAmount = (double.tryParse(gatewayCount) ?? 0) *
        (double.tryParse(gatewayUnitPrice) ?? 0);

    // 使用 Column 包裝標題和表格，標題無框線，只有表格有框線
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // 標題（無框線）
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Text(
            '費用攤提',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),

        // 表格（有框線）
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.black, width: 1),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(1.5),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(2),
          },
          children: [
            // 表頭（黑底白字）
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.black),
              children: [
                _buildTableHeaderCell('品項'),
                _buildTableHeaderCell('數量'),
                _buildTableHeaderCell('月租'),
                _buildTableHeaderCell('金額'),
              ],
            ),

            // AI T8節電燈管
            _buildPaybackRow(
              'AI T8節電燈管',
              step3LightCount,
              '$lightUnitPrice/支',
              '${lightAmount.toStringAsFixed(0)}',
            ),

            // 邊緣中控網關
            _buildPaybackRow(
              '邊緣中控網關',
              gatewayCount,
              '$gatewayUnitPrice/台',
              '${gatewayAmount.toStringAsFixed(0)}',
            ),

            // 根據租賃/買斷模式顯示不同內容（版本 14.0）
            if (isRentalMode) ...[
              // 租賃模式：設備月租費
              _buildPaybackRow(
                '設備月租費',
                '',
                '',
                '$monthlyRental\$',
                isImportant: true,
              ),

              // 租賃模式：社區電費淨利(月)
              _buildPaybackRow(
                '社區電費淨利(月)',
                '',
                '',
                '${monthlySaving.toStringAsFixed(0)}\$',
                isRed: true,
                isImportant: true,
              ),

              // 租賃模式：社區電費淨利(年)
              _buildPaybackRow(
                '社區電費淨利(年)',
                '',
                '',
                '${yearlySaving.toStringAsFixed(0)}\$',
                isRed: true,
                isImportant: true,
              ),
            ] else ...[
              // 買斷模式：買斷總費用
              _buildPaybackRow(
                '買斷總費用',
                '',
                '',
                '$buyoutTotal\$',
                isImportant: true,
              ),

              // 買斷模式：攤提時間
              _buildPaybackRow(
                '攤提時間',
                '',
                '',
                '$paybackPeriod 個月',
                isRed: true,
                isImportant: true,
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// 建立費用攤提表格的資料列（黑字白底）
  static pw.TableRow _buildPaybackRow(
    String item,
    String quantity,
    String rental,
    String amount, {
    bool isRed = false,
    bool isImportant = false, // 是否為重要行（設備月租費、社區電費淨利）
  }) {
    return pw.TableRow(
      children: [
        _buildTableCell(item, isImportant: isImportant),
        _buildTableCell(quantity, isImportant: isImportant),
        _buildTableCell(rental, isImportant: isImportant),
        _buildTableCell(amount, isRed: isRed, isImportant: isImportant),
      ],
    );
  }

  /// 建立表格標頭 Cell（黑底白字）
  static pw.Widget _buildTableHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  /// 建立一般表格 Cell（黑字白底）
  static pw.Widget _buildTableCell(
    String text, {
    bool isRed = false,
    bool isImportant = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isImportant ? 14 : 12,
          fontWeight: isImportant ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isRed ? PdfColors.red : PdfColors.black,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  /// 建立第三區域：圖表（並排顯示）
  static pw.Widget _buildChartsSection(
    Uint8List? chart1Image,
    Uint8List? chart2Image,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // 圖表區域標題
        pw.Text(
          '圖表分析',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 12),

        // 兩個圖表並排顯示
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // 第一個圖表：電費估算圖表
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '電費估算圖表',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  if (chart1Image != null)
                    pw.Container(
                      height: 350,
                      child: pw.Image(
                        pw.MemoryImage(chart1Image),
                        fit: pw.BoxFit.contain,
                      ),
                    )
                  else
                    pw.Container(
                      height: 350,
                      padding: const pw.EdgeInsets.all(20),
                      alignment: pw.Alignment.center,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey400),
                      ),
                      child: pw.Text(
                        '圖表載入失敗',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            pw.SizedBox(width: 20), // 圖表之間的間距

            // 第二個圖表：費用攤提圖表
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '費用攤提圖表',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  if (chart2Image != null)
                    pw.Container(
                      height: 350,
                      child: pw.Image(
                        pw.MemoryImage(chart2Image),
                        fit: pw.BoxFit.contain,
                      ),
                    )
                  else
                    pw.Container(
                      height: 350,
                      padding: const pw.EdgeInsets.all(20),
                      alignment: pw.Alignment.center,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey400),
                      ),
                      child: pw.Text(
                        '圖表載入失敗',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 在瀏覽器中下載 PDF
  static void _downloadPdf(Uint8List pdfBytes, String projectName) {
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // 只使用日期（年-月-日），不包含時間
    final now = DateTime.now();
    final dateString =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final filename = projectName.isEmpty
        ? 'AI燈管節電效能評估_$dateString.pdf'
        : 'AI燈管節電效能評估_${projectName}_$dateString.pdf';

    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
