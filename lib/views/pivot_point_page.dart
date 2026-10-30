// views/pivot_point_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/connectivity_service.dart';
import '../models/pivot_point_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/pivot_point_levels.dart';
import '../viewmodels/pivot_point_viewmodel.dart';
import '../widgets/action_badge.dart';
import '../widgets/education_sections.dart';
import '../widgets/exportable_area.dart';
import '../widgets/kalkulator_form_widgets.dart';
import '../widgets/mini_stat.dart';
import 'riwayat_kalkulator_page.dart';

/// Halaman kalkulator Pivot Point.
class PivotPointPage extends StatefulWidget {
  const PivotPointPage({super.key});

  @override
  State<PivotPointPage> createState() => _PivotPointPageState();
}

class _PivotPointPageState extends State<PivotPointPage> {
  DateTime _selectedDate = DateTime.now();
  String _selectedAsset = 'gold'; // gold | nikkei | hangseng
  SumberData _sumberData = SumberData.otomatis;

  // ===== Input Manual =====
  final _highCtrl = TextEditingController();
  final _lowCtrl = TextEditingController();
  final _closeCtrl = TextEditingController();
  final _openCtrl = TextEditingController(); // opsional
  bool _showOpenManual = false;
  String? _manualError;
  PivotPointModel? _manualResult;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PivotPointViewModel>().reset();
    });
  }

  @override
  void dispose() {
    _highCtrl.dispose();
    _lowCtrl.dispose();
    _closeCtrl.dispose();
    _openCtrl.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final picked = await pilihTanggalKalkulator(context, _selectedDate);
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _bukaRiwayat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RiwayatKalkulatorPage(
          jenis: RiwayatJenis.pivotPoint,
          initialAsset: _selectedAsset, // filter awal = produk yang sedang dipilih
        ),
      ),
    );
  }

  double _round2(double v) => (v * 100).round() / 100;

  void _hitung() {
    if (_sumberData == SumberData.otomatis) {
      if (context.read<ConnectivityService>().isOffline) return;
      context.read<PivotPointViewModel>().hitung(asset: _selectedAsset, tanggal: _selectedDate);
      return;
    }

    // ===== Manual (dihitung langsung di app, tidak lewat API, tidak disimpan) =====
    FocusScope.of(context).unfocus();
    setState(() => _manualError = null);

    final high = parseAngka(_highCtrl.text);
    final low = parseAngka(_lowCtrl.text);
    final close = parseAngka(_closeCtrl.text);
    final openRaw = _openCtrl.text.trim();
    final open = openRaw.isEmpty ? null : parseAngka(openRaw);

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
      _manualResult = _hitungManual(high: high, low: low, close: close, open: open);
    });
  }

  /// Rumus identik dengan app/Services/PivotPointService.php di backend.
  PivotPointModel _hitungManual({
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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PivotPointViewModel>();
    final online = context.watch<ConnectivityService>().isOnline;

    final isOtomatis = _sumberData == SumberData.otomatis;
    final butuhInternet = isOtomatis && !online; // mode pasar tidak bisa saat offline
    final isLoading = isOtomatis && vm.isLoading;
    final errorMessage = isOtomatis ? vm.errorMessage : _manualError;
    final result = isOtomatis ? vm.result : _manualResult;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KalkulatorHeader(
                iconAsset: 'assets/images/welcome/pivot_point.webp',
                title: 'Pivot Point',
                onRiwayat: _bukaRiwayat,
              ),
              const SizedBox(height: 24),

              Text('Data Pasar (Input)', style: AppTextStyles.h3(color: AppColors.primary)),
              const SizedBox(height: 4),
              Text('Pilih produk, sumber data & tanggal', style: AppTextStyles.bodySm()),
              const SizedBox(height: 16),

              const PivotPointExplainer(),
              const SizedBox(height: 14),

              KalkulatorProdukSelector(
                selected: _selectedAsset,
                onChanged: (v) => setState(() => _selectedAsset = v),
              ),
              const SizedBox(height: 14),

              KalkulatorChart(asset: _selectedAsset),
              const SizedBox(height: 14),

              KalkulatorSumberDataSelector(
                value: _sumberData,
                onChanged: (v) => setState(() {
                  _sumberData = v;
                  _manualError = null;
                }),
              ),
              const SizedBox(height: 14),

              if (butuhInternet) ...[
                KalkulatorOfflineNotice(
                  onPakaiManual: () => setState(() {
                    _sumberData = SumberData.manual;
                    _manualError = null;
                  }),
                ),
                const SizedBox(height: 14),
              ],

              if (isOtomatis) ...[
                KalkulatorTanggalField(tanggal: _selectedDate, onTap: _pilihTanggal),
                const SizedBox(height: 14),
              ] else ...[
                // Input manual: High, Low, Close (+ Open opsional)
                Row(
                  children: [
                    Expanded(child: KalkulatorNumberField(label: 'High', controller: _highCtrl, hint: 'cth. 2350.40')),
                    const SizedBox(width: 12),
                    Expanded(child: KalkulatorNumberField(label: 'Low', controller: _lowCtrl, hint: 'cth. 2330.10')),
                  ],
                ),
                const SizedBox(height: 12),
                KalkulatorNumberField(label: 'Close', controller: _closeCtrl, hint: 'cth. 2342.75'),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => setState(() => _showOpenManual = !_showOpenManual),
                  child: Row(
                    children: [
                      Icon(
                        _showOpenManual ? Icons.remove_circle_outline : Icons.add_circle_outline,
                        size: 16,
                        color: AppColors.primary,
                      ),
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
                  KalkulatorNumberField(label: 'Open', controller: _openCtrl, hint: 'cth. 2338.00'),
                  const SizedBox(height: 4),
                  Text(
                    'Diisi supaya muncul sinyal BUY/SELL. Kalau dikosongkan, hanya tabel level yang tampil.',
                    style: AppTextStyles.micro().copyWith(height: 1.4),
                  ),
                ],
                const SizedBox(height: 14),
              ],

              const SizedBox(height: 4),
              KalkulatorHitungButton(
                isLoading: isLoading,
                onPressed: (isLoading || butuhInternet) ? null : _hitung,
              ),

              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(errorMessage, style: AppTextStyles.bodySm(color: AppColors.danger)),
                ),

              if (result != null) ...[
                const SizedBox(height: 28),
                ExportableArea(
                  namaFile: 'pivot_${result.asset ?? 'manual'}',
                  judul: 'Pivot Point',
                  subjudul: subjudulExport(result.asset, result.tanggal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildResult(result),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildResult(PivotPointModel result) {
    return [
      Text('Hasil Pivot Point', style: AppTextStyles.h3(color: AppColors.primary)),
      const SizedBox(height: 12),

      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            MiniStat(label: 'Open', value: result.open != null ? formatAngka(result.open!) : '-'),
            MiniStat(label: 'High', value: formatAngka(result.high)),
            MiniStat(label: 'Low', value: formatAngka(result.low)),
            MiniStat(label: 'Close', value: formatAngka(result.close)),
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

      Text('Indikator Action', style: AppTextStyles.h3(color: AppColors.primary)),
      const SizedBox(height: 12),
      // Action + keterangan sekarang di bawah tabel level
      if (result.action != null) ...[
        const SizedBox(height: 16),
        ActionBadge(action: result.action!),
        if (result.open != null) ...[
          const SizedBox(height: 12),
          PivotPointWhyCard(
            action: result.action!,
            pivotPoint: result.pivotPoint,
            open: result.open!,
          ),
        ],
      ],
    ];
  }
}