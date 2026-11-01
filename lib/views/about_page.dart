// views/about_page.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const _features = <(IconData, String, String)>[
    (Icons.stacked_line_chart_rounded, 'Pivot Point', 'Hitung titik pivot, level support dan resistance, serta indikator buy atau sell dari data pasar atau input manual.'),
    (Icons.insights_rounded, 'Nest', 'Sinyal harian dari perbandingan Close kemarin dan Open hari ini.'),
    (Icons.savings_outlined, 'Emas Fisik', 'Hitung selisih harga, berat emas, dan estimasi keuntungan dari harga beli, harga jual, kurs, dan modal.'),
    (Icons.show_chart_rounded, 'Chart & Data Historis', 'Grafik interaktif Gold, Nikkei (JPK), dan Hang Seng (HKK) dengan data historis Open, High, Low, Close yang bisa diunduh ke Pdf.'),
    (Icons.history_rounded, 'Riwayat', 'Simpan dan lihat kembali hasil perhitungan Pivot Point, Nest, dan Emas Fisik.'),
    (Icons.newspaper_rounded, 'Berita', 'Berita pasar dan ekonomi terbaru dari CNBC dan Reuters.'),
  ];

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Saya'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ===== Konten =====
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  children: [
                    // Logo
                    Container(
                      width: 100,
                      height: 100,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo_trustByEwf.png',
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.public, color: AppColors.primary, size: 48),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nama
                    Text(
                      'Trust by Equityworld',
                      style: AppTextStyles.h2(color: AppColors.primary)
                          .copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Trade with Trust',
                      style: AppTextStyles.bodySm(),
                    ),
                    const SizedBox(height: 28),

                    // Tentang aplikasi
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Tentang Aplikasi',
                        style: AppTextStyles.labelLg(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Trust by Equityworld adalah aplikasi pendamping perdagangan berjangka komoditi. '
                      'Kami berizin resmi BAPPEBTI sejak 2005 dan berkomitmen menjadi partner '
                      'terpercaya Anda. Aplikasi ini membantu Anda memantau grafik dan berita pasar, '
                      'menghitung Pivot Point, Nest, dan emas fisik, serta menyimpan riwayat '
                      'perhitungan dengan cara yang sederhana.',
                      textAlign: TextAlign.justify,
                      style: AppTextStyles.bodySm().copyWith(height: 1.6),
                    ),
                    const SizedBox(height: 24),

                    // Fitur
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Fitur Utama',
                        style: AppTextStyles.labelLg(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._features.map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _FeatureRow(icon: f.$1, title: f.$2, desc: f.$3),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Divider(color: AppColors.divider),
                    const SizedBox(height: 20),

                    // ===== Copyright =====
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 240),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          'assets/images/lowprofile-highprofit.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '© $year Trust by Equityworld.\nAll rights reserved.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption().copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _FeatureRow({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelBase()),
                const SizedBox(height: 2),
                Text(desc, style: AppTextStyles.caption().copyWith(height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}