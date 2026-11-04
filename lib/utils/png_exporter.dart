// utils/png_exporter.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PngExporter {
  /// Sisi terpanjang gambar dibatasi supaya tidak melewati batas tekstur GPU
  /// (banyak HP Android hanya kuat sekitar 4096 px).
  static const double _maxSidePx = 4096;

  static Future<Uint8List> capture(GlobalKey key, {double pixelRatio = 3}) async {
    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw Exception('Area hasil belum siap diekspor.');
    }

    // Tunggu sampai benar-benar selesai digambar (loop, bukan sekali saja).
    // Di release, debugNeedsPaint selalu false jadi loop ini langsung lewat.
    var tries = 0;
    while (boundary.debugNeedsPaint && tries++ < 10) {
      await Future.delayed(const Duration(milliseconds: 20));
    }

    // Turunkan pixelRatio otomatis kalau areanya panjang.
    final longest = boundary.size.longestSide;
    final ratio =
        (longest * pixelRatio > _maxSidePx) ? _maxSidePx / longest : pixelRatio;

    ui.Image? image;
    try {
      image = await boundary.toImage(pixelRatio: ratio);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) {
        throw Exception('Gagal membuat gambar.');
      }
      return data.buffer.asUint8List();
    } finally {
      image?.dispose();
    }
  }

  static Future<void> share(
    Uint8List bytes, {
    required String namaFile,
    String? subject,
    String? text,
    Rect? sharePositionOrigin, // wajib di iPad
  }) async {
    final dir = await getTemporaryDirectory();
    final aman = namaFile.replaceAll(RegExp(r'[^\w\-.]'), '_');
    final file = File('${dir.path}/$aman.png');
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'image/png')],
      subject: subject,
      text: text,
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}