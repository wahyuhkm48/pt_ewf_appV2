// lib/widgets/recent_history_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/skeleton.dart';
import '../models/recent_history_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../viewmodels/recent_history_viewmodel.dart';
import '../views/emas_fisik_detail_page.dart';
import '../views/nest_detail_page.dart';
import '../views/pivot_point_detail_page.dart';
import 'empty_state.dart';
import 'history_tiles.dart';

class RecentHistorySection extends StatelessWidget {
  final VoidCallback? onViewAll;
  const RecentHistorySection({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecentHistoryViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Riwayat Terbaru',
              style: AppTextStyles.labelLg(),
            ),
            if (onViewAll != null)
              GestureDetector(
                onTap: onViewAll,
                child: Text(
                  'lihat semua',
                  style: AppTextStyles.labelMd(color: AppColors.primary),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _buildBody(context, vm),
        const SizedBox(height: 56), // ruang untuk bottom nav
      ],
    );
  }

  Widget _buildBody(BuildContext context, RecentHistoryViewModel vm) {
    if (vm.isLoading && vm.items.isEmpty) {
      return const SkeletonHistoryList(count: 3);
    }

    if (vm.errorMessage != null && vm.items.isEmpty) {
      return Center(
        child: GestureDetector(
          onTap: () => vm.load(),
          child: const EmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Gagal memuat riwayat',
            subtitle: 'Ketuk untuk coba lagi',
          ),
        ),
      );
    }

    if (vm.items.isEmpty) {
      return const Center(
        child: EmptyState(
          icon: Icons.folder_open_rounded,
          title: 'Belum ada riwayat perhitungan',
          subtitle: 'Hasil perhitungan terbaru kamu\nakan muncul di sini',
        ),
      );
    }

    final last = vm.items.length - 1;
    return Column(
      children: [
        for (var i = 0; i < vm.items.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == last ? 0 : 10),
            child: _tileFor(context, vm.items[i]),
          ),
      ],
    );
  }

  Widget _tileFor(BuildContext context, RecentHistoryItem item) {
    void open(Widget page) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

    return switch (item) {
      RecentPivot(:final data) =>
        PivotHistoryTile(item: data, onTap: () => open(PivotPointDetailPage(item: data))),
      RecentNest(:final data) =>
        NestHistoryTile(item: data, onTap: () => open(NestDetailPage(item: data))),
      RecentEmas(:final data) =>
        EmasHistoryTile(item: data, onTap: () => open(EmasFisikDetailPage(item: data))),
    };
  }
}