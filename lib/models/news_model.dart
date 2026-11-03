// models/news_model.dart
class NewsModel {
  final String articleId;
  final String title;
  final String? description;
  final String? linkUrl;
  final String? imageUrl;
  final DateTime? pubDate;
  final String sourceName;
  final String? sourceIcon;

  NewsModel({
    required this.articleId,
    required this.title,
    this.description,
    this.linkUrl,
    this.imageUrl,
    this.pubDate,
    required this.sourceName,
    this.sourceIcon,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) => NewsModel(
        articleId: json['article_id'] ?? '',
        title: json['title'] ?? 'Tanpa judul',
        description: json['description'],
        linkUrl: json['link'],
        imageUrl: json['image_url'],
        pubDate: json['pubDate'] != null ? DateTime.tryParse(json['pubDate']) : null,
        sourceName: json['source_name'] ?? 'Tidak diketahui',
        sourceIcon: json['source_icon'],
      );
}