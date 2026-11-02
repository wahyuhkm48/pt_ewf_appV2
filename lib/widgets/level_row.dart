// widgets/level_row.dart
import 'package:flutter/material.dart' hide Text;
import '../widgets/app_text.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class LevelRow extends StatelessWidget {
  final String label;
  final String value;
  final Color dotColor;
  final bool isMidpoint;
  final bool isFirst;

  const LevelRow({
    super.key,
    required this.label,
    required this.value,
    required this.dotColor,
    this.isMidpoint = false,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        border: isFirst ? null : Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: isMidpoint ? AppTextStyles.caption().copyWith(fontStyle: FontStyle.italic) : AppTextStyles.labelBase(),
            ),
          ),
          Text(
            value,
            style: isMidpoint ? AppTextStyles.bodySm() : AppTextStyles.labelLg().copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}