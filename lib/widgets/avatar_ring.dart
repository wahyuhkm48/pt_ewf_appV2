// widgets/avatar_ring.dart
import 'package:flutter/material.dart' hide Text;
import '../widgets/app_text.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AvatarRing extends StatelessWidget {
  final double size;
  final String? fotoUrl;
  final String? nama;

  const AvatarRing({super.key, required this.size, this.fotoUrl, this.nama});

  String get _initial {
    final n = nama?.trim();
    if (n == null || n.isEmpty) return '?';
    return n[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: ClipOval(
          child: fotoUrl != null && fotoUrl!.isNotEmpty
              ? Image.network(
                  fotoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _fallback(),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: AppColors.surface,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    );
                  },
                )
              : _fallback(),
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: AppColors.primarySoft,
      alignment: Alignment.center,
      child: Text(
        _initial,
        style: AppTextStyles.h3(color: AppColors.primaryDark).copyWith(fontSize: size * 0.34),
      ),
    );
  }
}