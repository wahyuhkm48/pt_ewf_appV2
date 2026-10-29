// widgets/custom_bottom_nav.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class NavItemData {
  final IconData icon;       // ikon saat tidak aktif
  final IconData activeIcon; // ikon di dalam lingkaran saat aktif
  final String label;

  const NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Bar navigasi bawah dengan lingkaran aktif yang "naik" di atas bar.
/// Dipasang di dalam Stack yang membungkus body (lihat views/main_shell.dart).
class CustomBottomNav extends StatelessWidget {
  final List<NavItemData> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  static const double _barHeight = 66;
  static const double _circleSize = 60;
  static const double _rise = 25; // seberapa tinggi lingkaran menonjol di atas bar
  static const double _sideMargin = 16;

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomSafe > 0 ? bottomSafe : 12),
      child: SizedBox(
        height: _rise + _barHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth - _sideMargin * 2;
            final cellWidth = barWidth / items.length;
            final circleLeft =
                _sideMargin + cellWidth * currentIndex + (cellWidth - _circleSize) / 2;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Bar pil
                Positioned(
                  left: _sideMargin,
                  right: _sideMargin,
                  top: _rise,
                  child: Container(
                    height: _barHeight,
                    decoration: BoxDecoration(
                      color: AppColors.navBarBackground,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int i = 0; i < items.length; i++)
                          Expanded(
                            child: _NavCell(
                              item: items[i],
                              selected: i == currentIndex,
                              onTap: () => onTap(i),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Lingkaran aktif: bergeser ke tab terpilih, lalu "naik"
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  left: circleLeft,
                  top: 0,
                  child: IgnorePointer(
                    // ketukan di bagian bawah lingkaran diteruskan ke sel di bawahnya
                    child: TweenAnimationBuilder<double>(
                      key: ValueKey(currentIndex), // animasi naik diulang tiap pindah tab
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 380),
                      curve: Curves.easeOutBack,
                      builder: (context, t, child) => Transform.translate(
                        offset: Offset(0, (1 - t) * 14),
                        child: Transform.scale(scale: 0.8 + 0.2 * t, child: child),
                      ),
                      child: Container(
                        width: _circleSize,
                        height: _circleSize,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(items[currentIndex].activeIcon, color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NavCell extends StatelessWidget {
  static const double _iconSize = 30;
  static const double _iconGap = 5;
  final NavItemData item;
  final bool selected;
  final VoidCallback onTap;

  const _NavCell({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Ikon hanya terlihat saat TIDAK aktif; saat aktif ikonnya ada di lingkaran.
              // Tetap menempati ruang supaya posisi label sama di semua tab.
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: selected ? 0 : 1,
                child: Icon(item.icon, size: _iconSize, color: AppColors.textSecondary),
              ),
              const SizedBox(height: _iconGap),
              Text(
                item.label,
                style: AppTextStyles.micro(
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ).copyWith(fontWeight: selected ? FontWeight.w600 : FontWeight.w400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}