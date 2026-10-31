// widgets/skeleton.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Efek shimmer. Bungkus satu layout skeleton dengan widget ini.
/// Bentuk di dalamnya dicat putih (lihat SkeletonBox): warna akhirnya
/// ditentukan gradient shimmer. Alpha < 1 menghasilkan nada lebih terang,
/// jadi kartu (alpha kecil) dan isinya (alpha 1) punya dua nada seperti wireframe.
class SkeletonShimmer extends StatefulWidget {
  final Widget child;
  const SkeletonShimmer({super.key, required this.child});

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Kalau pengguna mematikan animasi di HP, tampilkan versi diam.
    final reduce = MediaQuery.disableAnimationsOf(context);

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = reduce ? 0.0 : _controller.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              AppColors.skeletonBase,
              AppColors.skeletonHighlight,
              AppColors.skeletonBase,
            ],
            stops: const [0.35, 0.5, 0.65],
            transform: _SlideGradient(t * 2 - 1),
          ).createShader(bounds),
          child: child,
        );
      },
    );
  }
}

class _SlideGradient extends GradientTransform {
  final double percent;
  const _SlideGradient(this.percent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * percent, 0, 0);
}

// ===================== Blok dasar =====================

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  /// 1 = nada lebih gelap (isi), kecil = nada lebih terang (kartu/latar).
  final double opacity;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
    this.opacity = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class SkeletonCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const SkeletonCircle({super.key, required this.size, this.opacity = 1});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

// ===================== Layout per fitur =====================

/// Home: carousel berita (kartu 280 px, tinggi 180 dari parent).
class SkeletonNewsCarousel extends StatelessWidget {
  const SkeletonNewsCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, _) => Container(
          width: 280,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: double.infinity, height: 80, radius: 0, opacity: 0.8),
              Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: double.infinity, height: 12),
                    SizedBox(height: 8),
                    SkeletonBox(width: 180, height: 12),
                    SizedBox(height: 10),
                    SkeletonBox(width: 70, height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hot News: kartu besar 220 px dengan baris judul di bagian bawah.
class SkeletonNewsHeroList extends StatelessWidget {
  final int count;
  const SkeletonNewsHeroList({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (_, _) => Container(
          height: 220,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: double.infinity, height: 16),
              SizedBox(height: 8),
              SkeletonBox(width: 220, height: 16),
              SizedBox(height: 12),
              SkeletonBox(width: 150, height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

/// Home (Riwayat Terbaru) dan halaman History.
class SkeletonHistoryList extends StatelessWidget {
  final int count;
  const SkeletonHistoryList({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        children: [
          for (var i = 0; i < count; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == count - 1 ? 0 : 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    SkeletonCircle(size: 42),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 140, height: 14),
                          SizedBox(height: 8),
                          SkeletonBox(width: 90, height: 11),
                        ],
                      ),
                    ),
                    SkeletonBox(width: 44, height: 22, radius: 11),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Chart: baris tabel Data Historis (tanggal + OPEN HIGH LOW CLOSE).
class SkeletonTableRows extends StatelessWidget {
  final int count;
  const SkeletonTableRows({super.key, this.count = 7});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            for (var i = 0; i < count; i++)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    // 78 = lebar kolom tanggal di tabel asli
                    SizedBox(
                      width: 78,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SkeletonBox(width: 58, height: 12),
                      ),
                    ),
                    Expanded(child: Center(child: SkeletonBox(width: 44, height: 12))),
                    Expanded(child: Center(child: SkeletonBox(width: 44, height: 12))),
                    Expanded(child: Center(child: SkeletonBox(width: 44, height: 12))),
                    Expanded(child: Center(child: SkeletonBox(width: 44, height: 12))),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
