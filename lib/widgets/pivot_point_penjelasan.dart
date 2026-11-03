import 'package:flutter/material.dart' hide Text;
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_text.dart';

/// Tabel penjelasan singkat Pivot Point. Hanya dipakai di PNG ekspor.
class PivotPointPenjelasanTable extends StatelessWidget {
  const PivotPointPenjelasanTable({super.key});

  // Harus persis sama dengan kunci di l10n/en_part1.dart supaya ikut diterjemahkan.
  static const _teks =
      'Pivot Point adalah harga wajar atau harga pasaran, untuk menentukan aksi beli dan jual '
      'yang mengacu pada harga pembukaan (open).';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text('Penjelasan Pivot Point', style: AppTextStyles.labelMd()),
          ),
          Divider(height: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(_teks, style: AppTextStyles.bodySm().copyWith(height: 1.5)),
          ),
        ],
      ),
    );
  }
}