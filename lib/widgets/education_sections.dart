// widgets/education_sections.dart
import 'package:flutter/material.dart' hide Text;
import 'panduan_dialog.dart';
import 'app_text.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// ============================================================
// Building blocks
// ============================================================

/// Kartu penjelasan yang bisa dibuka-tutup.
class ExplainCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool initiallyExpanded;

  const ExplainCard({
    super.key,
    required this.title,
    required this.children,
    this.icon = Icons.lightbulb_outline_rounded,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          leading: Icon(icon, color: AppColors.primary),
          title: Text(
            title,
            style: AppTextStyles.labelBase(),
          ),
          children: children,
        ),
      ),
    );
  }
}

/// Kartu "Kenapa hasilnya BUY/SELL?" berisi alasan dengan angka nyata dari hasil hitung.
class _WhyCard extends StatelessWidget {
  final String action; // buy | sell | netral
  final String headline;
  final String detail;
  const _WhyCard({required this.action, required this.headline, required this.detail});

  @override
  Widget build(BuildContext context) {
    final isBuy = action == 'buy';
    final isSell = action == 'sell';
    final color = isBuy ? AppColors.success : (isSell ? AppColors.danger : AppColors.textSecondary);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline_rounded, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(headline,
                    style: AppTextStyles.labelBase(color: color)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(detail,
              style: AppTextStyles.bodySm(color: AppColors.textPrimary).copyWith(height: 1.5)),
        ],
      ),
    );
  }
}

String _n(double v) => v.toStringAsFixed(2);

String _rp(double v) {
  final s = v.abs().round().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return '${v < 0 ? '-' : ''}Rp $b';
}

// ============================================================
// PIVOT POINT
// ============================================================

class PivotPointExplainer extends StatelessWidget {
  const PivotPointExplainer({super.key});

  @override
  Widget build(BuildContext context) {
    return PanduanBukaKartu(
      title: 'Apa itu Pivot Point?',
      subtitle: 'Panduan & Rumus Perhitungan Level',
      onTap: () => bukaPanduanPivotPoint(context),
    );
  }
}

class PivotPointWhyCard extends StatelessWidget {
  final String action;
  final double pivotPoint;
  final double open;
  const PivotPointWhyCard({
    super.key,
    required this.action,
    required this.pivotPoint,
    required this.open,
  });

  @override
  Widget build(BuildContext context) {
    late final String headline;
    late final String detail;

    if (action == 'buy') {
      headline = 'Kenapa hasilnya BUY?';
      detail = 'Pivot Point (${_n(pivotPoint)}) lebih tinggi dari harga open (${_n(open)}). '
          'Artinya harga dibuka di bawah titik acuan hari ini, sehingga ada peluang harga naik '
          'menuju Pivot Point dan level resistance di atasnya.';
    } else if (action == 'sell') {
      headline = 'Kenapa hasilnya SELL?';
      detail = 'Pivot Point (${_n(pivotPoint)}) lebih rendah dari harga open (${_n(open)}). '
          'Artinya harga dibuka di atas titik acuan hari ini, sehingga ada peluang harga turun '
          'menuju Pivot Point dan level support di bawahnya.';
    } else {
      headline = 'Kenapa hasilnya NETRAL?';
      detail = 'Pivot Point (${_n(pivotPoint)}) sama dengan harga open (${_n(open)}), '
          'sehingga belum ada kecenderungan arah dari indikator ini.';
    }
    return _WhyCard(action: action, headline: headline, detail: detail);
  }
}

// ============================================================
// NEST
// ============================================================

class NestExplainer extends StatelessWidget {
  const NestExplainer({super.key});

  @override
  Widget build(BuildContext context) {
    return PanduanBukaKartu(
      title: 'Apa itu Konsep Nest?',
      subtitle: 'Panduan & Aturan Analisa Follow the Trend',
      onTap: () => bukaPanduanNest(context),
    );
  }
}

class NestWhyCard extends StatelessWidget {
  final String action;
  final double close;
  final double open;
  const NestWhyCard({
    super.key,
    required this.action,
    required this.close,
    required this.open,
  });

  @override
  Widget build(BuildContext context) {
    late final String headline;
    late final String detail;

    if (action == 'buy') {
      headline = 'Kenapa hasilnya BUY?';
      detail = 'Close kemarin (${_n(close)}) lebih tinggi dari Open hari ini (${_n(open)}). '
          'Harga dibuka lebih murah dari penutupan sebelumnya, sehingga ada peluang harga naik kembali.';
    } else if (action == 'sell') {
      headline = 'Kenapa hasilnya SELL?';
      detail = 'Close kemarin (${_n(close)}) lebih rendah dari Open hari ini (${_n(open)}). '
          'Harga dibuka lebih mahal dari penutupan sebelumnya, sehingga ada peluang harga turun kembali.';
    } else {
      headline = 'Kenapa hasilnya NETRAL?';
      detail = 'Close kemarin (${_n(close)}) sama dengan Open hari ini (${_n(open)}), '
          'sehingga belum ada kecenderungan arah dari indikator ini.';
    }
    return _WhyCard(action: action, headline: headline, detail: detail);
  }
}

// ============================================================
// EMAS FISIK
// ============================================================

class EmasFisikExplainer extends StatelessWidget {
  const EmasFisikExplainer({super.key});

  @override
  Widget build(BuildContext context) {
    return PanduanBukaKartu(
      title: 'Apa itu Emas Fisik?',
      subtitle: 'Panduan & Rumus Simulasi Perhitungan',
      onTap: () => bukaPanduanEmasFisik(context),
    );
  }
}

class EmasFisikReadingCard extends StatelessWidget {
  final double selisih; // HHJ - HHB per gram
  final double beratGram;
  final double profit;
  const EmasFisikReadingCard({
    super.key,
    required this.selisih,
    required this.beratGram,
    required this.profit,
  });

  @override
  Widget build(BuildContext context) {
    final untung = profit > 0;
    final rugi = profit < 0;
    final action = untung ? 'buy' : (rugi ? 'sell' : 'netral');

    final headline = untung
        ? 'Kenapa hasilnya untung?'
        : (rugi ? 'Kenapa hasilnya rugi?' : 'Kenapa hasilnya impas?');

    final detail = untung
        ? 'Harga jual per gram lebih tinggi ${_rp(selisih)} dari harga beli. Dengan modal Anda, '
            'Anda mendapat ${beratGram.toStringAsFixed(2).replaceAll('.', ',')} gram, sehingga '
            'keuntungannya ${_rp(selisih)} × ${beratGram.toStringAsFixed(2).replaceAll('.', ',')} gram = ${_rp(profit)}.'
        : (rugi
            ? 'Harga jual per gram lebih rendah ${_rp(selisih.abs())} dari harga beli. Dengan '
                '${beratGram.toStringAsFixed(2).replaceAll('.', ',')} gram yang Anda beli, '
                'kerugiannya ${_rp(profit.abs())}.'
            : 'Harga jual sama dengan harga beli, sehingga tidak ada keuntungan maupun kerugian.');

    return _WhyCard(action: action, headline: headline, detail: detail);
  }
}