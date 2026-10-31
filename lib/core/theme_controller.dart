// core/theme_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../theme/app_colors.dart';

class ThemeController extends ChangeNotifier with WidgetsBindingObserver {
  static const _key = 'theme_mode';
  final _storage = const FlutterSecureStorage();

  ThemeMode _mode = ThemeMode.light; // bawaan: terang
  ThemeMode get mode => _mode;

  ThemeController() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// Panggil sekali sebelum runApp.
  Future<void> load() async {
    final saved = await _storage.read(key: _key);
    _mode = switch (saved) {
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.light,
    };
    _apply();
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    _apply();
    notifyListeners();
    await _storage.write(
      key: _key,
      value: switch (mode) {
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
        ThemeMode.light => 'light',
      },
    );
  }

  void _apply() {
    AppColors.isDark = switch (_mode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark,
    };
  }

  /// Dipanggil saat user mengganti mode gelap di pengaturan HP.
  @override
  void didChangePlatformBrightness() {
    if (_mode != ThemeMode.system) return;
    final sebelum = AppColors.isDark;
    _apply();
    if (sebelum != AppColors.isDark) notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}