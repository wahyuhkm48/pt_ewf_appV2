// views/nest_detail_page.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/nest_model.dart';
import '../widgets/action_badge.dart';
import '../widgets/mini_stat.dart';
import '../widgets/exportable_area.dart';
import '../utils/asset_labels.dart';

class NestDetailPage extends StatelessWidget {
  final NestModel item;
  const NestDetailPage({super.key, required this.item});

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
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
                        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    Text('Detail Nest', style: AppTextStyles.h3()),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text('${assetLabel(item.asset)} • ${_formatDate(item.tanggal)}',
                  style: AppTextStyles.bodySm()),
              const SizedBox(height: 20),

              ExportableArea(
                namaFile: 'nest_${item.asset}',
                judul: 'Nest',
                subjudul: '${assetLabel(item.asset)} • ${_formatDate(item.tanggal)}',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          MiniStat(label: 'Open (Hari ini)', value: item.open != null ? item.open!.toStringAsFixed(2) : '-'),
                          MiniStat(label: 'Close (Kemarin)', value: item.close.toStringAsFixed(2)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    ActionBadge(action: item.action),
                    const SizedBox(height: 16),
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