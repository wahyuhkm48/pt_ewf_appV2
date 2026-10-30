import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/api_client.dart';
import 'core/connectivity_service.dart';
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

final navigatorKey = GlobalKey<NavigatorState>();
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final connectivity = ConnectivityService()..start();
  final apiClient = ApiClient(connectivity: connectivity);
  final authService = AuthService(apiClient);
  final authViewModel = AuthViewModel(authService);

  // Server menolak token (401): bersihkan sesi lalu kembalikan user ke Login.
  var sedangMenangani = false;
  apiClient.onUnauthorized = () async {
    if (sedangMenangani) return; // beberapa request bisa 401 bersamaan
    sedangMenangani = true;
    try {
      if (!await authService.hasToken()) return; // sudah ditangani
      await authService.clearSession();
      authViewModel.clearEmployee();

      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Sesi kamu berakhir. Silakan login lagi.')),
      );
    } finally {
      sedangMenangani = false;
    }
  };

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
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trust by Equityworld',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        dividerColor: AppColors.divider,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          error: AppColors.danger,
          surface: AppColors.background,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primary),
      ),
      builder: (context, child) => OfflineBannerHost(child: child!),
      home: const SplashPage(),
    );
  }
}