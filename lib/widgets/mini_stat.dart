// widgets/mini_stat.dart
import 'package:flutter/material.dart' hide Text;
import '../widgets/app_text.dart';
import '../theme/app_text_styles.dart';

class MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const MiniStat({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.micro()),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.labelMd()),
        ],
      ),
    );
  }
}