// l10n/app_strings.dart
import 'package:flutter/foundation.dart';
import 'en_part1.dart';

class AppLang {
  AppLang._();

  /// 'id' atau 'en'. Diatur oleh LanguageController.
  static String code = 'id';
  static bool get isEn => code == 'en';

  static const _bulanId = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
  static const _bulanEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  /// Nama bulan singkat sesuai bahasa aktif.
  static List<String> get bulan => isEn ? _bulanEn : _bulanId;
}

class AppStrings {
  AppStrings._();

  /// Kamus Indonesia -> Inggris. Tahap 2: tambahkan ...enPart2 di sini.
  static final Map<String, String> en = {
    ...enPart1,
  };

  static final Set<String> _dilaporkan = {};
}

extension AppTr on String {
  /// Terjemahkan teks Indonesia ke bahasa aktif. Kalau belum ada, kembalikan apa adanya.
  String get tr {
    if (!AppLang.isEn) return this;
    final hasil = AppStrings.en[this];
    if (hasil != null) return hasil;

    // Hanya saat debug: catat teks yang belum punya terjemahan.
    assert(() {
      if (AppStrings._dilaporkan.add(this)) {
        debugPrint('[i18n] belum ada terjemahan: $this');
      }
      return true;
    }());
    return this;
  }

  /// Terjemahkan template lalu isi placeholder {nama}.
  /// Contoh: 'Halo {nama}!'.trp({'nama': 'Budi'})
  String trp(Map<String, String> params) {
    var s = tr;
    params.forEach((k, v) => s = s.replaceAll('{$k}', v));
    return s;
  }
}