// widgets/level_row.dart
import 'package:flutter/material.dart' hide Text;
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_text.dart';

class LevelRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color; // warna teks label dan angka
  final bool isMidpoint;
  final bool isPivot; // baris Pivot Point (PP): paling menonjol
  final bool isFirst;

  const LevelRow({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.isMidpoint = false,
    this.isPivot = false,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isPivot) return _buildPivot();
    if (isMidpoint) return _buildMidpoint();
    return _buildLevel();
  }

  // Resistance dan Support
  Widget _buildLevel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        border: isFirst ? null : Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppTextStyles.labelBase(color: color)),
          ),
          Text(
            value,
            style: AppTextStyles.labelLg(color: color).copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Midpoint: lebih kecil, miring, dan menjorok sedikit
  Widget _buildMidpoint() {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 9, 16, 9),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.caption().copyWith(fontStyle: FontStyle.italic),
            ),
          ),
          Text(value, style: AppTextStyles.bodySm()),
        ],
      ),
    );
  }

  // Pivot Point: tujuan perhitungan, jadi dibuat paling menonjol
  Widget _buildPivot() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        border: Border(
          left: BorderSide(color: color, width: 5),
          top: BorderSide(color: color.withValues(alpha: 0.35), width: 1),
          bottom: BorderSide(color: color.withValues(alpha: 0.35), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppTextStyles.labelLg(color: color)),
          ),
          Text(
            value,
            style: AppTextStyles.h2().copyWith(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}