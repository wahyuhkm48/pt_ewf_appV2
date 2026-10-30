// widgets/kalkulator_form_widgets.dart
// Komponen formulir yang dipakai bersama oleh PivotPointPage dan NestPage.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/asset_labels.dart';
import 'offline_widgets.dart';
import 'riwayat_button.dart';
import 'tradingview_chart.dart';

enum SumberData { otomatis, manual }

/// Produk yang bisa dihitung: kunci API -> label di layar.
const kProdukKalkulator = {'gold': 'Gold', 'nikkei': 'JPK', 'hangseng': 'HKK'};

const _kSimbolTradingView = {
  'gold': 'Saxo:XAUUSD',
  'nikkei': 'Vantage:NIKKEI225',
  'hangseng': 'IG:HANGSENG',
};

const _kBulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

// ===================== Fungsi bantu =====================

String formatTanggalKalkulator(DateTime date) {
  final now = DateTime.now();
  final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
  final tanggal = '${date.day} ${_kBulan[date.month - 1]} ${date.year}';
  return isToday ? 'Hari ini, $tanggal' : tanggal;
}

String formatAngka(double value) => value.toStringAsFixed(2);

double? parseAngka(String raw) {
  final text = raw.trim().replaceAll(',', '.');
  if (text.isEmpty) return null;
  return double.tryParse(text);
}

String subjudulExport(String? asset, DateTime? tanggal) {
  final label = assetLabel(asset);
  return tanggal == null
      ? '$label • Perhitungan manual' // hasil manual tidak punya tanggal
      : '$label • ${formatTanggalKalkulator(tanggal)}';
}

Future<DateTime?> pilihTanggalKalkulator(BuildContext context, DateTime awal) {
  return showDatePicker(
    context: context,
    initialDate: awal,
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
  );
}

// ===================== Header =====================

class KalkulatorHeader extends StatelessWidget {
  final String iconAsset;
  final String title;
  final VoidCallback onRiwayat;

  const KalkulatorHeader({
    super.key,
    required this.iconAsset,
    required this.title,
    required this.onRiwayat,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(iconAsset, width: 28, height: 28),
              const SizedBox(width: 10),
              Text(title, style: AppTextStyles.h3()),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: RiwayatButton(onTap: onRiwayat),
          ),
        ],
      ),
    );
  }
}

// ===================== Produk + grafik =====================

class KalkulatorProdukSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const KalkulatorProdukSelector({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Produk', style: AppTextStyles.labelMd()),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(30)),
          child: Row(
            children: kProdukKalkulator.entries.map((entry) {
              final isSelected = selected == entry.key;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      entry.value,
                      style: AppTextStyles.labelMd(color: isSelected ? Colors.white : AppColors.textSecondary),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Grafik TradingView untuk produk yang dipilih.
class KalkulatorChart extends StatelessWidget {
  final String asset;
  const KalkulatorChart({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return OnlineGate(
      compact: true,
      title: 'Grafik butuh internet',
      message: 'Grafik harga dimuat dari TradingView. Input manual tetap bisa dipakai.',
      child: Container(
        width: double.infinity,
        height: 320,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
        ),
        child: TradingViewChart(
          key: ValueKey(_kSimbolTradingView[asset]), // ganti produk = muat ulang grafik
          symbol: _kSimbolTradingView[asset]!,
          interval: 'D',
          height: 320,
        ),
      ),
    );
  }
}

// ===================== Sumber data =====================

class KalkulatorSumberDataSelector extends StatelessWidget {
  final SumberData value;
  final ValueChanged<SumberData> onChanged;

  const KalkulatorSumberDataSelector({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sumber Data', style: AppTextStyles.labelMd()),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: SumberData.values.map((sumber) {
              final selected = value == sumber;
              final label = sumber == SumberData.otomatis ? 'Ambil dari Pasar' : 'Input Manual';
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(sumber),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      style: AppTextStyles.labelSm(color: selected ? AppColors.primary : AppColors.textSecondary),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class KalkulatorOfflineNotice extends StatelessWidget {
  final VoidCallback onPakaiManual;
  const KalkulatorOfflineNotice({super.key, required this.onPakaiManual});

  @override
  Widget build(BuildContext context) {
    return OfflineNotice(
      compact: true,
      title: 'Ambil dari Pasar butuh internet',
      message: 'Data pasar diambil dari server. Kamu tetap bisa menghitung dengan memasukkan angka sendiri.',
      alternativeLabel: 'Pakai Input Manual',
      onAlternative: onPakaiManual,
    );
  }
}

// ===================== Input =====================

class KalkulatorTanggalField extends StatelessWidget {
  final DateTime tanggal;
  final VoidCallback onTap;

  const KalkulatorTanggalField({super.key, required this.tanggal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tanggal', style: AppTextStyles.labelMd()),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatTanggalKalkulator(tanggal), style: AppTextStyles.labelBase()),
                const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class KalkulatorNumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;

  const KalkulatorNumberField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMd()),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
            style: AppTextStyles.labelBase(),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMd(),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class KalkulatorHitungButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed; // null = tombol nonaktif

  const KalkulatorHitungButton({super.key, required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.calculate_rounded, color: Colors.white),
        label: Text('Hitung', style: AppTextStyles.labelLg(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }
}