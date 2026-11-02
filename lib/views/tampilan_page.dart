// views/tampilan_page.dart
import 'package:flutter/material.dart' hide Text;
import '../widgets/app_text.dart';
import 'package:provider/provider.dart';
import '../core/theme_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TampilanPage extends StatelessWidget {
  const TampilanPage({super.key});

  static const _opsi = <(ThemeMode, IconData, String, String)>[
    (ThemeMode.light, Icons.light_mode_outlined, 'Terang', 'Tampilan terang (bawaan)'),
    (ThemeMode.dark, Icons.dark_mode_outlined, 'Gelap', 'Lebih nyaman di tempat minim cahaya'),
    (ThemeMode.system, Icons.brightness_auto_outlined, 'Ikuti sistem', 'Mengikuti pengaturan HP kamu'),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ThemeController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tampilan'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          for (final o in _opsi) ...[
            _OpsiTile(
              icon: o.$2,
              judul: o.$3,
              deskripsi: o.$4,
              selected: controller.mode == o.$1,
              onTap: () => controller.setMode(o.$1),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _OpsiTile extends StatelessWidget {
  final IconData icon;
  final String judul;
  final String deskripsi;
  final bool selected;
  final VoidCallback onTap;

  const _OpsiTile({
    required this.icon,
    required this.judul,
    required this.deskripsi,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primaryTint : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(judul, style: AppTextStyles.labelLg()),
                    const SizedBox(height: 2),
                    Text(deskripsi, style: AppTextStyles.caption()),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle_rounded, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}