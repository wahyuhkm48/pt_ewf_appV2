// views/kalkulator_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/connectivity_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'emas_fisik_page.dart';
import 'konsep_transaksi_page.dart';

class KalkulatorPage extends StatelessWidget {
  /// Membuka halaman kalkulator lalu me-refresh riwayat saat user kembali
  /// (diisi MainShell._openCalculator).
  final Future<void> Function(Widget page) onOpen;

  const KalkulatorPage({super.key, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final online = context.select<ConnectivityService, bool>((n) => n.isOnline);

    return SafeArea(
      child: ListView(
        // padding bawah besar supaya isi tidak tertutup bar navigasi
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
        children: [
          Text('Kalkulator', style: AppTextStyles.h1()),
          const SizedBox(height: 4),
          Text('Pilih alat hitung yang ingin kamu pakai.', style: AppTextStyles.bodyMd()),
          const SizedBox(height: 24),
          _CalcCard(
            iconAsset: 'assets/images/icons/pivot_point.png',
            title: 'Pivot Point & Nest',
            subtitle: 'Level support, resistance, dan sinyal harian untuk Gold, Nikkei, dan Hang Seng.',
            onTap: () => onOpen(const KonsepTransaksiPage()),
          ),
          const SizedBox(height: 14),
          _CalcCard(
            iconAsset: 'assets/images/icons/emas_fisik.png',
            title: 'Emas Fisik',
            subtitle: online
                ? 'Hitung selisih harga dan estimasi keuntungan emas fisik.'
                : 'Butuh internet, belum bisa dipakai saat offline.',
            onTap: () => onOpen(const EmasFisikPage()),
          ),
        ],
      ),
    );
  }
}

class _CalcCard extends StatelessWidget {
  final String iconAsset;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CalcCard({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(iconAsset, fit: BoxFit.contain),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.labelLg()),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTextStyles.bodySm(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}