// views/onboarding_page.dart
import 'package:flutter/material.dart' hide Text;
import '../widgets/app_text.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'welcome_page.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ===== Background: foto gedung, full-bleed =====
          Image.asset(
            'assets/images/onboarding_building.png',
            fit: BoxFit.cover,
          ),

          // ===== Overlay gradient supaya teks tetap kebaca =====
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.05),
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.85),
                ],
                stops: const [0.0, 0.35, 0.65, 1.0],
              ),
            ),
          ),

          // ===== Konten =====
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // Logo + wordmark
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset('assets/images/logo_trustByEwf.png', height: 32),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Trust by Equityworld',
                        style: AppTextStyles.labelLg(color: AppColors.textPrimary)
                            .copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Headline
                  Text(
                    'TRADE\nWITH TRUST',
                    style: AppTextStyles.display(color: AppColors.primary).copyWith(height: 1.05),
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  Text(
                    'Berizin resmi BAPPEBTI sejak 2005. Partner '
                    'terpercaya Anda dalam perdagangan berjangka komoditi.',
                    style: AppTextStyles.bodyMd(color: Colors.white),
                  ),

                  const SizedBox(height: 24),

                  // Tombol Get Started (pill putih + tombol panah oranye)
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(32),
                      onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const WelcomePage()),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 24, right: 6, top: 6, bottom: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: Text(
                                'Mulai',
                                style: AppTextStyles.labelLg(color: AppColors.textPrimary)
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}