// widgets/action_badge.dart
import 'package:flutter/material.dart' hide Text;
import '../widgets/app_text.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ActionBadge extends StatelessWidget {
  final String action; // 'buy' | 'sell' | 'netral'
  final bool compact;
  const ActionBadge({super.key, required this.action, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final isBuy = action == 'buy';
    final isSell = action == 'sell';
    final color = isBuy ? AppColors.success : (isSell ? AppColors.danger : AppColors.textSecondary);
    final label = isBuy ? 'BUY' : (isSell ? 'SELL' : 'NETRAL');
    final icon = isBuy ? Icons.trending_up_rounded : (isSell ? Icons.trending_down_rounded : Icons.remove_rounded);

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 4),
            Text(label, style: AppTextStyles.micro(color: color).copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.labelLg(color: color).copyWith(letterSpacing: 1)),
        ],
      ),
    );
  }
}