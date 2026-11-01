// widgets/news_fallback_cover.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class NewsFallbackCover extends StatelessWidget {
  final String sourceName;
  final String? sourceIcon;
  final double logoSize;

  const NewsFallbackCover({
    super.key,
    required this.sourceName,
    this.sourceIcon,
    this.logoSize = 56,
  });

  Color _brandColor(String source) {
    switch (source.toLowerCase()) {
      case 'cnbc':
        return AppColors.brandCnbc;
      case 'reuters':
        return AppColors.brandReuters;
      default:
        return AppColors.brandDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _brandColor(sourceName),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (sourceIcon != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                sourceIcon!,
                width: logoSize, height: logoSize, fit: BoxFit.contain,
                errorBuilder: (_, _, _ ) => Icon(Icons.public, color: Colors.white54, size: logoSize * 0.7),
              ),
            )
          else
            Icon(Icons.public, color: Colors.white54, size: logoSize * 0.7),
          const SizedBox(height: 8),
          Text(sourceName,
              style: AppTextStyles.labelMd(color: Colors.white70).copyWith(letterSpacing: 0.5)),
        ],
      ),
    );
  }
}