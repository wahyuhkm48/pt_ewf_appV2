// lib/widgets/history_tiles.dart
// Tile ini DIPINDAH dari history_page.dart (isinya sama, hanya nama jadi public).
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/pivot_point_model.dart';
import '../models/nest_model.dart';
import '../models/emas_fisik_model.dart';
import '../utils/asset_labels.dart';
import 'action_badge.dart';

class PivotHistoryTile extends StatelessWidget {
  final PivotPointModel item;
  final VoidCallback onTap;
  const PivotHistoryTile({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tanggal = item.tanggal;
    final tanggalStr = tanggal != null
        ? '${tanggal.day.toString().padLeft(2, '0')}/${tanggal.month.toString().padLeft(2, '0')}/${tanggal.year}'
        : '-';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Image.asset('assets/images/welcome/pivot_point.webp', width: 42, height: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pivot Point: ${item.pivotPoint.toStringAsFixed(2)}',
                      style: AppTextStyles.labelBase()),
                  const SizedBox(height: 2),
                  Text('${assetLabel(item.asset)} • $tanggalStr',
                      style: AppTextStyles.caption()),
                ],
              ),
            ),
            if (item.action != null) ...[
              ActionBadge(action: item.action!, compact: true),
              const SizedBox(width: 4),
            ],
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class NestHistoryTile extends StatelessWidget {
  final NestModel item;
  final VoidCallback onTap;
  const NestHistoryTile({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tanggal = item.tanggal;
    final tanggalStr = tanggal != null
        ? '${tanggal.day.toString().padLeft(2, '0')}/${tanggal.month.toString().padLeft(2, '0')}/${tanggal.year}'
        : '-';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Image.asset('assets/images/welcome/nest.webp', width: 42, height: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nest',
                      style: AppTextStyles.labelBase()),
                  const SizedBox(height: 2),
                  Text('${assetLabel(item.asset)} • $tanggalStr',
                      style: AppTextStyles.caption()),
                ],
              ),
            ),
            ActionBadge(action: item.action, compact: true),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class EmasHistoryTile extends StatelessWidget {
  final EmasFisikModel item;
  final VoidCallback onTap;
  const EmasHistoryTile({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tanggal = item.tanggal;
    final tanggalStr = tanggal != null
        ? '${tanggal.day.toString().padLeft(2, '0')}/${tanggal.month.toString().padLeft(2, '0')}/${tanggal.year}'
        : '-';
    final untung = item.profit >= 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Image.asset('assets/images/welcome/emas_fisik.webp', width: 42, height: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Untung/Rugi : ${item.profit.toStringAsFixed(2)}',
                      style: AppTextStyles.labelBase(color: untung ? AppColors.success : AppColors.danger)),
                  const SizedBox(height: 2),
                  Text('${item.beratGram.toStringAsFixed(2)} gram • $tanggalStr',
                      style: AppTextStyles.caption()),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}