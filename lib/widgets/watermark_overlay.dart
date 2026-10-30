// widgets/watermark_overlay.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/watermark_config.dart';

/// Watermark logo + teks yang berulang dan miring.
/// Dipasang di atas konten, hanya saat ekspor PNG.
class WatermarkOverlay extends StatelessWidget {
  const WatermarkOverlay({super.key});

  static const double _tileW = 220;
  static const double _tileH = 110;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, c) {
            // Area dibuat lebih besar dari gambar supaya setelah diputar
            // tidak ada sudut yang kosong.
            final side = (c.maxWidth > c.maxHeight ? c.maxWidth : c.maxHeight) * 1.6;
            final cols = (side / _tileW).ceil() + 1;
            final rows = (side / _tileH).ceil() + 1;

            final tiles = <Widget>[];
            for (var r = 0; r < rows; r++) {
              for (var col = 0; col < cols; col++) {
                // Baris genap-ganjil digeser setengah supaya polanya selang-seling
                final dx = col * _tileW + (r.isOdd ? _tileW / 2 : 0);
                tiles.add(Positioned(
                  left: dx,
                  top: r * _tileH,
                  width: _tileW,
                  height: _tileH,
                  child: const Center(child: _WatermarkTile()),
                ));
              }
            }

            return OverflowBox(
              minWidth: side,
              maxWidth: side,
              minHeight: side,
              maxHeight: side,
              child: Opacity(
                opacity: 0.15,
                child: Transform.rotate(
                  angle: -0.5,
                  child: Stack(clipBehavior: Clip.none, children: tiles),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WatermarkTile extends StatelessWidget {
  const _WatermarkTile();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(WatermarkConfig.logoAsset, height: 28),
        const SizedBox(width: 8),
        const Text(
          WatermarkConfig.teks,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}