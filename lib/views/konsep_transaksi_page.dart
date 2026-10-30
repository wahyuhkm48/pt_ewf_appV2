// views/konsep_transaksi_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../viewmodels/pivot_point_viewmodel.dart';
import '../viewmodels/nest_viewmodel.dart';
import '../models/pivot_point_model.dart';
import '../models/nest_model.dart';
import '../widgets/action_badge.dart';
import '../widgets/mini_stat.dart';
import '../widgets/education_sections.dart';
import '../widgets/exportable_area.dart';
import '../widgets/offline_widgets.dart';
import '../widgets/riwayat_button.dart';
import '../utils/pivot_point_levels.dart';
import '../utils/asset_labels.dart';
import '../core/connectivity_service.dart';
import 'riwayat_kalkulator_page.dart';

enum KalkulatorMode { pivotPoint, nest }
enum _SumberData { otomatis, manual }

class KonsepTransaksiPage extends StatefulWidget {
  /// Menentukan halaman ini menghitung Pivot Point atau Nest.
  final KalkulatorMode mode;
  const KonsepTransaksiPage({super.key, required this.mode});

  @override
  State<KonsepTransaksiPage> createState() => _KonsepTransaksiPageState();
}

class _KonsepTransaksiPageState extends State<KonsepTransaksiPage> {
  DateTime _selectedDate = DateTime.now();
  String _selectedAsset = 'gold'; // gold | nikkei | hangseng
  KalkulatorMode get _mode => widget.mode;
  _SumberData _sumberData = _SumberData.otomatis;

  // ===== Input Manual =====
  final _highCtrl = TextEditingController();
  final _lowCtrl = TextEditingController();
  final _closeCtrl = TextEditingController();
  final _openCtrl = TextEditingController(); // opsional, khusus Pivot Point
  final _closeKemarinCtrl = TextEditingController();
  final _openHariIniCtrl = TextEditingController();
  bool _showOpenManual = false;
  String? _manualError;
  PivotPointModel? _manualPivotResult;
  NestModel? _manualNestResult;

  static const _assetLabels = {'gold': 'Gold', 'nikkei': 'JPK', 'hangseng': 'HKK'};
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

  @override
  void dispose() {
    _highCtrl.dispose();
    _lowCtrl.dispose();
    _closeCtrl.dispose();
    _openCtrl.dispose();
    _closeKemarinCtrl.dispose();
    _openHariIniCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PivotPointViewModel>().reset();
      context.read<NestViewModel>().reset();
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final tanggal = '${date.day} ${_months[date.month - 1]} ${date.year}';
    return isToday ? 'Hari ini, $tanggal' : tanggal;
  }

  String _formatNumber(double value) => value.toStringAsFixed(2);

  void _bukaRiwayat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RiwayatKalkulatorPage(
          jenis: _mode == KalkulatorMode.pivotPoint ? RiwayatJenis.pivotPoint : RiwayatJenis.nest,
          initialAsset: _selectedAsset, // filter awal = produk yang sedang dipilih
        ),
      ),
    );
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  double? _parseInput(String raw) {
    final text = raw.trim().replaceAll(',', '.');
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  double _round2(double v) => (v * 100).round() / 100;

  void _hitung() {
    if (_sumberData == _SumberData.otomatis) {
      if (context.read<ConnectivityService>().isOffline) return;
      if (_mode == KalkulatorMode.pivotPoint) {
        context.read<PivotPointViewModel>().hitung(asset: _selectedAsset, tanggal: _selectedDate);
      } else {
        context.read<NestViewModel>().hitung(asset: _selectedAsset, tanggal: _selectedDate);
      }
      return;
    }

    // ===== Manual (dihitung langsung di app, tidak lewat API, tidak disimpan) =====
    FocusScope.of(context).unfocus();
    setState(() => _manualError = null);

    if (_mode == KalkulatorMode.pivotPoint) {
      final high = _parseInput(_highCtrl.text);
      final low = _parseInput(_lowCtrl.text);
      final close = _parseInput(_closeCtrl.text);
      final openRaw = _openCtrl.text.trim();
      final open = openRaw.isEmpty ? null : _parseInput(openRaw);

      if (high == null || low == null || close == null) {
        setState(() => _manualError = 'Isi High, Low, dan Close dengan angka yang valid.');
        return;
      }
      if (openRaw.isNotEmpty && open == null) {
        setState(() => _manualError = 'Open harus berupa angka yang valid, atau kosongkan.');
        return;
      }
      if (low > high) {
        setState(() => _manualError = 'Low tidak boleh lebih besar dari High.');
        return;
      }

      setState(() {
        _manualPivotResult = _hitungPivotPointManual(high: high, low: low, close: close, open: open);
      });
    } else {
      final closeKemarin = _parseInput(_closeKemarinCtrl.text);
      final openHariIni = _parseInput(_openHariIniCtrl.text);

      if (closeKemarin == null || openHariIni == null) {
        setState(() => _manualError = 'Isi Close (Kemarin) dan Open (Hari ini) dengan angka yang valid.');
        return;
      }

      setState(() {
        _manualNestResult = _hitungNestManual(closeKemarin: closeKemarin, openHariIni: openHariIni);
      });
    }
  }

  /// Rumus identik dengan app/Services/PivotPointService.php di backend.
  PivotPointModel _hitungPivotPointManual({
    required double high,
    required double low,
    required double close,
    double? open,
  }) {
    final pp = (high + low + close) / 3;
    final range = high - low;

    final resistance = [
      _round2((2 * pp) - low),
      _round2(pp + range),
      _round2(high + 2 * (pp - low)),
      _round2(high + 3 * (pp - low)),
    ];
    final support = [
      _round2((2 * pp) - high),
      _round2(pp - range),
      _round2(low - 2 * (high - pp)),
      _round2(low - 3 * (high - pp)),
    ];

    final roundedPp = _round2(pp);
    String? action;
    if (open != null) {
      if (roundedPp > open) {
        action = 'buy';
      } else if (roundedPp < open) {
        action = 'sell';
      } else {
        action = 'netral';
      }
    }

    return PivotPointModel(
      id: 0,
      asset: _selectedAsset,
      open: open,
      high: high,
      low: low,
      close: close,
      pivotPoint: roundedPp,
      action: action,
      resistance: resistance,
      support: support,
      tanggal: null,
    );
  }

  /// Rumus identik dengan app/Services/NestService.php di backend.
  NestModel _hitungNestManual({required double closeKemarin, required double openHariIni}) {
    final String action;
    if (closeKemarin > openHariIni) {
      action = 'buy';
    } else if (closeKemarin < openHariIni) {
      action = 'sell';
    } else {
      action = 'netral';
    }

    return NestModel(
      id: 0,
      asset: _selectedAsset,
      open: openHariIni,
      close: closeKemarin,
      action: action,
      tanggal: null,
    );
  }

  Widget _numberField({required String label, required TextEditingController controller, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMd(),),
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

  @override
  Widget build(BuildContext context) {
    final pivotVm = context.watch<PivotPointViewModel>();
    final nestVm = context.watch<NestViewModel>();

    final online = context.watch<ConnectivityService>().isOnline;
    final isOtomatis = _sumberData == _SumberData.otomatis;
    final butuhInternet = isOtomatis && !online; // mode pasar tidak bisa saat offline
    final isLoading = isOtomatis
        ? (_mode == KalkulatorMode.pivotPoint ? pivotVm.isLoading : nestVm.isLoading)
        : false;
    final errorMessage = isOtomatis
        ? (_mode == KalkulatorMode.pivotPoint ? pivotVm.errorMessage : nestVm.errorMessage)
        : _manualError;
    final pivotResult = isOtomatis ? pivotVm.result : _manualPivotResult;
    final nestResult = isOtomatis ? nestVm.result : _manualNestResult;

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
                        Image.asset(
                          _mode == KalkulatorMode.pivotPoint
                              ? 'assets/images/welcome/pivot_point.webp'
                              : 'assets/images/welcome/nest.webp',
                          width: 28,
                          height: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _mode == KalkulatorMode.pivotPoint ? 'Pivot Point' : 'Nest',
                          style: AppTextStyles.h3(),
                        ),
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

              Text('Data Pasar (Input)',
                  style: AppTextStyles.h3(color: AppColors.primary)),
              const SizedBox(height: 4),
              Text('Pilih Produk, sumber data, dan tanggal',
                  style: AppTextStyles.bodySm()),
              const SizedBox(height: 16),


              // Penjelasan konsep (berubah sesuai mode)
              _mode == KalkulatorMode.pivotPoint
                  ? const PivotPointExplainer()
                  : const NestExplainer(),
              const SizedBox(height: 14),

              // Produk
              Text('Produk', style: AppTextStyles.labelMd(),),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(30)),
                child: Row(
                  children: _assetLabels.entries.map((entry) {
                    final selected = _selectedAsset == entry.key;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedAsset = entry.key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(26),
                          ),
                          alignment: Alignment.center,
                          child: Text(entry.value, style: AppTextStyles.labelMd(color: selected ? Colors.white : AppColors.textSecondary)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 14),

              // Sumber Data: Otomatis (dari pasar) / Manual (input sendiri)
              Text('Sumber Data', style: AppTextStyles.labelMd(),),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: _SumberData.values.map((sumber) {
                    final selected = _sumberData == sumber;
                    final label = sumber == _SumberData.otomatis ? 'Ambil dari Pasar' : 'Input Manual';
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _sumberData = sumber;
                          _manualError = null;
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          alignment: Alignment.center,
                          child: Text(label, style: AppTextStyles.labelSm(color: selected ? AppColors.primary : AppColors.textSecondary)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),

              if (butuhInternet) ...[
                OfflineNotice(
                  compact: true,
                  title: 'Ambil dari Pasar butuh internet',
                  message: 'Data pasar diambil dari server. Kamu tetap bisa menghitung dengan memasukkan angka sendiri.',
                  alternativeLabel: 'Pakai Input Manual',
                  onAlternative: () => setState(() {
                    _sumberData = _SumberData.manual;
                    _manualError = null;
                  }),
                ),
                const SizedBox(height: 14),
              ],

              if (_sumberData == _SumberData.otomatis) ...[
                // Tanggal
                Text('Tanggal', style: AppTextStyles.labelMd(),),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _pilihTanggal,
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
                        Text(_formatDate(_selectedDate),
                            style: AppTextStyles.labelBase(),),
                        const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ] else if (_mode == KalkulatorMode.pivotPoint) ...[
                // Input manual Pivot Point: High, Low, Close (+ Open opsional)
                Row(
                  children: [
                    Expanded(child: _numberField(label: 'High', controller: _highCtrl, hint: 'cth. 2350.40')),
                    const SizedBox(width: 12),
                    Expanded(child: _numberField(label: 'Low', controller: _lowCtrl, hint: 'cth. 2330.10')),
                  ],
                ),
                const SizedBox(height: 12),
                _numberField(label: 'Close', controller: _closeCtrl, hint: 'cth. 2342.75'),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => setState(() => _showOpenManual = !_showOpenManual),
                  child: Row(
                    children: [
                      Icon(_showOpenManual ? Icons.remove_circle_outline : Icons.add_circle_outline,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        _showOpenManual ? 'Sembunyikan Open' : 'Tambah Open (opsional)',
                        style: AppTextStyles.labelSm(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                if (_showOpenManual) ...[
                  const SizedBox(height: 10),
                  _numberField(label: 'Open', controller: _openCtrl, hint: 'cth. 2338.00'),
                  const SizedBox(height: 4),
                  Text(
                    'Diisi supaya muncul sinyal BUY/SELL. Kalau dikosongkan, hanya tabel level yang tampil.',
                    style: AppTextStyles.micro().copyWith(height: 1.4),
                  ),
                ],
                const SizedBox(height: 14),
              ] else ...[
                // Input manual Nest: Close (kemarin) & Open (hari ini)
                Row(
                  children: [
                    Expanded(child: _numberField(label: 'Close (Kemarin)', controller: _closeKemarinCtrl, hint: 'cth. 2342.75')),
                    const SizedBox(width: 12),
                    Expanded(child: _numberField(label: 'Open (Hari ini)', controller: _openHariIniCtrl, hint: 'cth. 2338.00')),
                  ],
                ),
                const SizedBox(height: 14),
              ],

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (isLoading || butuhInternet) ? null : _hitung,
                  icon: isLoading
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

              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(errorMessage, style: AppTextStyles.bodySm(color: AppColors.danger)),
                ),

              if (_mode == KalkulatorMode.pivotPoint && pivotResult != null) ...[
                const SizedBox(height: 28),
                ExportableArea(
                  namaFile: 'pivot_${pivotResult.asset ?? 'manual'}',
                  judul: 'Pivot Point',
                  subjudul: _subjudulExport(pivotResult.asset, pivotResult.tanggal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildPivotPointResult(pivotResult),
                  ),
                ),
              ],
              if (_mode == KalkulatorMode.nest && nestResult != null) ...[
                const SizedBox(height: 28),
                ExportableArea(
                  namaFile: 'nest_${nestResult.asset}',
                  judul: 'Nest',
                  subjudul: _subjudulExport(nestResult.asset, nestResult.tanggal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildNestResult(nestResult),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _subjudulExport(String? asset, DateTime? tanggal) {
    final label = assetLabel(asset);
    return tanggal == null
        ? '$label • Perhitungan manual' // hasil manual tidak punya tanggal
        : '$label • ${formatTanggalIndo(tanggal)}';
  }

  // Indikator: PP > O = buy, PP < O = sell, PP == O = netral
  List<Widget> _buildPivotPointResult(PivotPointModel result) {
    return [
      Text('Hasil Pivot Point',
          style: AppTextStyles.h3(color: AppColors.primary)),
      const SizedBox(height: 12),

      if (result.action != null) ...[
        ActionBadge(action: result.action!),
        if (result.open != null) ...[
          const SizedBox(height: 12),
          PivotPointWhyCard(
            action: result.action!,
            pivotPoint: result.pivotPoint,
            open: result.open!,
          ),
        ],
        const SizedBox(height: 16),
      ],

      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            MiniStat(label: 'Open', value: result.open != null ? _formatNumber(result.open!) : '-'),
            MiniStat(label: 'High', value: _formatNumber(result.high)),
            MiniStat(label: 'Low', value: _formatNumber(result.low)),
            MiniStat(label: 'Close', value: _formatNumber(result.close)),
          ],
        ),
      ),
      const SizedBox(height: 16),

      Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(children: buildPivotLevelRows(result)),
      ),
    ];
  }

  List<Widget> _buildNestResult(NestModel result) {
    return [
      Text('Hasil Nest',
          style: AppTextStyles.h3(color: AppColors.primary)),
      const SizedBox(height: 12),

      ActionBadge(action: result.action),
      if (result.open != null) ...[
        const SizedBox(height: 12),
        NestWhyCard(action: result.action, close: result.close, open: result.open!),
      ],
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
            MiniStat(label: 'Open (Hari ini)', value: result.open != null ? _formatNumber(result.open!) : '-'),
            MiniStat(label: 'Close (Kemarin)', value: _formatNumber(result.close)),
          ],
        ),
      ),
    ];
  }
}