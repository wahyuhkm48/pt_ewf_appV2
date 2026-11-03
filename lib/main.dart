import 'package:flutter/material.dart' hide Text;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'widgets/app_text.dart';
import 'l10n/app_strings.dart';
import 'l10n/language_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/api_client.dart';
import 'core/connectivity_service.dart';
import 'core/theme_controller.dart';
import 'core/session_watcher.dart';
import 'services/auth_service.dart';
import 'services/pivot_point_service.dart';
import 'services/emas_fisik_service.dart';
import 'services/histori_service.dart';
import 'services/news_service.dart';
import 'services/market_data_service.dart';
import 'theme/app_colors.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/pivot_point_viewmodel.dart';
import 'viewmodels/emas_fisik_viewmodel.dart';
import 'viewmodels/histori_viewmodel.dart';
import 'viewmodels/news_viewmodel.dart';
import 'services/nest_service.dart';
import 'viewmodels/nest_viewmodel.dart';
import 'views/splash_page.dart';
import 'views/login_page.dart';
import 'widgets/offline_widgets.dart';
import 'widgets/theme_rebuilder.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeController = ThemeController();
  await themeController.load();
  final languageController = LanguageController();
  await languageController.load();

  final connectivity = ConnectivityService()..start();
  final apiClient = ApiClient(connectivity: connectivity);
  final authService = AuthService(apiClient);
  final authViewModel = AuthViewModel(authService);

  // Server menolak token (401): bersihkan sesi lalu kembalikan user ke Login.
  var sedangMenangani = false;
  apiClient.onUnauthorized = (digantikan) async {
    if (sedangMenangani) return;
    sedangMenangani = true;
    try {
      if (!await authService.hasToken()) return;
      await authService.clearSession();
      authViewModel.clearEmployee();

      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );

      if (digantikan) {
        _tampilkanDialogSesiDigantikan();
      } else {
        scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(content: Text('Sesi kamu berakhir. Silakan login lagi.')),
        );
      }
    } finally {
      sedangMenangani = false;
    }
  };

  SessionWatcher(authService).start();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: connectivity),
        Provider(create: (_) => apiClient),
        ChangeNotifierProvider.value(value: authViewModel),
        ChangeNotifierProvider(create: (_) => PivotPointViewModel(PivotPointService(apiClient))),
        ChangeNotifierProvider(create: (_) => NestViewModel(NestService(apiClient))),
        ChangeNotifierProvider(create: (_) => EmasFisikViewModel(EmasFisikService(apiClient), MarketDataService(apiClient))),
        ChangeNotifierProvider(create: (_) => HistoriViewModel(HistoriService(apiClient))),
        ChangeNotifierProvider(create: (_) => NewsViewModel(NewsService(apiClient))),
        ChangeNotifierProvider.value(value: themeController),
        ChangeNotifierProvider.value(value: languageController),
      ],
      child: const MyApp(),
    ),
  );
}

void _tampilkanDialogSesiDigantikan() {
  // Tunggu LoginPage terpasang, baru dialog muncul di atasnya.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final ctx = navigatorKey.currentState?.overlay?.context;
    if (ctx == null) return;
    showDialog<void>(
      context: ctx,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        icon: const Icon(Icons.devices_other_rounded, color: AppColors.primary, size: 32),
        title: const Text('Akun digunakan di perangkat lain'),
        content: const Text(
          'Akunmu baru saja login di perangkat lain, jadi kamu otomatis keluar dari perangkat ini. '
          'Jika itu bukan kamu, segera ganti password setelah login.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dibaca supaya MaterialApp ikut dibangun ulang saat mode berubah
    context.watch<ThemeController>();
    context.watch<LanguageController>();
    final brightness = AppColors.isDark ? Brightness.dark : Brightness.light;

    return MaterialApp(
      title: 'Trust by Equityworld',
      debugShowCheckedModeBanner: false,
      locale: Locale(AppLang.code),
      supportedLocales: const [Locale('id'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: ThemeData(
        useMaterial3: true,
        brightness: brightness,
        scaffoldBackgroundColor: AppColors.background,
        dividerColor: AppColors.divider,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: brightness,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          error: AppColors.danger,
          surface: AppColors.background,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          surfaceTintColor: Colors.transparent,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData(brightness: brightness).textTheme),
        progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primary),
      ),
      builder: (context, child) => ThemeRebuilder(child: OfflineBannerHost(child: child!)),
      home: const SplashPage(),
    );
  }
}