import 'package:flutter/material.dart';

/// Kumpulan warna utama aplikasi, diambil dari desain (nuansa oranye/peach).
/// Warna netral berubah mengikuti mode terang/gelap lewat [isDark].
class AppColors {
  AppColors._();

  /// Diatur oleh ThemeController. Jangan diubah dari tempat lain.
  static bool isDark = false;

  static Color _pick(int terang, int gelap) => Color(isDark ? gelap : terang);

  // ===== Berubah mengikuti mode =====

  // Tint lembut (latar ikon/kartu)
  static Color get primaryTint => _pick(0xFFFFF1E6, 0xFF3A2414);
  static Color get secondaryTint => _pick(0xFFDCEBFF, 0xFF14283F);
  static Color get primarySoft => _pick(0xFFFBD9BE, 0xFF4A2D18);
  static Color get secondarySoft => _pick(0xFFBBD6FB, 0xFF1F3C5E);
  static Color get successBg => _pick(0xFFDCF9EB, 0xFF0F3324);
  static Color get dangerBg => _pick(0xFFFBD9D9, 0xFF3D1A1A);

  // Netral
  static Color get textPrimary => _pick(0xFF1B1B1B, 0xFFF2F2F2);
  static Color get textSecondary => _pick(0xFF8C8A87, 0xFFA3A19D);
  static Color get background => _pick(0xFFFFFFFF, 0xFF121212);
  static Color get surface => _pick(0xFFF2F2F2, 0xFF1E1E1E);
  static Color get navBarBackground => _pick(0xFFEDEAE6, 0xFF1E1E1E);
  static Color get divider => _pick(0xFFE5E5E5, 0xFF2E2E2E);

  // Skeleton loading
  static Color get skeletonBase => _pick(0xFFE6E6E6, 0xFF2A2A2A);
  static Color get skeletonHighlight => _pick(0xFFF7F7F7, 0xFF3A3A3A);

  // ===== Sama di kedua mode =====

  static const Color darkButtonTop = Color(0xFF1B1F2A);
  static const Color darkButtonBottom = Color(0xFF0D0F14);

  // Primary — oranye
  static const Color primary = Color(0xFFEC7013);
  static const Color primaryLight = Color(0xFFFF8D46);
  static const Color primaryDeep = Color(0xFFC25800);
  static const Color primaryDark = Color(0xFFB85510);

  // Secondary — biru
  static const Color secondary = Color(0xFF138EEC);

  // Tertiary — hijau
  static const Color success = Color(0xFF13A868);

  // Danger
  static const Color danger = Color(0xFFE53935);

  // Ilustrasi (globe di halaman Bahasa)
  static const Color globeLight = Color(0xFF64C7F0);
  static const Color globeDark = Color(0xFF4389D8);

  // Brand sumber berita (kartu berita cadangan)
  static const Color brandBloomberg = Color(0xFF1A1A1A);
  static const Color brandCnbc = Color(0xFF0A1E42);
  static const Color brandReuters = Color(0xFFFF6600);
  static const Color brandDefault = Color(0xFF37474F);

  // Overlay gelap di atas foto berita (sama dengan Colors.black87)
  static const Color overlayDark = Color(0xDD000000);
}