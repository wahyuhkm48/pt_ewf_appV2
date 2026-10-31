// views/login_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../utils/form_errors.dart';
import '../widgets/password_field.dart';
import '../widgets/offline_widgets.dart';
import '../core/connectivity_service.dart';
import 'register_page.dart';
import 'main_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String? _error; // error milik halaman ini saja

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final online = context.watch<ConnectivityService>().isOnline;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
     body: SafeArea(
  child: SizedBox(
    height: double.infinity,
    width: double.infinity,
    child: Stack(
      children: [
            // ===== Blob dekorasi atas (oranye besar + lingkaran biru kecil) =====
            Positioned(
              top: -40,
              left: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 30,
              left: 150,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // ===== Blob dekorasi bawah (oranye besar + biru kecil) =====
            Positioned(
              bottom: -40,
              right: -50,
              child: Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              right: 70,
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: AppColors.secondarySoft,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // ===== Konten utama form login =====
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              // padding bawah = tinggi keyboard, supaya form tetap bisa digulir
              // ke atas keyboard (resizeToAvoidBottomInset: false)
              padding: EdgeInsets.fromLTRB(28, 0, 28, MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                children: [
                  const SizedBox(height: 190),
                  Text('Masuk', style: AppTextStyles.h1()),
                  const SizedBox(height: 6),
                  Text("Selamat datang kembali, silakan masuk untuk melanjutkan", style: AppTextStyles.bodySm()),
                  const SizedBox(height: 36),

                  // Email
                  TextField(
                    controller: emailCtrl,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: AppTextStyles.bodyMd(),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.divider),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password
                  PasswordField(controller: passCtrl),

                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        _error!,
                        style: AppTextStyles.bodyMd(color: AppColors.danger),
                      ),
                    ),
                  ],

                  if (!online) ...[
                    const SizedBox(height: 16),
                    const OfflineNotice(
                      compact: true,
                      title: 'Masuk butuh internet',
                      message: 'Sambungkan ke internet untuk masuk ke akun kamu.',
                    ),
                  ],

                  const SizedBox(height: 60),

                  // Tombol Login
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: vm.isLoading
                        ? ElevatedButton(
                            onPressed: null,
                            style: ElevatedButton.styleFrom(
                              disabledBackgroundColor: AppColors.secondary.withValues(alpha: 0.6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              elevation: 0,
                            ),
                            child: const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            ),
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              disabledBackgroundColor: AppColors.secondary.withValues(alpha: 0.4),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            onPressed: !online ? null : () async {
                              final salah = validasiLogin(
                                email: emailCtrl.text,
                                password: passCtrl.text,
                              );
                              if (salah != null) {
                                setState(() => _error = salah);
                                return;
                              }

                              setState(() => _error = null);
                              final sukses = await vm.login(
                                emailCtrl.text.trim(),
                                passCtrl.text,
                              );
                              if (!context.mounted) return;
                              if (sukses) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const MainShell()),
                                );
                              } else {
                                setState(() => _error = vm.errorMessage);
                              }
                            },
                          child: Text('Masuk', style: AppTextStyles.labelLg(color: Colors.white)),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Link Sign up
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: "Belum punya akun? ",
                        style: AppTextStyles.bodySm(),
                        children: [
                          TextSpan(
                            text: 'Daftar',
                            style: AppTextStyles.labelMd(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
     ),
    );
  }
}