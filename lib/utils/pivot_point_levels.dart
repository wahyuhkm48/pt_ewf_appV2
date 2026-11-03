// utils/pivot_point_levels.dart
import 'package:flutter/material.dart';
import '../models/pivot_point_model.dart';
import '../theme/app_colors.dart';
import '../widgets/level_row.dart';

List<Widget> buildPivotLevelRows(PivotPointModel result) {
  final labels = ['R4', 'R3', 'R2', 'R1', 'PP', 'S1', 'S2', 'S3', 'S4'];
  final values = result.levelsTopToBottom;
  final rows = <Widget>[];

  for (var i = 0; i < labels.length; i++) {
    final isPP = labels[i] == 'PP';
    final isResistance = labels[i].startsWith('R');
    final color = isPP ? AppColors.primary : (isResistance ? AppColors.success : AppColors.danger);

    rows.add(LevelRow(
      label: isPP
          ? 'Pivot Point (PP)'
          : '${isResistance ? 'Resistance' : 'Support'} ${labels[i].substring(1)} (${labels[i]})',
      value: values[i].toStringAsFixed(2),
      color: color,
      isPivot: isPP,
      isFirst: i == 0,
    ));

    if (i < labels.length - 1) {
      final mid = (values[i] + values[i + 1]) / 2;
      rows.add(LevelRow(
        label: 'Midpoint (${labels[i]}-${labels[i + 1]})',
        value: mid.toStringAsFixed(2),
        color: AppColors.textSecondary,
        isMidpoint: true,
      ));
    }
  }
  return rows;
}