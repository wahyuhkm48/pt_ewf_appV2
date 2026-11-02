// l10n/language_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'app_strings.dart';

class LanguageController extends ChangeNotifier {
  static const _key = 'app_language';
  static const supported = ['id', 'en'];

  final _storage = const FlutterSecureStorage();

  String get code => AppLang.code;

  /// Panggil sekali sebelum runApp.
  Future<void> load() async {
    final saved = await _storage.read(key: _key);
    if (saved != null && supported.contains(saved)) {
      AppLang.code = saved;
    }
  }

  Future<void> setLanguage(String code) async {
    if (!supported.contains(code) || code == AppLang.code) return;
    AppLang.code = code;
    notifyListeners();
    await _storage.write(key: _key, value: code);
  }
}