// views/kalkulator_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/connectivity_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'emas_fisik_page.dart';
import 'nest_page.dart';
import 'pivot_point_page.dart';

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
          _KonsepTransaksiCard(
            onOpenPivot: () => onOpen(const PivotPointPage()),
            onOpenNest: () => onOpen(const NestPage()),
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

/// Kartu "Konsep Transaksi": ketuk untuk membuka dropdown berisi Pivot Point dan Nest.
class _KonsepTransaksiCard extends StatefulWidget {
  final VoidCallback onOpenPivot;
  final VoidCallback onOpenNest;

  const _KonsepTransaksiCard({required this.onOpenPivot, required this.onOpenNest});

  @override
  State<_KonsepTransaksiCard> createState() => _KonsepTransaksiCardState();
}

class _KonsepTransaksiCardState extends State<_KonsepTransaksiCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
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
                    child: Image.asset('assets/images/icons/pivot_point.png', fit: BoxFit.contain),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Konsep Transaksi', style: AppTextStyles.labelLg()),
                        const SizedBox(height: 4),
                        Text(
                          'Pivot Point dan Nest untuk Gold, Nikkei, dan Hang Seng.',
                          style: AppTextStyles.bodySm(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Column(
                    children: [
                      const Divider(height: 1, color: AppColors.divider),
                      _SubItem(
                        iconAsset: 'assets/images/welcome/pivot_point.webp',
                        title: 'Pivot Point',
                        subtitle: 'Level support, resistance, dan sinyal buy atau sell.',
                        onTap: widget.onOpenPivot,
                      ),
                      _SubItem(
                        iconAsset: 'assets/images/welcome/nest.webp',
                        title: 'Nest',
                        subtitle: 'Sinyal harian dari Close kemarin dan Open hari ini.',
                        onTap: widget.onOpenNest,
                      ),
                      const SizedBox(height: 4),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _SubItem extends StatelessWidget {
  final String iconAsset;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SubItem({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 12, 16, 12),
        child: Row(
          children: [
            Image.asset(iconAsset, width: 40, height: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.labelBase()),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.caption()),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
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