// widgets/exportable_area.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/png_exporter.dart';
import '../utils/watermark_config.dart';
import 'watermark_overlay.dart';

const _bulan = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];

String formatTanggalIndo(DateTime? d) {
  if (d == null) return '-';
  return '${d.day} ${_bulan[d.month - 1]} ${d.year}';
}

String _dua(int v) => v.toString().padLeft(2, '0');

class ExportableArea extends StatefulWidget {
  /// Awal nama file, mis. 'pivot_gold'. Stempel waktu ditambahkan otomatis.
  final String namaFile;
  final String judul;      // mis. 'Pivot Point'
  final String? subjudul;  // mis. 'Gold • 20 Okt 2026'
  final Widget child;

  const ExportableArea({
    super.key,
    required this.namaFile,
    required this.judul,
    this.subjudul,
    required this.child,
  });

  @override
  State<ExportableArea> createState() => _ExportableAreaState();
}

class _ExportableAreaState extends State<ExportableArea> {
  final _boundaryKey = GlobalKey();
  bool _capturing = false; // true hanya sebentar: menampilkan header/footer khusus PNG
  bool _busy = false;

  Future<void> _export() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final bytes = await _capture();
      final now = DateTime.now();
      final stamp = '${now.year}${_dua(now.month)}${_dua(now.day)}_${_dua(now.hour)}${_dua(now.minute)}';
      await PngExporter.share(
        bytes,
        namaFile: '${widget.namaFile}_$stamp',
        subject: widget.judul,
        text: '${widget.judul} - Trust by Equityworld',
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengekspor gambar. Coba lagi.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<Uint8List> _capture() async {
    // Pastikan logo watermark sudah ter-decode sebelum di-capture
    await precacheImage(const AssetImage(WatermarkConfig.logoAsset), context);

    setState(() => _capturing = true);
    try {
      await WidgetsBinding.instance.endOfFrame; // tunggu header/footer/watermark tergambar
      return await PngExporter.capture(_boundaryKey);
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  List<Widget> _header() => [
        Text('Trust by Equityworld', style: AppTextStyles.labelMd(color: AppColors.primary)),
        const SizedBox(height: 4),
        Text(widget.judul, style: AppTextStyles.h2()),
        if (widget.subjudul != null) ...[
          const SizedBox(height: 2),
          Text(widget.subjudul!, style: AppTextStyles.bodySm(color: AppColors.textSecondary)),
        ],
        const SizedBox(height: 12),
        const Divider(color: AppColors.divider, height: 1),
        const SizedBox(height: 16),
      ];

  List<Widget> _footer() {
    final now = DateTime.now();
    return [
      const SizedBox(height: 16),
      const Divider(color: AppColors.divider, height: 1),
      const SizedBox(height: 8),
      Text(
        'Dibuat ${formatTanggalIndo(now)} ${_dua(now.hour)}:${_dua(now.minute)} • Trust by Equityworld',
        style: AppTextStyles.caption(color: AppColors.textSecondary),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RepaintBoundary(
          key: _boundaryKey,
          child: Container(
            width: double.infinity,
            color: AppColors.background, // tanpa ini PNG-nya transparan
            child: Stack(
              children: [
                Padding(
                  padding: _capturing ? const EdgeInsets.all(20) : EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_capturing) ..._header(),
                      widget.child,
                      if (_capturing) ..._footer(),
                    ],
                  ),
                ),
                // Watermark hanya muncul saat ekspor, tidak tampil di layar biasa
                if (_capturing) const Positioned.fill(child: WatermarkOverlay()),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _busy ? null : _export,
          icon: _busy
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
              : const Icon(Icons.ios_share_rounded, size: 18),
          label: Text('Ekspor PNG', style: AppTextStyles.labelLg(color: AppColors.primary)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ],
    );
  }
}