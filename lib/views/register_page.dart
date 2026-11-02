// views/register_page.dart
import 'package:flutter/material.dart' hide Text;
import '../widgets/app_text.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/form_errors.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/password_field.dart';
import '../widgets/offline_widgets.dart';
import '../core/connectivity_service.dart';
import '../l10n/app_strings.dart';
import 'login_page.dart';
import 'main_shell.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final namaCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final telpCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  String? _localError;

  @override
  void dispose() {
    namaCtrl.dispose();
    emailCtrl.dispose();
    telpCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthViewModel vm) async {
    setState(() => _localError = null);

    final salah = validasiRegister(
      nama: namaCtrl.text,
      email: emailCtrl.text,
      telp: telpCtrl.text,
      password: passCtrl.text,
      konfirmasi: confirmCtrl.text,
    );
    if (salah != null) {
      setState(() => _localError = salah);
      return;
    }

    final sukses = await vm.register(
      namaLengkap: namaCtrl.text.trim(),
      email: emailCtrl.text.trim().toLowerCase(),
      noTelp: normalisasiTelp(telpCtrl.text),
      password: passCtrl.text,
    );

    if (!mounted) return;
    if (sukses) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell()));
    } else {
      setState(() => _localError = vm.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final online = context.watch<ConnectivityService>().isOnline;
    final errorText = _localError;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned(
                top: -40, left: -60,
                child: Container(width: 220, height: 220, decoration: BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle)),
              ),
              Positioned(
                top: 30, left: 150,
                child: Container(width: 44, height: 44, decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle)),
              ),
              Positioned(
                bottom: -40, right: -50,
                child: Container(width: 140, height: 140, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
              ),
              Positioned(
                bottom: 40, right: 70,
                child: Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.secondarySoft, shape: BoxShape.circle)),
              ),

              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(28, 0, 28, MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  children: [
                    const SizedBox(height: 150),
                    Text('Daftar', style: AppTextStyles.h1()),
                    const SizedBox(height: 6),
                    Text('Buat akun baru', style: AppTextStyles.bodySm()),
                    const SizedBox(height: 32),

                    TextField(
                      controller: namaCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap'.tr,
                        labelStyle: AppTextStyles.bodyMd(),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'nama@gmail.com',
                        hintStyle: AppTextStyles.bodyMd(color: Colors.black.withValues(alpha: 0.3)),
                        labelStyle: AppTextStyles.bodyMd(),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: telpCtrl,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]'))],
                      decoration: InputDecoration(
                        labelText: 'Nomor Telepon'.tr,
                        labelStyle: AppTextStyles.bodyMd(),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    PasswordField(controller: passCtrl),
                    const SizedBox(height: 20),

                    PasswordField(controller: confirmCtrl, label: 'Konfirmasi Password'),

                    if (errorText != null) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: Text(errorText, style: AppTextStyles.bodyMd(color: AppColors.danger)),
                      ),
                    ],

                    if (!online) ...[
                      const SizedBox(height: 16),
                      const OfflineNotice(
                        compact: true,
                        title: 'Pendaftaran butuh internet',
                        message: 'Sambungkan ke internet untuk membuat akun.',
                      ),
                    ],

                    const SizedBox(height: 40),

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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              elevation: 0,
                            ),
                            onPressed: online ? () => _submit(vm) : null,
                            child: Text('Daftar', style: AppTextStyles.labelLg(color: Colors.white)),
                          ),
                    ),
                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      ),
                      child: RichText(
                        text: TextSpan(
                          text: 'Sudah punya akun? '.tr,
                          style: AppTextStyles.bodySm(),
                          children: [
                            TextSpan(text: 'Masuk'.tr, style: AppTextStyles.labelMd()),
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