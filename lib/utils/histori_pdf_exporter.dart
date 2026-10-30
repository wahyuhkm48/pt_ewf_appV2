// utils/histori_pdf_exporter.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'watermark_config.dart';
import '../models/histori_data_model.dart';

class HistoriPdfExporter {
  static const _bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

  static const _primary = PdfColor.fromInt(0xFFEC7013);
  static const _primaryTint = PdfColor.fromInt(0xFFFFF1E6);
  static const _divider = PdfColor.fromInt(0xFFE5E5E5);
  static const _textSecondary = PdfColor.fromInt(0xFF8C8A87);

  /// Membuat file .pdf dari [data] lalu membuka share sheet
  /// (user bisa "Simpan ke File", Google Drive, WhatsApp, dll).
  static Future<void> export({
    required String namaProduk,
    required List<HistoriDataModel> data,
  }) async {
    final doc = pw.Document(
      title: 'Data Historis $namaProduk',
      author: 'Trust by Equityworld',
    );

    // Logo watermark. Kalau gagal dimuat, watermark tetap tampil tanpa logo.
    pw.MemoryImage? logo;
    try {
      final data = await rootBundle.load(WatermarkConfig.logoAsset);
      logo = pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {
      logo = null;
    }

    final tanggalData = data.map((d) => d.tanggal).toList()..sort();
    final rentang = tanggalData.isEmpty
        ? '-'
        : '${_formatTanggal(tanggalData.first)} - ${_formatTanggal(tanggalData.last)}';

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(36, 40, 36, 40),
          buildForeground: (_) => _watermark(logo),
        ),
        header: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Data Historis $namaProduk',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: _primary),
            ),
            pw.SizedBox(height: 4),
            pw.Text('Rentang data: $rentang',
                style: const pw.TextStyle(fontSize: 10, color: _textSecondary)),
            pw.Text('Dicetak: ${_formatTanggal(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10, color: _textSecondary)),
            pw.SizedBox(height: 12),
          ],
        ),
        footer: (ctx) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Trust by Equityworld',
                style: const pw.TextStyle(fontSize: 9, color: _textSecondary)),
            pw.Text('Halaman ${ctx.pageNumber} dari ${ctx.pagesCount}',
                style: const pw.TextStyle(fontSize: 9, color: _textSecondary)),
          ],
        ),
        build: (_) => [
          pw.TableHelper.fromTextArray(
            headers: const ['Tanggal', 'Open', 'High', 'Low', 'Close'],
            data: data
                .map((d) => [
                      _formatTanggal(d.tanggal),
                      _angka(d.open),
                      _angka(d.high),
                      _angka(d.low),
                      _angka(d.close),
                    ])
                .toList(),
            headerStyle: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: _primary),
            cellStyle: const pw.TextStyle(fontSize: 10),
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerRight,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
            },
            border: const pw.TableBorder(
              horizontalInside: pw.BorderSide(color: _divider, width: 0.5),
              bottom: pw.BorderSide(color: _divider, width: 0.5),
            ),
            oddRowDecoration: const pw.BoxDecoration(color: _primaryTint),
          ),
        ],
      ),
    );

    final bytes = await doc.save();

    final dir = await getTemporaryDirectory();
    final namaFile = 'histori_${namaProduk.toLowerCase()}_${_stamp(DateTime.now())}.pdf';
    final file = File('${dir.path}/$namaFile');
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: 'Data Historis $namaProduk',
      text: 'Data Historis $namaProduk - Trust by Equityworld',
    );
  }

    /// Watermark logo + teks yang berulang dan miring di setiap halaman.
  static pw.Widget _watermark(pw.MemoryImage? logo) {
    const tileW = 200.0;
    const tileH = 120.0;
    const cols = 4;
    const rows = 8;

    final tiles = <pw.Widget>[];
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final dx = c * tileW - 40 + (r.isOdd ? tileW / 2 : 0);
        tiles.add(
          pw.Positioned(
            left: dx,
            top: r * tileH,
            child: pw.Transform.rotate(
              angle: -0.5,
              child: pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  if (logo != null) pw.Image(logo, height: 26),
                  if (logo != null) pw.SizedBox(width: 8),
                  pw.Text(
                    WatermarkConfig.teks,
                    style: pw.TextStyle(
                      fontSize: 15,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return pw.FullPage(
      ignoreMargins: true,
      child: pw.Opacity(
        opacity: 0.15,
        child: pw.Stack(overflow: pw.Overflow.clip, children: tiles),
      ),
    );
  }

  static String _two(int v) => v.toString().padLeft(2, '0');

  static String _formatTanggal(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';

  static String _stamp(DateTime d) => '${d.year}${_two(d.month)}${_two(d.day)}';

  /// 2 desimal dengan pemisah ribuan (koma), mis. 2,345.67
  static String _angka(double v) {
    final s = v.toStringAsFixed(2);
    final parts = s.split('.');
    final intPart = parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
    return '$intPart.${parts[1]}';
  }
}