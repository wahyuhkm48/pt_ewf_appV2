// views/emas_fisik_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../viewmodels/emas_fisik_viewmodel.dart';
import '../widgets/education_sections.dart';
import '../widgets/exportable_area.dart';
import '../widgets/offline_widgets.dart';
import '../widgets/riwayat_button.dart';
import '../core/connectivity_service.dart';
import 'riwayat_kalkulator_page.dart';

class EmasFisikPage extends StatefulWidget {
  const EmasFisikPage({super.key});

  @override
  State<EmasFisikPage> createState() => _EmasFisikPageState();
}

class _EmasFisikPageState extends State<EmasFisikPage> {
  final _hargaBeliController = TextEditingController();
  final _hargaJualController = TextEditingController();
  final _kursController = TextEditingController();
  final _modalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<EmasFisikViewModel>();
      await vm.muatHargaAwal();
      if (vm.kursAwal != null) {
        _kursController.text = vm.kursAwal!.toStringAsFixed(0);
      }
    });
  }

  @override
  void dispose() {
    _hargaBeliController.dispose();
    _hargaJualController.dispose();
    _kursController.dispose();
    _modalController.dispose();
    super.dispose();
  }

  double _parseNumber(String text) {
    final cleaned = text.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0;
  }

  String _formatNumber(double value) {
    final rounded = value.round();
    final str = rounded.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  String _formatDecimal(double value, {int decimals = 2}) {
    return value.toStringAsFixed(decimals).replaceAll('.', ',');
  }

  void _bukaRiwayat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const RiwayatKalkulatorPage(jenis: RiwayatJenis.emasFisik),
      ),
    );
  }

  void _hitung() {
    final vm = context.read<EmasFisikViewModel>();
    vm.hitung(
      hb: _parseNumber(_hargaBeliController.text),
      hj: _parseNumber(_hargaJualController.text),
      kurs: _parseNumber(_kursController.text),
      modal: _parseNumber(_modalController.text),
    );
  }

  @override
    Widget build(BuildContext context) {
    final online = context.watch<ConnectivityService>().isOnline;
    if (!online) {
      return const OfflinePageScaffold(
        title: 'Emas Fisik',
        message: 'Kalkulator Emas Fisik memakai harga dan kurs terbaru dari server, jadi butuh internet.',
      );
    }

    final vm = context.watch<EmasFisikViewModel>();
    final result = vm.result;

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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/images/icons/emas_fisik.png', width: 28, height: 28),
                        const SizedBox(width: 10),
                        Text('Emas Fisik',
                            style: AppTextStyles.h3()),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: RiwayatButton(onTap: _bukaRiwayat),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const EmasFisikExplainer(),
              const SizedBox(height: 20),
              Text('Input Data',
                  style: AppTextStyles.h3(color: AppColors.primary)),
              const SizedBox(height: 12),

              if (vm.isLoadingHarga)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 10),
                      Text('Memuat kurs terkini...', style: AppTextStyles.bodySm()),
                    ],
                  ),
                ),
              if (vm.errorHarga != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(vm.errorHarga!, style: AppTextStyles.bodySm(color: AppColors.danger)),
                ),

              _InputField(label: 'Harga Beli (USD / toz)', controller: _hargaBeliController, hint: 'Contoh: 2.500'),
              const SizedBox(height: 14),
              _InputField(label: 'Harga Jual (USD / toz)', controller: _hargaJualController, hint: 'Contoh: 2.510'),
              const SizedBox(height: 14),
              _InputField(
                label: 'Kurs (USD ke IDR)',
                controller: _kursController,
                readOnly: false,
                hint: vm.isLoadingHarga ? 'Memuat...' : null,
              ),
              const SizedBox(height: 14),
              _InputField(label: 'Modal (Rupiah)', controller: _modalController, hint: 'Contoh: 10.000.000'),

              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: vm.isLoading ? null : _hitung,
                  icon: vm.isLoading
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.calculate_rounded, color: Colors.white),
                  label: Text('Hitung', style: AppTextStyles.labelLg(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),

              if (vm.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(vm.errorMessage!, style: AppTextStyles.bodySm(color: AppColors.danger)),
                ),

              if (result != null) ...[
                const SizedBox(height: 28),
                ExportableArea(
                  namaFile: 'emas_fisik',
                  judul: 'Emas Fisik',
                  subjudul: formatTanggalIndo(result.tanggal ?? DateTime.now()),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hasil Perhitungan',
                          style: AppTextStyles.h3(color: AppColors.primary)),
                      const SizedBox(height: 12),
                      _ResultCard(number: 1, title: 'HHB (Harga Hitung Beli)', formula: 'HB × Kurs ÷ 31,1',
                          value: 'Rp ${_formatNumber(result.hhb)}', valueColor: AppColors.primary),
                      const SizedBox(height: 12),
                      _ResultCard(number: 2, title: 'HHJ (Harga Hitung Jual)', formula: 'HJ × Kurs ÷ 31,1',
                          value: 'Rp ${_formatNumber(result.hhj)}', valueColor: AppColors.primary),
                      const SizedBox(height: 12),
                      _ResultCard(number: 3, title: 'Selisih (HHJ - HHB)', formula: 'HHJ - HHB',
                          value: '${result.selisih >= 0 ? '+' : ''}Rp ${_formatNumber(result.selisih)}',
                          valueColor: result.selisih >= 0 ? AppColors.success : AppColors.danger),
                      const SizedBox(height: 12),
                      _ResultCard(number: 4, title: 'Berat Emas (Gram)', formula: 'Modal ÷ HHB',
                          value: '${_formatDecimal(result.beratGram)} gram', valueColor: AppColors.primary),
                      const SizedBox(height: 12),
                      _ResultCard(number: 5, title: 'Keuntungan', formula: 'Selisih × Gram',
                          value: '${result.profit >= 0 ? '+' : ''}Rp ${_formatNumber(result.profit)}',
                          valueColor: result.profit >= 0 ? AppColors.success : AppColors.danger),
                      const SizedBox(height: 16),
                      EmasFisikReadingCard(
                        selisih: result.selisih,
                        beratGram: result.beratGram,
                        profit: result.profit,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool readOnly;

  const _InputField({required this.label, required this.controller, this.hint, this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: readOnly ? AppColors.divider.withValues(alpha: 0.3) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.labelBase())),
          SizedBox(
            width: 130,
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.right,
              style: AppTextStyles.labelLg(color: readOnly ? AppColors.textSecondary : AppColors.textPrimary),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: AppTextStyles.bodyMd(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final int number;
  final String title;
  final String formula;
  final String value;
  final Color valueColor;

  const _ResultCard({required this.number, required this.title, required this.formula, required this.value, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
      child: Row(
        children: [
          CircleAvatar(radius: 16, backgroundColor: AppColors.primary,
              child: Text('$number', style: AppTextStyles.labelBase(color: Colors.white))),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelBase()),
                const SizedBox(height: 2),
                Text(formula, style: AppTextStyles.caption()),
              ],
            ),
          ),
          Text(value, style: AppTextStyles.labelLg(color: valueColor)),
        ],
      ),
    );
  }
}