// views/history_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/empty_state.dart';
import '../widgets/history_tiles.dart';
import '../widgets/skeleton.dart';
import '../widgets/offline_widgets.dart';
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

class HistoryPage extends StatefulWidget {
  /// true saat tab History sedang tampil (diatur oleh MainShell).
  final bool isActive;
  const HistoryPage({super.key, this.isActive = false});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _tab = 0; // 0 = Pivot Point, 1 = Nest, 2 = Emas Fisik

  bool _loading = true;
  bool _inFlight = false; // cegah dua pemuatan berjalan bersamaan
  String? _error;
  List<PivotPointModel> _pivotHistory = [];
  List<NestModel> _nestHistory = [];
  List<EmasFisikModel> _emasHistory = [];

  bool get _hasAnyData =>
      _pivotHistory.isNotEmpty || _nestHistory.isNotEmpty || _emasHistory.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant HistoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Tab History baru saja dibuka.
    // Kalau sebelumnya gagal: muat penuh (skeleton) sebagai percobaan ulang.
    // Kalau tidak: refresh diam-diam, daftar lama tetap tampil.
    if (widget.isActive && !oldWidget.isActive) {
      _load(silent: _error == null);
    }
  }

  /// [silent] = true dipakai oleh tarik-ke-bawah dan saat tab dibuka:
  /// list lama tetap tampil (tidak diganti skeleton layar penuh).
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
      final (pivot, nest, emas) = await (
        PivotPointService(client).riwayat(),
        NestService(client).riwayat(),
        EmasFisikService(client).riwayat(),
      ).wait;

      if (!mounted) return;
      setState(() {
        _pivotHistory = pivot;
        _nestHistory = nest;
        _emasHistory = emas;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      if (silent && _hasAnyData) {
        // refresh gagal, tapi data lama masih ada: biarkan tampil, beri tahu lewat snackbar
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My History',
              style: AppTextStyles.h1(),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildTabSwitcher(),
            ),
            Divider(color: AppColors.divider, height: 32),
            Expanded(
              child: OnlineGate(
                title: 'Riwayat butuh internet',
                message: 'Riwayat perhitungan tersimpan di server. Hitung manual tetap bisa dipakai.',
                onReconnect: () => _load(silent: _hasAnyData),
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Row(
      children: [
        _TabChip(label: 'Pivot Point', selected: _tab == 0, onTap: () => setState(() => _tab = 0)),
        const SizedBox(width: 10),
        _TabChip(label: 'Nest', selected: _tab == 1, onTap: () => setState(() => _tab = 1)),
        const SizedBox(width: 10),
        _TabChip(label: 'Emas Fisik', selected: _tab == 2, onTap: () => setState(() => _tab = 2)),
      ],
    );
  }

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

    switch (_tab) {
      case 0:
        return _buildList<PivotPointModel>(
          items: _pivotHistory,
          emptySubtitle: 'Semua hasil perhitungan pivot\nakan tersimpan di sini',
          tileBuilder: (item) => PivotHistoryTile(
            item: item,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PivotPointDetailPage(item: item)),
            ),
          ),
        );
      case 1:
        return _buildList<NestModel>(
          items: _nestHistory,
          emptySubtitle: 'Semua hasil perhitungan nest\nakan tersimpan di sini',
          tileBuilder: (item) => NestHistoryTile(
            item: item,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => NestDetailPage(item: item)),
            ),
          ),
        );
      default:
        return _buildList<EmasFisikModel>(
          items: _emasHistory,
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

  /// List riwayat yang bisa ditarik ke bawah untuk refresh.
  /// Kalau kosong, tampilkan EmptyState yang juga bisa di-refresh.
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

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
    );
  }
}