// views/welcome_page.dart
import 'package:flutter/material.dart' hide Text;
import '../widgets/app_text.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'login_page.dart';
import 'register_page.dart';

/// Clipper untuk bentuk "dome" putih di bagian bawah — melengkung naik
/// di tengah, seperti pada desain welcome screen.
class _DomeClipper extends CustomClipper<Path> {
  const _DomeClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    const domeHeight = 36.0; // seberapa tinggi lengkungan naik di tengah

    path.moveTo(0, domeHeight + 24);
    path.quadraticBezierTo(
      size.width / 2,
      -domeHeight + 24,
      size.width,
      domeHeight + 24,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ===== Background: foto gedung, full-bleed =====
          Image.asset(
            'assets/images/onboarding_building.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.textPrimary,
            ),
          ),

          // ===== Overlay gradient tipis supaya logo tetap kebaca =====
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.black.withValues(alpha: 0.10),
                  Colors.black.withValues(alpha: 0.30),
                ],
                stops: const [0.0, 0.35, 1.0],
              ),
            ),
          ),

          // ===== Logo + wordmark di atas foto =====
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 56),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Image.asset(
                      'assets/images/logo_trustByEwf.png',
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.public, color: AppColors.primary, size: 40),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Trust by Equityworld',
                    style: AppTextStyles.h3(color: AppColors.darkButtonBottom)
                        .copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.2),
                  ),
                ],
              ),
            ),
          ),

          // ===== Panel putih melengkung di bawah =====
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: const _DomeClipper(),
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.52,
                color: AppColors.background,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 64, 28, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Selamat Datang',
                          style: AppTextStyles.h1(color: AppColors.textPrimary)
                              .copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Masuk atau buat akun untuk melanjutkan.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMd(color: AppColors.textSecondary),
                        ),
                        const Spacer(),

                        _WelcomeButton(
                          label: 'Masuk',
                          gradientColors: const [AppColors.darkButtonTop, AppColors.darkButtonBottom],
                          textColor: Colors.white,
                          onTap: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                          ),
                        ),
                        const SizedBox(height: 14),

                        _WelcomeButton(
                          label: 'Daftar',
                          gradientColors: [AppColors.secondary, AppColors.secondary.withValues(alpha: 0.85)],
                          textColor: Colors.white,
                          onTap: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const RegisterPage()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeButton extends StatelessWidget {
  final String label;
  final List<Color> gradientColors;
  final Color textColor;
  final VoidCallback onTap;

  const _WelcomeButton({
    required this.label,
    required this.gradientColors,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(32),
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,
            ),
            boxShadow: [
              BoxShadow(
                color: gradientColors.last.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            label,
            style: AppTextStyles.labelLg(color: textColor)
                .copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}