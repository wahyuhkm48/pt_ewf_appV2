// views/emas_fisik_detail_page.dart
import 'package:flutter/material.dart' hide Text;
import '../widgets/app_text.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/emas_fisik_model.dart';
import '../widgets/mini_stat.dart';
import '../widgets/exportable_area.dart';
import '../l10n/app_strings.dart';

class EmasFisikDetailPage extends StatelessWidget {
  final EmasFisikModel item;
  const EmasFisikDetailPage({super.key, required this.item});

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final months = AppLang.bulan;
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final untung = item.profit >= 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    Text('Detail Emas Fisik',
                        style: AppTextStyles.h3()),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(_formatDate(item.tanggal), style: AppTextStyles.bodySm()),
              const SizedBox(height: 20),

              ExportableArea(
                namaFile: 'emas_fisik',
                judul: 'Emas Fisik',
                subjudul: _formatDate(item.tanggal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: (untung ? AppColors.success : AppColors.danger).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: untung ? AppColors.success : AppColors.danger),
                      ),
                      child: Column(
                        children: [
                          Text(untung ? 'UNTUNG' : 'RUGI',
                              style: AppTextStyles.labelBase(color: untung ? AppColors.success : AppColors.danger).copyWith(letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text(item.profit.toStringAsFixed(2),
                              style: AppTextStyles.h2(color: untung ? AppColors.success : AppColors.danger)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          MiniStat(label: 'HHB', value: item.hhb.toStringAsFixed(2)),
                          MiniStat(label: 'HHJ', value: item.hhj.toStringAsFixed(2)),
                          MiniStat(label: 'Selisih', value: item.selisih.toStringAsFixed(2)),
                          MiniStat(label: 'Berat', value: '${item.beratGram.toStringAsFixed(2)} gr'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}