// widgets/riwayat_button.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Tombol kotak membulat "Riwayat" untuk header halaman hitung.
class RiwayatButton extends StatelessWidget {
  final VoidCallback onTap;
  const RiwayatButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryTint,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.history_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text('Riwayat', style: AppTextStyles.labelSm(color: AppColors.primary)),
            ],
          ),
        ),
      ),
    );
  }
}