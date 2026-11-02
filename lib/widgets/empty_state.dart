import 'package:flutter/material.dart' hide Text;
import '../widgets/app_text.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Tampilan kosong (belum ada data) yang dipakai di Home, History, dan Chart.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final double iconSize;
  final EdgeInsetsGeometry padding;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconSize = 40,
    this.padding = const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconSize + 32,
            height: iconSize + 32,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: iconSize, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelBase(),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption(),
            ),
          ],
        ],
      ),
    );
  }
}