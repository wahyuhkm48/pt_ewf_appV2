// widgets/hasil_disclaimer.dart
import 'package:flutter/material.dart' hide Text;
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_text.dart';

/// Catatan bahwa indikator di bawahnya adalah hasil perhitungan.
class HasilDisclaimer extends StatelessWidget {
  const HasilDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Indikator di bawah adalah hasil perhitungan dari data harga, '
              'bukan saran investasi atau jaminan keuntungan.',
              style: AppTextStyles.caption().copyWith(
                height: 1.45,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}