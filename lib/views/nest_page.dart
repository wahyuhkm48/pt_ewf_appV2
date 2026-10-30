// views/nest_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/connectivity_service.dart';
import '../models/nest_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../viewmodels/nest_viewmodel.dart';
import '../widgets/action_badge.dart';
import '../widgets/education_sections.dart';
import '../widgets/exportable_area.dart';
import '../widgets/kalkulator_form_widgets.dart';
import '../widgets/mini_stat.dart';
import 'riwayat_kalkulator_page.dart';

/// Halaman kalkulator Nest.
class NestPage extends StatefulWidget {
  const NestPage({super.key});

  @override
  State<NestPage> createState() => _NestPageState();
}

class _NestPageState extends State<NestPage> {
  DateTime _selectedDate = DateTime.now();
  String _selectedAsset = 'gold'; // gold | nikkei | hangseng
  SumberData _sumberData = SumberData.otomatis;

  // ===== Input Manual =====
  final _closeKemarinCtrl = TextEditingController();
  final _openHariIniCtrl = TextEditingController();
  String? _manualError;
  NestModel? _manualResult;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NestViewModel>().reset();
    });
  }

  @override
  void dispose() {
    _closeKemarinCtrl.dispose();
    _openHariIniCtrl.dispose();
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
          jenis: RiwayatJenis.nest,
          initialAsset: _selectedAsset, // filter awal = produk yang sedang dipilih
        ),
      ),
    );
  }

  void _hitung() {
    if (_sumberData == SumberData.otomatis) {
      if (context.read<ConnectivityService>().isOffline) return;
      context.read<NestViewModel>().hitung(asset: _selectedAsset, tanggal: _selectedDate);
      return;
    }

    // ===== Manual (dihitung langsung di app, tidak lewat API, tidak disimpan) =====
    FocusScope.of(context).unfocus();
    setState(() => _manualError = null);

    final closeKemarin = parseAngka(_closeKemarinCtrl.text);
    final openHariIni = parseAngka(_openHariIniCtrl.text);

    if (closeKemarin == null || openHariIni == null) {
      setState(() => _manualError = 'Isi Close (Kemarin) dan Open (Hari ini) dengan angka yang valid.');
      return;
    }

    setState(() {
      _manualResult = _hitungManual(closeKemarin: closeKemarin, openHariIni: openHariIni);
    });
  }

  /// Rumus identik dengan app/Services/NestService.php di backend.
  NestModel _hitungManual({required double closeKemarin, required double openHariIni}) {
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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NestViewModel>();
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
                iconAsset: 'assets/images/welcome/nest.webp',
                title: 'Nest',
                onRiwayat: _bukaRiwayat,
              ),
              const SizedBox(height: 24),

              Text('Data Pasar (Input)', style: AppTextStyles.h3(color: AppColors.primary)),
              const SizedBox(height: 4),
              Text('Pilih produk, sumber data & tanggal', style: AppTextStyles.bodySm()),
              const SizedBox(height: 16),

              const NestExplainer(),
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
                // Input manual: Close (kemarin) & Open (hari ini)
                Row(
                  children: [
                    Expanded(
                      child: KalkulatorNumberField(
                        label: 'Close (Kemarin)',
                        controller: _closeKemarinCtrl,
                        hint: 'cth. 2342.75',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: KalkulatorNumberField(
                        label: 'Open (Hari ini)',
                        controller: _openHariIniCtrl,
                        hint: 'cth. 2338.00',
                      ),
                    ),
                  ],
                ),
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
                  namaFile: 'nest_${result.asset}',
                  judul: 'Nest',
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

  List<Widget> _buildResult(NestModel result) {
    return [
      Text('Hasil Nest', style: AppTextStyles.h3(color: AppColors.primary)),
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
            MiniStat(label: 'Open (Hari ini)', value: result.open != null ? formatAngka(result.open!) : '-'),
            MiniStat(label: 'Close (Kemarin)', value: formatAngka(result.close)),
          ],
        ),
      ),

      const SizedBox(height: 16),

      Text('Indikator Action', style: AppTextStyles.h3(color: AppColors.primary)),
      const SizedBox(height: 12),
      
      ActionBadge(action: result.action),
      if (result.open != null) ...[
        const SizedBox(height: 12),
        NestWhyCard(action: result.action, close: result.close, open: result.open!),
      ],
    ];
  }
}