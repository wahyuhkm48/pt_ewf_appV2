// views/hot_news_screen.dart
import 'package:flutter/material.dart' hide Text;
import '../widgets/app_text.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/empty_state.dart';
import '../widgets/news_fallback_cover.dart';
import '../widgets/skeleton.dart';
import '../widgets/offline_widgets.dart';
import '../models/news_model.dart';
import '../viewmodels/news_viewmodel.dart';
import '../utils/page_transitions.dart';
import 'news_detail_page.dart';



class HotNewsPage extends StatefulWidget {
  final String query;
  const HotNewsPage({super.key, required this.query});

  @override
  State<HotNewsPage> createState() => _HotNewsPageState();
}

class _HotNewsPageState extends State<HotNewsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsViewModel>().loadNews(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NewsViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              const SizedBox(height: 4),
              Text('Berita Terkini', style: AppTextStyles.h1()),
              const SizedBox(height: 16),
              Expanded(
                child: OnlineGate(
                  title: 'Berita butuh internet',
                  message: 'Berita pasar dimuat dari internet. Hitung manual Pivot Point dan Nest tetap bisa dipakai.',
                  onReconnect: () => context.read<NewsViewModel>().loadNews(forceRefresh: true),
                  child: Builder(builder: (context) {
                    if (vm.isLoading && vm.articles == null) {
                      return const SkeletonNewsHeroList();
                    }
                    if (vm.errorMessage != null && vm.articles == null) {
                      return const Center(child: EmptyState(icon: Icons.error_outline_rounded, title: 'Gagal memuat berita'));
                    }
                    final articles = vm.articles ?? [];
                    if (articles.isEmpty) {
                      return const Center(child: EmptyState(icon: Icons.article_outlined, title: 'Belum ada berita'));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: articles.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) => _HotNewsCard(article: articles[index]),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HotNewsCard extends StatelessWidget {
  final NewsModel article;
  const _HotNewsCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(PageTransitions.heroDetail(NewsDetailPage(article: article))),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 220,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'news_image_${article.articleId}',
                child: article.imageUrl != null
                    ? Image.network(
                        article.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            NewsFallbackCover(sourceName: article.sourceName, sourceIcon: article.sourceIcon),
                      )
                    : NewsFallbackCover(sourceName: article.sourceName, sourceIcon: article.sourceIcon),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, AppColors.overlayDark], stops: [0.4, 1.0]),
                ),
              ),
              Positioned(
                left: 16, right: 16, bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(article.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.h3(color: Colors.white)),
                    if (article.description != null) ...[
                      const SizedBox(height: 6),
                      Text(article.description!, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodySm(color: Colors.white70)),
                    ],
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