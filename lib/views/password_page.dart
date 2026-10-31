// views/password_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../utils/form_errors.dart';
import '../widgets/offline_widgets.dart';
import '../core/connectivity_service.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _errorText; // peringatan merah di bawah form (seperti di halaman Login)

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _changePassword() async {
    setState(() => _errorText = null);

    final salah = validasiGantiPassword(
      sekarang: _currentPasswordController.text,
      baru: _newPasswordController.text,
      konfirmasi: _confirmPasswordController.text,
    );
    if (salah != null) {
      setState(() => _errorText = salah);
      return;
    }

    setState(() => _loading = true);

    final auth = context.read<AuthViewModel>();
    final ok = await auth.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      _showSnack('Password berhasil diganti');
      Navigator.pop(context);
    } else {
      setState(() => _errorText = auth.errorMessage ?? 'Gagal mengganti password');
    }
  }

  @override
  Widget build(BuildContext context) {
    final online = context.watch<ConnectivityService>().isOnline;
    if (!online) {
      return const OfflinePageScaffold(
        title: 'Password',
        message: 'Mengganti password membutuhkan internet.',
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Password'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PasswordField(
              label: 'Password Saat Ini',
              hint: 'Masukkan password saat ini',
              controller: _currentPasswordController,
              obscureText: _obscureCurrent,
              onToggleVisibility: () => setState(() => _obscureCurrent = !_obscureCurrent),
            ),
            const SizedBox(height: 20),
            _PasswordField(
              label: 'Password Baru',
              hint: 'Masukkan password baru',
              controller: _newPasswordController,
              obscureText: _obscureNew,
              onToggleVisibility: () => setState(() => _obscureNew = !_obscureNew),
              helperText: 'Minimal 8 karakter yang terdiri dari huruf dan angka.',
            ),
            const SizedBox(height: 20),
            _PasswordField(
              label: 'Konfirmasi Password Baru',
              hint: 'Konfirmasi password baru',
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              onToggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(_errorText!, style: AppTextStyles.bodyMd(color: AppColors.danger)),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(
                        'Ganti Password',
                        style: AppTextStyles.labelLg(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final String? helperText;

  const _PasswordField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.obscureText,
    required this.onToggleVisibility,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelBase()),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, size: 20),
              onPressed: onToggleVisibility,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(helperText!, style: AppTextStyles.caption()),
        ],
      ],
    );
  }
}