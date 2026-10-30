// views/home_screen.dart
import 'dart:async';
import 'dart:math' show Random;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'hot_news_page.dart';
import 'news_detail_page.dart';
import 'about_page.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/empty_state.dart';
import '../widgets/news_fallback_cover.dart';
import '../widgets/skeleton.dart';
import '../widgets/offline_widgets.dart';
import '../models/news_model.dart';
import '../viewmodels/news_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../utils/greeting.dart';
import '../utils/page_transitions.dart';


const String kNewsCombinedQuery = 'Federal Reserve OR interest rate';
const int kHomeNewsLimit = 10; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String _greeting = greetingWib();
  Timer? _greetingTimer;

  @override
  void initState() {
    super.initState();
    // Cek tiap menit; rebuild hanya kalau sapaan benar-benar berganti
    // (mis. app dibiarkan terbuka melewati jam 11.00)
    _greetingTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final baru = greetingWib();
      if (mounted && baru != _greeting) setState(() => _greeting = baru);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsViewModel>().loadNews();
    });
  }

  Future<void> _refresh() async {
    await context.read<NewsViewModel>().loadNews(forceRefresh: true);
  }

  @override                   
  void dispose() {
    _greetingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NewsViewModel>();
    final employee = context.watch<AuthViewModel>().employee;
    final namaDepan = (employee?.namaLengkap ?? 'Pengguna').split(' ').first;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hi $namaDepan!', style: AppTextStyles.h2()),
                      const SizedBox(height: 2),
                      Text(_greeting, style: AppTextStyles.bodyMd()),
                    ],
                  ),
                  Container(
                    width: 44, height: 44,
                    decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                    child: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const _WelcomeCard(),
              const SizedBox(height: 24),
              _SectionHeader(
                title: 'Information',
                onViewAll: () {
                  Navigator.of(context).push(PageTransitions.slideRight(const HotNewsPage(query: kNewsCombinedQuery)));
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: OnlineGate(
                  compact: true,
                  title: 'Berita butuh internet',
                  message: 'Berita pasar dimuat dari internet.',
                  onReconnect: () => context.read<NewsViewModel>().loadNews(forceRefresh: true),
                  child: Builder(builder: (context) {
                  if (vm.isLoading && vm.articles == null) {
                    return const SkeletonNewsCarousel();
                  }
                  if (vm.errorMessage != null && vm.articles == null) {
                    return const EmptyState(icon: Icons.error_outline_rounded, title: 'Gagal memuat berita');
                  }
                  final articles = (vm.articles ?? []).take(kHomeNewsLimit).toList();
                  if (articles.isEmpty) {
                    return const EmptyState(icon: Icons.article_outlined, title: 'Belum ada berita');
                  }
                  return _NewsCarousel(articles: articles);
                  }),
                ),
              ),
                            const SizedBox(height: 28),
              const _AboutAppSection(),
              const SizedBox(height: 80), // ruang agar tidak tertutup bar navigasi
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;
  const _SectionHeader({required this.title, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.labelLg()),
        GestureDetector(
          onTap: onViewAll,
          child: Text('view all', style: AppTextStyles.labelMd(color: AppColors.primary)),
        ),
      ],
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsModel article;
  const _NewsCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final heroTag = 'home_news_image_${article.articleId}';

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        PageTransitions.heroDetail(NewsDetailPage(article: article, heroTag: heroTag)),
      ),
      child: Container(
        width: 280,
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 80, width: double.infinity,
              child: Hero(
                tag: heroTag,
                child: article.imageUrl != null
                    ? Image.network(
                        article.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            NewsFallbackCover(sourceName: article.sourceName, sourceIcon: article.sourceIcon, logoSize: 32),
                      )
                    : NewsFallbackCover(sourceName: article.sourceName, sourceIcon: article.sourceIcon, logoSize: 32),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.sourceName, style: AppTextStyles.micro(color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text(article.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelMd(color: Colors.white),),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatefulWidget {
  const _WelcomeCard();

  @override
  State<_WelcomeCard> createState() => _WelcomeCardState();
}

class _WelcomeCardState extends State<_WelcomeCard> {
  // (gambar, judul, isi). Tambah atau ubah pesan di sini.
  static const _messages = <(String, String, String)>[
    ('assets/images/welcome/welcome_hello.webp', 'Selamat datang!', 'Pantau pasar dan hitung peluangmu dengan lebih tenang.'),
    ('assets/images/welcome/welcome_pivot.webp', 'Siap menghitung?', 'Coba Pivot Point untuk melihat level support dan resistance.'),
    ('assets/images/welcome/welcome_chart.webp', 'Pantau grafik', 'Lihat grafik Gold, Nikkei, dan Hang Seng di halaman Pivot Point dan Nest.'),
    ('assets/images/welcome/welcome_emas.webp', 'Hitung emas fisik', 'Cek selisih harga dan estimasi keuntunganmu.'),
    ('assets/images/welcome/welcome_nest.webp', 'Sinyal harian', 'Bandingkan Close kemarin dan Open hari ini lewat Nest.'),
    ('assets/images/welcome/welcome_news.webp', 'Kabar terbaru', 'Baca berita pasar dari Bloomberg, CNBC, dan Reuters.'),
    ('assets/images/welcome/welcome_history.webp', 'Riwayat tersimpan', 'Lihat kembali hasil perhitunganmu lewat tombol Riwayat di tiap kalkulator.'),
  ];

  late int _index = Random().nextInt(_messages.length);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % _messages.length);
      _precache(_index + 1); // siapkan gambar berikutnya agar pergantian mulus
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precache(_index);
    _precache(_index + 1);
  }

  void _precache(int i) {
    precacheImage(AssetImage(_messages[i % _messages.length].$1), context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = _messages[_index];

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        color: AppColors.primaryTint,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Column(
            key: ValueKey(_index),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 800 / 350,
                child: Image.asset(
                  m.$1,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder: (context, error, stackTrace) => const ColoredBox(
                    color: AppColors.primarySoft,
                    child: Center(
                      child: Icon(Icons.image_not_supported_outlined, color: AppColors.primaryDark),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: ConstrainedBox(
                  // tinggi minimum supaya kartu tidak melompat saat teks berganti
                  constraints: const BoxConstraints(minHeight: 62),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.$2, style: AppTextStyles.labelLg()),
                      const SizedBox(height: 4),
                      Text(m.$3, style: AppTextStyles.bodySm(color: AppColors.textPrimary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutAppSection extends StatelessWidget {
  const _AboutAppSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tentang Aplikasi', style: AppTextStyles.labelLg()),
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                PageTransitions.slideRight(const AboutPage()),
              ),
              child: Text('selengkapnya', style: AppTextStyles.labelMd(color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Trust by Equityworld membantu kamu membaca pasar dan menghitung level penting '
          'untuk Gold, Nikkei, dan Hang Seng, semuanya dalam satu aplikasi.',
          style: AppTextStyles.bodyMd().copyWith(height: 1.45),
        ),
        const SizedBox(height: 16),
        const _FeaturePair(
          left: _FeatureTile(
            iconAsset: 'assets/images/welcome/pivot_point.webp',
            title: 'Pivot Point',
            desc: 'Level support, resistance, dan sinyal buy atau sell.',
            bg: AppColors.primaryTint,
            fg: AppColors.primary,
          ),
          right: _FeatureTile(
            iconAsset: 'assets/images/welcome/nest.webp',
            title: 'Nest',
            desc: 'Sinyal harian dari Close kemarin dan Open hari ini.',
            bg: AppColors.secondaryTint,
            fg: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 12),
        const _FeaturePair(
          left: _FeatureTile(
            iconAsset: 'assets/images/welcome/emas_fisik.webp',
            title: 'Emas Fisik',
            desc: 'Selisih harga dan estimasi keuntungan.',
            bg: AppColors.successBg,
            fg: AppColors.success,
          ),
          right: _FeatureTile(
            iconAsset: 'assets/images/welcome/riwayat_kalkulator.webp' ,
            title: 'Riwayat',
            desc: 'Hasil hitunganmu tersimpan dan bisa dibuka lagi.',
            bg: AppColors.primaryTint,
            fg: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tanpa internet? Pivot Point dan Nest mode manual tetap bisa dipakai.',
                  style: AppTextStyles.bodySm(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Hasil perhitungan adalah alat bantu analisis, bukan jaminan keuntungan.',
          style: AppTextStyles.caption(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

/// Dua kartu sejajar dengan tinggi yang sama (aman untuk teks yang membesar).
class _FeaturePair extends StatelessWidget {
  final Widget left;
  final Widget right;
  const _FeaturePair({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: left),
          const SizedBox(width: 12),
          Expanded(child: right),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData? icon;
  final String? iconAsset;
  final String title;
  final String desc;
  final Color bg;
  final Color fg;

  const _FeatureTile({
    this.icon,
    this.iconAsset,
    required this.title,
    required this.desc,
    required this.bg,
    required this.fg,
  }) : assert(icon != null || iconAsset != null);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: iconAsset != null
                ? Padding(
                    padding: const EdgeInsets.all(9),
                    child: Image.asset(
                      iconAsset!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) =>
                          Icon(Icons.image_not_supported_outlined, color: fg, size: 20),
                    ),
                  )
                : Icon(icon, color: fg, size: 22),
          ),
          const SizedBox(height: 12),
          Text(title, style: AppTextStyles.labelBase()),
          const SizedBox(height: 3),
          Text(
            desc,
            style: AppTextStyles.caption(
              color: AppColors.textPrimary.withValues(alpha: 0.7),
            ).copyWith(height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _NewsCarousel extends StatefulWidget {
  final List<NewsModel> articles;
  const _NewsCarousel({required this.articles});

  @override
  State<_NewsCarousel> createState() => _NewsCarouselState();
}

class _NewsCarouselState extends State<_NewsCarousel> {
  static const double _cardWidth = 280; 
  static const double _gap = 12;
  static const Duration _interval = Duration(seconds: 4);

  final ScrollController _controller = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) => _slide());
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _slide() {
    if (!mounted || !_controller.hasClients) return;
    if (!TickerMode.valuesOf(context).enabled) return; 
    if (MediaQuery.disableAnimationsOf(context)) return; 

    final pos = _controller.position;
    if (pos.maxScrollExtent <= 0) return;

    const step = _cardWidth + _gap;
    final atEnd = pos.pixels >= pos.maxScrollExtent - 4;

    // Satu kartu ke kanan; kalau sudah di ujung, kembali ke kartu pertama.
    var target = atEnd ? 0.0 : ((pos.pixels / step).floor() + 1) * step;
    if (target > pos.maxScrollExtent) target = pos.maxScrollExtent;

    _controller.animateTo(
      target,
      duration: Duration(milliseconds: atEnd ? 800 : 600),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      // Saat disentuh atau digeser pengguna, hentikan geser otomatis;
      // lanjut lagi setelah jari dilepas.
      onPointerDown: (_) => _stopTimer(),
      onPointerUp: (_) => _startTimer(),
      onPointerCancel: (_) => _startTimer(),
      child: ListView.separated(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        itemCount: widget.articles.length,
        separatorBuilder: (_, _) => const SizedBox(width: _gap),
        itemBuilder: (context, index) => _NewsCard(article: widget.articles[index]),
      ),
    );
  }
}