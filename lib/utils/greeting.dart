// utils/greeting.dart

/// Waktu sekarang di WIB (UTC+7).
/// Dihitung dari UTC, jadi tidak bergantung pada zona waktu yang di-set di HP.
DateTime nowWib() => DateTime.now().toUtc().add(const Duration(hours: 7));

/// Sapaan sesuai jam WIB:
///   04.00 - 10.59  Selamat Pagi
///   11.00 - 14.59  Selamat Siang
///   15.00 - 17.59  Selamat Sore
///   18.00 - 03.59  Selamat Malam
String greetingWib([DateTime? wib]) {
  final hour = (wib ?? nowWib()).hour;
  if (hour >= 4 && hour < 11) return 'Selamat Pagi';
  if (hour >= 11 && hour < 15) return 'Selamat Siang';
  if (hour >= 15 && hour < 18) return 'Selamat Sore';
  return 'Selamat Malam';
}