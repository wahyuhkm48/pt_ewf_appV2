// widgets/panduan_dialog.dart
import 'package:flutter/material.dart' hide Text;
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_text.dart';

// ============================================================
// Kartu pembuka + dialog
// ============================================================

/// Kartu "Apa itu ...?" di halaman kalkulator. Diketuk untuk membuka dialog panduan.
class PanduanBukaKartu extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const PanduanBukaKartu({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              const _KotakIkonInfo(),
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
              Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _KotakIkonInfo extends StatelessWidget {
  const _KotakIkonInfo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.secondaryTint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.info_outline_rounded, size: 22, color: AppColors.secondary),
    );
  }
}

Future<void> bukaPanduan(
  BuildContext context, {
  required String title,
  required String subtitle,
  required List<Widget> children,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => PanduanDialog(title: title, subtitle: subtitle, children: children),
  );
}

class PanduanDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const PanduanDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final tinggiMaks = MediaQuery.of(context).size.height * 0.85;

    return Dialog(
      backgroundColor: AppColors.background,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 640, maxHeight: tinggiMaks),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===== Header =====
            Container(
              width: double.infinity,
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(20, 16, 10, 16),
              child: Row(
                children: [
                  const _KotakIkonInfo(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTextStyles.h3()),
                        const SizedBox(height: 2),
                        Text(subtitle, style: AppTextStyles.caption()),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.divider),

            // ===== Isi =====
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              ),
            ),

            // ===== Footer =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.isDark ? AppColors.primary : AppColors.darkButtonTop,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Mengerti & Tutup', style: AppTextStyles.labelBase(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Blok isi
// ============================================================

class PanduanJudul extends StatelessWidget {
  final String text;
  const PanduanJudul(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: AppTextStyles.labelLg()),
      );
}

class PanduanParagraf extends StatelessWidget {
  final String text;
  const PanduanParagraf(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTextStyles.bodyMd().copyWith(height: 1.55, color: AppColors.textPrimary),
      );
}

/// Susunan kartu: 2 kolom di layar lebar, 1 kolom di layar HP.
class PanduanGrid extends StatelessWidget {
  final List<Widget> children;
  const PanduanGrid({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final duaKolom = c.maxWidth >= 520;
        final lebar = duaKolom ? (c.maxWidth - 12) / 2 : c.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final w in children) SizedBox(width: lebar, child: w),
          ],
        );
      },
    );
  }
}

/// Kartu rumus / aturan.
/// [warna] mewarnai seluruh kartu (hijau/merah/oranye). [sorot] menandai kartu utama.
/// [chip] mengganti warna kotak rumus.
class RumusKartu extends StatelessWidget {
  final String judul;
  final String rumus;
  final String deskripsi;
  final Color? warna;
  final Color? chip;
  final bool sorot;

  const RumusKartu({
    super.key,
    required this.judul,
    required this.rumus,
    required this.deskripsi,
    this.warna,
    this.chip,
    this.sorot = false,
  });

  @override
  Widget build(BuildContext context) {
    final aksen = chip ?? warna ?? AppColors.secondary;
    final latar = warna != null
        ? warna!.withValues(alpha: 0.08)
        : (sorot ? AppColors.secondaryTint : AppColors.surface);
    final garis = warna != null
        ? warna!.withValues(alpha: 0.4)
        : (sorot ? AppColors.secondary.withValues(alpha: 0.5) : AppColors.divider);
    final warnaJudul = warna ?? (sorot ? AppColors.secondary : AppColors.textPrimary);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: latar,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: garis),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(judul, style: AppTextStyles.labelBase(color: warnaJudul)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: aksen.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              rumus,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: aksen,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(deskripsi, style: AppTextStyles.caption().copyWith(height: 1.45)),
        ],
      ),
    );
  }
}

/// Kartu "1 troy ounce = 31.1 gram" di panduan Emas Fisik.
class PanduanKonversiKartu extends StatelessWidget {
  final String label;
  final String nilai;
  final String deskripsi;

  const PanduanKonversiKartu({
    super.key,
    required this.label,
    required this.nilai,
    required this.deskripsi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelSm(color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(nilai, style: AppTextStyles.h3()),
          const SizedBox(height: 2),
          Text(deskripsi, style: AppTextStyles.caption()),
        ],
      ),
    );
  }
}

// ============================================================
// Isi panduan
// ============================================================

void bukaPanduanPivotPoint(BuildContext context) {
  bukaPanduan(
    context,
    title: 'Apa itu Pivot Point?',
    subtitle: 'Panduan & Rumus Perhitungan Level',
    children: [
      const PanduanJudul('Pengertian Pivot Point'),
      const PanduanParagraf(
        'Pivot Point adalah harga wajar atau harga pasaran, untuk menentukan aksi beli dan jual '
        'yang mengacu pada harga pembukaan (open).',
      ),
      const SizedBox(height: 22),
      const PanduanJudul('Rumus Perhitungan Level Pivot Point'),
      PanduanGrid(
        children: const [
          RumusKartu(
            sorot: true,
            judul: '1. Pivot Point (PP)',
            rumus: '(High + Low + Close) ÷ 3',
            deskripsi: 'Titik tumpu harga wajar harian sebagai patokan penentu area bullish atau bearish.',
          ),
          RumusKartu(
            judul: '2. Range Harian',
            rumus: 'High - Low',
            deskripsi: 'Jarak rentang pergerakan volatilitas harga tertinggi dan terendah periode sebelumnya.',
          ),
          RumusKartu(
            judul: '3. Resistance 1 (R1) & 2 (R2)',
            rumus: 'R1 = (2 × PP) - Low | R2 = PP + Range',
            deskripsi: 'Batas tahanan harga atas pertama dan kedua untuk target profit atau area jenuh beli.',
          ),
          RumusKartu(
            judul: '4. Resistance 3 (R3) & 4 (R4)',
            rumus: 'R3 = PP + (2 × Range) | R4 = PP + (3 × Range)',
            deskripsi: 'Tingkat batas atas ekstrim pergerakan tren pasar lanjutan yang sangat kuat.',
          ),
          RumusKartu(
            judul: '5. Support 1 (S1) & 2 (S2)',
            rumus: 'S1 = (2 × PP) - High | S2 = PP - Range',
            deskripsi: 'Batas tahanan harga bawah pertama dan kedua untuk titik beli atau area pantulan harga.',
          ),
          RumusKartu(
            judul: '6. Support 3 (S3) & 4 (S4)',
            rumus: 'S3 = PP - (2 × Range) | S4 = PP - (3 × Range)',
            deskripsi: 'Tingkat batas bawah ekstrim ketika pasar mengalami tekanan jual yang sangat kuat.',
          ),
        ],
      ),
    ],
  );
}

void bukaPanduanNest(BuildContext context) {
  bukaPanduan(
    context,
    title: 'Apa itu Konsep Nest?',
    subtitle: 'Panduan & Aturan Analisa Follow the Trend',
    children: [
      const PanduanJudul('Pengertian Konsep Nest'),
      const PanduanParagraf(
        'Konsep Nest adalah konsep follow the trend yang mengacu pada harga penutupan kemarin '
        'dibandingkan dengan harga pembukaan kemarin untuk menentukan arah transaksi selanjutnya.',
      ),
      const SizedBox(height: 22),
      const PanduanJudul('Aturan Penentuan Aksi'),
      RumusKartu(
        warna: AppColors.success,
        judul: '1. BELI',
        rumus: 'Harga Close > Harga Open',
        deskripsi: 'Ketika harga penutupan kemarin lebih tinggi dari harga pembukaan kemarin, '
            'maka pasar cenderung memiliki peluang untuk melanjutkan kenaikan.',
      ),
      const SizedBox(height: 12),
      RumusKartu(
        warna: AppColors.danger,
        judul: '2. JUAL',
        rumus: 'Harga Close < Harga Open',
        deskripsi: 'Ketika harga penutupan kemarin lebih rendah dari harga pembukaan kemarin, '
            'maka pasar cenderung memiliki peluang untuk melanjutkan penurunan.',
      ),
      const SizedBox(height: 12),
      const RumusKartu(
        judul: '3. NETRAL',
        rumus: 'Harga Close = Harga Open',
        deskripsi: 'Ketika harga penutupan kemarin sama dengan harga pembukaan kemarin, '
            'pasar memiliki kecenderungan bergerak normal.',
      ),
    ],
  );
}

void bukaPanduanEmasFisik(BuildContext context) {
  bukaPanduan(
    context,
    title: 'Apa itu Emas Fisik?',
    subtitle: 'Panduan & Rumus Simulasi Perhitungan',
    children: [
      const PanduanJudul('Pengertian Emas Fisik'),
      const PanduanParagraf(
        'Emas yang memiliki bentuk nyata dan bisa dipegang langsung, seperti emas batangan atau perhiasan.',
      ),
      const SizedBox(height: 22),
      const PanduanJudul('Ketentuan Konversi'),
      const PanduanKonversiKartu(
        label: '1 TROY OUNCE (TOZ)',
        nilai: '31.1 gram',
        deskripsi: 'Standar bobot konversi emas internasional per troy ounce.',
      ),
      const SizedBox(height: 22),
      const PanduanJudul('Rumus Perhitungan Emas Fisik'),
      PanduanGrid(
        children: [
          RumusKartu(
            chip: AppColors.primaryDark,
            judul: '1. Harga Beli / Gram',
            rumus: '(Harga Beli Point × Kurs USD/IDR) ÷ 31.1',
            deskripsi: 'Konversi harga beli emas internasional per troy ounce (31.1 gram) ke harga rupiah per gram.',
          ),
          RumusKartu(
            chip: AppColors.primaryDark,
            judul: '2. Harga Jual / Gram',
            rumus: '(Harga Jual Point × Kurs USD/IDR) ÷ 31.1',
            deskripsi: 'Konversi harga jual emas internasional per troy ounce (31.1 gram) ke harga rupiah per gram.',
          ),
          RumusKartu(
            chip: AppColors.primaryDark,
            judul: '3. Selisih / Gram',
            rumus: 'Harga Jual / Gram - Harga Beli / Gram',
            deskripsi: 'Selisih keuntungan atau kerugian per 1 gram emas fisik.',
          ),
          RumusKartu(
            chip: AppColors.primaryDark,
            judul: '4. Jumlah Emas Diperoleh (Gram)',
            rumus: 'Alokasi Modal ÷ Harga Beli / Gram',
            deskripsi: 'Total bobot gram emas fisik yang didapatkan dari modal yang dibelanjakan.',
          ),
          RumusKartu(
            warna: AppColors.primary,
            chip: AppColors.primaryDark,
            judul: '5. Total Keuntungan / Kerugian',
            rumus: 'Selisih / Gram × Jumlah Emas',
            deskripsi: 'Total keuntungan atau kerugian dari seluruh emas fisik yang dibeli.',
          ),
        ],
      ),
    ],
  );
}