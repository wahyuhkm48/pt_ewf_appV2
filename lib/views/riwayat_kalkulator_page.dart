// views/riwayat_kalkulator_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/empty_state.dart';
import '../widgets/history_tiles.dart';
import '../widgets/offline_widgets.dart';
import '../widgets/skeleton.dart';
import '../services/pivot_point_service.dart';
import '../services/nest_service.dart';
import '../services/emas_fisik_service.dart';
import '../models/pivot_point_model.dart';
import '../models/nest_model.dart';
import '../models/emas_fisik_model.dart';
import '../core/api_client.dart';
import 'pivot_point_detail_page.dart';
import 'nest_detail_page.dart';
import 'emas_fisik_detail_page.dart';

enum RiwayatJenis { pivotPoint, nest, emasFisik }

class RiwayatKalkulatorPage extends StatefulWidget {
  final RiwayatJenis jenis;

  /// Produk yang dipilih di halaman hitung (gold | nikkei | hangseng).
  /// null = tampilkan semua produk.
  final String? initialAsset;

  const RiwayatKalkulatorPage({super.key, required this.jenis, this.initialAsset});

  @override
  State<RiwayatKalkulatorPage> createState() => _RiwayatKalkulatorPageState();
}

class _RiwayatKalkulatorPageState extends State<RiwayatKalkulatorPage> {
  static const _assetLabels = {'gold': 'Gold', 'nikkei': 'JPK', 'hangseng': 'HKK'};

  late String? _asset = widget.initialAsset; // null = Semua
  bool _loading = true;
  bool _inFlight = false;
  String? _error;
  List<PivotPointModel> _pivot = [];
  List<NestModel> _nest = [];
  List<EmasFisikModel> _emas = [];

  bool get _punyaFilterProduk => widget.jenis != RiwayatJenis.emasFisik;

  String get _judul => switch (widget.jenis) {
        RiwayatJenis.pivotPoint => 'Riwayat Pivot Point',
        RiwayatJenis.nest => 'Riwayat Nest',
        RiwayatJenis.emasFisik => 'Riwayat Emas Fisik',
      };

  bool get _hasData => switch (widget.jenis) {
        RiwayatJenis.pivotPoint => _pivot.isNotEmpty,
        RiwayatJenis.nest => _nest.isNotEmpty,
        RiwayatJenis.emasFisik => _emas.isNotEmpty,
      };

  List<PivotPointModel> get _pivotTampil =>
      _asset == null ? _pivot : _pivot.where((e) => e.asset == _asset).toList();

  List<NestModel> get _nestTampil =>
      _asset == null ? _nest : _nest.where((e) => e.asset == _asset).toList();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool silent = false}) async {
    if (_inFlight) return;
    _inFlight = true;

    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    final client = context.read<ApiClient>();
    try {
      switch (widget.jenis) {
        case RiwayatJenis.pivotPoint:
          final data = await PivotPointService(client).riwayat();
          if (!mounted) return;
          setState(() {
            _pivot = data;
            _error = null;
          });
        case RiwayatJenis.nest:
          final data = await NestService(client).riwayat();
          if (!mounted) return;
          setState(() {
            _nest = data;
            _error = null;
          });
        case RiwayatJenis.emasFisik:
          final data = await EmasFisikService(client).riwayat();
          if (!mounted) return;
          setState(() {
            _emas = data;
            _error = null;
          });
      }
    } catch (e) {
      if (!mounted) return;
      if (silent && _hasData) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat ulang riwayat')),
        );
      } else {
        setState(() => _error = 'Server sedang sibuk. Tarik ke bawah untuk mencoba lagi.');
      }
    } finally {
      _inFlight = false;
      if (mounted && !silent) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 44,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(width: 4),
                    Expanded(child: Text(_judul, style: AppTextStyles.h3())),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (_punyaFilterProduk)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _buildFilterProduk(),
                ),
              const Divider(color: AppColors.divider, height: 28),
              Expanded(
                child: OnlineGate(
                  title: 'Riwayat butuh internet',
                  message: 'Riwayat perhitungan tersimpan di server. Hitung manual tetap bisa dipakai.',
                  onReconnect: () => _load(silent: _hasData),
                  child: _buildBody(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterProduk() {
    return Row(
      children: [
        _FilterChip(
          label: 'Semua',
          selected: _asset == null,
          onTap: () => setState(() => _asset = null),
        ),
        for (final e in _assetLabels.entries)
          _FilterChip(
            label: e.value,
            selected: _asset == e.key,
            onTap: () => setState(() => _asset = e.key),
          ),
      ],
    );
  }

  String _subtitleKosong(String jenisTeks) => _asset == null
      ? 'Semua hasil perhitungan $jenisTeks\nakan tersimpan di sini'
      : 'Belum ada hasil $jenisTeks untuk ${_assetLabels[_asset]}';

  Widget _buildBody() {
    if (_loading) {
      return const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: SkeletonHistoryList(count: 7),
      );
    }

    if (_error != null) {
      return _refreshable(
        EmptyState(
          icon: Icons.error_outline_rounded,
          iconSize: 48,
          title: 'Gagal memuat riwayat',
          subtitle: _error,
        ),
      );
    }

    switch (widget.jenis) {
      case RiwayatJenis.pivotPoint:
        return _buildList<PivotPointModel>(
          items: _pivotTampil,
          emptySubtitle: _subtitleKosong('pivot point'),
          tileBuilder: (item) => PivotHistoryTile(
            item: item,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PivotPointDetailPage(item: item)),
            ),
          ),
        );
      case RiwayatJenis.nest:
        return _buildList<NestModel>(
          items: _nestTampil,
          emptySubtitle: _subtitleKosong('nest'),
          tileBuilder: (item) => NestHistoryTile(
            item: item,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => NestDetailPage(item: item)),
            ),
          ),
        );
      case RiwayatJenis.emasFisik:
        return _buildList<EmasFisikModel>(
          items: _emas,
          emptySubtitle: 'Semua hasil perhitungan emas fisik\nakan tersimpan di sini',
          tileBuilder: (item) => EmasHistoryTile(
            item: item,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => EmasFisikDetailPage(item: item)),
            ),
          ),
        );
    }
  }

  Widget _buildList<T>({
    required List<T> items,
    required String emptySubtitle,
    required Widget Function(T item) tileBuilder,
  }) {
    if (items.isEmpty) {
      return _refreshable(
        EmptyState(
          icon: Icons.folder_open_rounded,
          iconSize: 48,
          title: 'Belum ada riwayat perhitungan',
          subtitle: emptySubtitle,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _load(silent: true),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) => tileBuilder(items[i]),
      ),
    );
  }

  /// Membungkus konten tunggal (EmptyState / error) supaya tetap bisa ditarik ke bawah.
  Widget _refreshable(Widget child) {
    return RefreshIndicator(
      onRefresh: () => _load(silent: true),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelMd(color: selected ? Colors.white : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}