// views/chart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/empty_state.dart';
import '../widgets/skeleton.dart';
import '../widgets/offline_widgets.dart';
import '../viewmodels/histori_viewmodel.dart';
import '../models/histori_data_model.dart';
import '../utils/histori_excel_exporter.dart';

enum _RangeFilter { all, last7, last30, custom }

const _kBulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
String _fmtTanggal(DateTime d) => '${d.day} ${_kBulan[d.month - 1]} ${d.year}';
String _fmtPendek(DateTime d) => '${d.day} ${_kBulan[d.month - 1]}';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  int _selectedTab = 0; // 0 = Gold, 1 = JPK, 2 = HKK
  final List<String> _tabs = const ['Gold', 'JPK', 'HKK'];
  bool _isExporting = false;

  // ===== Filter tabel Data Historis =====
  final ScrollController _scroll = ScrollController();
  _RangeFilter _range = _RangeFilter.all;
  DateTimeRange? _customRange;
  bool _newestFirst = true;

  bool get _isFiltered => _range != _RangeFilter.all || !_newestFirst;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoriViewModel>().loadTab(_selectedTab);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Kembalikan filter dan urutan ke tampilan awal.
  void _resetFilters() {
    _range = _RangeFilter.all;
    _customRange = null;
    _newestFirst = true;
  }

  void _setRange(_RangeFilter r) {
    setState(() {
      _range = r;
      _customRange = null;
    });
  }

  void _pindahTab(int index) {
    setState(() {
      _selectedTab = index;
      _resetFilters();
    });
    context.read<HistoriViewModel>().loadTab(index);
  }

  /// Muat ulang tabel untuk tab aktif, lalu kembali ke tampilan default
  /// (filter dan urutan direset, layar digulung ke atas).
  Future<void> _refresh() async {
    final vm = context.read<HistoriViewModel>();
    setState(() {
      _resetFilters();
    });
    if (_scroll.hasClients && _scroll.offset > 0) {
      _scroll.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
    await vm.loadTab(_selectedTab, forceRefresh: true);
  }

  Future<void> _pilihRentang(List<HistoriDataModel> all) async {
    if (all.isEmpty) return;

    final first = all.map((d) => d.tanggal).reduce((a, b) => a.isBefore(b) ? a : b);
    final last = all.map((d) => d.tanggal).reduce((a, b) => a.isAfter(b) ? a : b);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(first.year, first.month, first.day),
      lastDate: DateTime(last.year, last.month, last.day),
      initialDateRange: _customRange,
      helpText: 'Pilih rentang tanggal',
      saveText: 'Terapkan',
    );

    if (picked == null || !mounted) return;
    setState(() {
      _customRange = picked;
      _range = _RangeFilter.custom;
    });
  }

  /// Menyaring dan mengurutkan data sesuai pilihan filter.
  List<HistoriDataModel> _applyFilter(List<HistoriDataModel> all) {
    if (all.isEmpty) return all;

    DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

    // Tanggal data terbaru dipakai sebagai acuan "N hari terakhir" (bukan hari ini),
    // supaya hasilnya tidak kosong saat akhir pekan atau data belum diperbarui.
    final latest = dateOnly(all.map((d) => d.tanggal).reduce((a, b) => a.isAfter(b) ? a : b));

    Iterable<HistoriDataModel> result = all;
    switch (_range) {
      case _RangeFilter.all:
        break;
      case _RangeFilter.last7:
        final from = latest.subtract(const Duration(days: 6));
        result = all.where((d) => !dateOnly(d.tanggal).isBefore(from));
      case _RangeFilter.last30:
        final from = latest.subtract(const Duration(days: 29));
        result = all.where((d) => !dateOnly(d.tanggal).isBefore(from));
      case _RangeFilter.custom:
        final r = _customRange;
        if (r != null) {
          final start = dateOnly(r.start);
          final end = dateOnly(r.end);
          result = all.where((d) {
            final day = dateOnly(d.tanggal);
            return !day.isBefore(start) && !day.isAfter(end);
          });
        }
    }

    final list = result.toList()
      ..sort((a, b) => _newestFirst ? b.tanggal.compareTo(a.tanggal) : a.tanggal.compareTo(b.tanggal));
    return list;
  }

  Future<void> _unduhExcel() async {
    if (_isExporting) return;

    // Yang diunduh = yang sedang tampil (sudah terfilter dan terurut)
    final data = _applyFilter(context.read<HistoriViewModel>().forTab(_selectedTab));
    final messenger = ScaffoldMessenger.of(context);

    if (data.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Belum ada data untuk diunduh')),
      );
      return;
    }

    setState(() => _isExporting = true);
    try {
      await HistoriExcelExporter.export(namaProduk: _tabs[_selectedTab], data: data);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Gagal membuat file Excel, coba lagi')),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: OnlineGate(
        title: 'Data historis butuh internet',
        message: 'Data historis dimuat dari server, jadi butuh internet.',
        onReconnect: () => context.read<HistoriViewModel>().loadTab(_selectedTab, forceRefresh: true),
        child: _buildOnline(context),
      ),
    );
  }

  Widget _buildOnline(BuildContext context) {
    final vm = context.watch<HistoriViewModel>();
    final all = vm.forTab(_selectedTab);
    final filtered = _applyFilter(all);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Data Historis', style: AppTextStyles.h1()),
              const SizedBox(height: 16),
              _buildTabs(),
              const SizedBox(height: 20),

              // ===== Judul + tombol refresh + Excel =====
              Row(
                children: [
                  Text('Data Pasar ${_tabs[_selectedTab]}', style: AppTextStyles.h3()),
                  const Spacer(),
                  _RefreshButton(loading: vm.isLoading, onTap: _refresh),
                  const SizedBox(width: 8),
                  _buildExcelButton(),
                ],
              ),
              const SizedBox(height: 12),

              // ===== Filter =====
              _buildFilterBar(all),
              if (_isFiltered && all.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('Menampilkan ${filtered.length} dari ${all.length} data', style: AppTextStyles.caption()),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(_resetFilters),
                      child: Text('Reset filter', style: AppTextStyles.labelSm(color: AppColors.primary)),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),

              // ===== Tabel =====
              _buildTable(vm, all, filtered),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExcelButton() {
    return Material(
      color: AppColors.successBg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: _isExporting ? null : _unduhExcel,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _isExporting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.success),
                    )
                  : const Icon(Icons.file_download_outlined, size: 16, color: AppColors.success),
              const SizedBox(width: 6),
              Text(
                _isExporting ? 'Menyiapkan...' : 'Excel',
                style: AppTextStyles.labelMd(color: AppColors.success),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar(List<HistoriDataModel> all) {
    final custom = _customRange;
    final customLabel = (_range == _RangeFilter.custom && custom != null)
        ? '${_fmtPendek(custom.start)} - ${_fmtPendek(custom.end)}'
        : 'Pilih tanggal';

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'Semua',
            selected: _range == _RangeFilter.all,
            onTap: () => _setRange(_RangeFilter.all),
          ),
          _FilterChip(
            label: '7 Hari',
            selected: _range == _RangeFilter.last7,
            onTap: () => _setRange(_RangeFilter.last7),
          ),
          _FilterChip(
            label: '30 Hari',
            selected: _range == _RangeFilter.last30,
            onTap: () => _setRange(_RangeFilter.last30),
          ),
          _FilterChip(
            label: customLabel,
            icon: Icons.date_range_rounded,
            selected: _range == _RangeFilter.custom,
            onTap: () => _pilihRentang(all),
          ),
          _FilterChip(
            label: 'Terlama',
            icon: Icons.swap_vert_rounded,
            selected: !_newestFirst,
            onTap: () => setState(() => _newestFirst = !_newestFirst),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(HistoriViewModel vm, List<HistoriDataModel> all, List<HistoriDataModel> filtered) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
            ),
            child: Row(
              children: [
                _dateCell('TANGGAL', AppTextStyles.labelSm()),
                _ohlcCell('OPEN', AppTextStyles.labelSm()),
                _ohlcCell('HIGH', AppTextStyles.labelSm()),
                _ohlcCell('LOW', AppTextStyles.labelSm()),
                _ohlcCell('CLOSE', AppTextStyles.labelSm()),
              ],
            ),
          ),
          Builder(builder: (context) {
            if (vm.isLoading && !vm.hasData(_selectedTab)) {
              return const SkeletonTableRows();
            }
            if (vm.errorMessage != null && !vm.hasData(_selectedTab)) {
              return GestureDetector(
                onTap: () => context.read<HistoriViewModel>().loadTab(_selectedTab, forceRefresh: true),
                child: const EmptyState(
                  icon: Icons.error_outline_rounded,
                  iconSize: 30,
                  title: 'Gagal memuat data (tap untuk coba lagi)',
                  padding: EdgeInsets.symmetric(vertical: 28),
                ),
              );
            }
            if (all.isEmpty) {
              return const EmptyState(
                icon: Icons.table_chart_outlined,
                iconSize: 30,
                title: 'Belum ada data historis',
                padding: EdgeInsets.symmetric(vertical: 28),
              );
            }
            if (filtered.isEmpty) {
              return GestureDetector(
                onTap: () => setState(_resetFilters),
                child: const EmptyState(
                  icon: Icons.filter_alt_off_outlined,
                  iconSize: 30,
                  title: 'Tidak ada data pada filter ini (tap untuk reset)',
                  padding: EdgeInsets.symmetric(vertical: 28),
                ),
              );
            }
            return Column(children: filtered.map((d) => _HistoryRow(data: d)).toList());
          }),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final selected = _selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => _pindahTab(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                alignment: Alignment.center,
                child: Text(
                  _tabs[index],
                  style: AppTextStyles.labelMd(color: selected ? Colors.white : AppColors.textSecondary),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ===================== Komponen kecil =====================

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 14, color: fg),
                  const SizedBox(width: 4),
                ],
                Text(label, style: AppTextStyles.labelSm(color: fg)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RefreshButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;
  const _RefreshButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Muat ulang dan reset tampilan',
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: loading ? null : onTap,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    )
                  : const Icon(Icons.refresh_rounded, size: 20, color: AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }
}

// Lebar kolom tanggal. Kecilkan angka ini kalau mau OHLC lebih dekat ke tanggal.
const double _kDateColWidth = 78;

Widget _dateCell(String text, TextStyle style) => SizedBox(
      width: _kDateColWidth,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(text, maxLines: 1, style: style),
      ),
    );

// Sel OHLC. Besarkan `horizontal` kalau mau jarak antar OHLC lebih lebar.
Widget _ohlcCell(String text, TextStyle style) => Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(text, maxLines: 1, style: style),
        ),
      ),
    );

class _HistoryRow extends StatelessWidget {
  final HistoriDataModel data;
  const _HistoryRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.caption(color: AppColors.textPrimary);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.divider, width: 0.5))),
      child: Row(
        children: [
          _dateCell(_fmtTanggal(data.tanggal), style),
          _ohlcCell(data.open.toStringAsFixed(2), style),
          _ohlcCell(data.high.toStringAsFixed(2), style),
          _ohlcCell(data.low.toStringAsFixed(2), style),
          _ohlcCell(data.close.toStringAsFixed(2), style),
        ],
      ),
    );
  }
}