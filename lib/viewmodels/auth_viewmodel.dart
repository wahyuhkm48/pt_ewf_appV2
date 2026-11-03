// viewmodels/auth_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/employee_model.dart';
import '../utils/form_errors.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _service;
  AuthViewModel(this._service);

  bool isLoading = false;
  String? errorMessage;
  EmployeeModel? employee;

  /// Dipanggil Splash. true = ada sesi tersimpan -> langsung ke halaman utama.
  Future<bool> restoreSession() async {
    try {
      if (!await _service.hasToken()) return false;

      // Ada profil tersimpan: masuk sekarang juga (berlaku offline),
      // lalu verifikasi ke server diam-diam di latar belakang.
      final cached = await _service.cachedEmployee();
      if (cached != null) {
        employee = cached;
        notifyListeners();
        _verifikasiDiLatarBelakang();
        return true;
      }

      // Tidak ada profil tersimpan: harus ambil dari server (butuh internet).
      employee = await _service.me();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _verifikasiDiLatarBelakang() async {
    try {
      employee = await _service.me();
      notifyListeners();
    } catch (_) {
      // Offline atau server bermasalah: tetap pakai profil tersimpan.
      // Kalau token ditolak (401), ApiClient.onUnauthorized yang mengurus.
    }
  }

  /// Dipakai saat sesi berakhir (401).
  void clearEmployee() {
    employee = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      employee = await _service.login(email, password);
      return true;
    } catch (e) {
      errorMessage = pesanError(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String namaLengkap,
    required String email,
    required String noTelp,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      employee = await _service.register(
        namaLengkap: namaLengkap,
        email: email,
        noTelp: noTelp,
        password: password,
      );
      return true;
    } catch (e) {
      errorMessage = pesanError(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _service.logout();
    employee = null;
    notifyListeners();
  }

  Future<bool> updateProfile({String? namaLengkap, String? noTelp}) async {
    try {
      employee = await _service.updateProfile(namaLengkap: namaLengkap, noTelp: noTelp);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = pesanError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateFoto(List<int> bytes, String filename) async {
    try {
      employee = await _service.updateFoto(bytes, filename);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = pesanError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteFoto() async {
    try {
      employee = await _service.deleteFoto();
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = pesanError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _service.changePassword(currentPassword: currentPassword, newPassword: newPassword);
      return true;
    } catch (e) {
      errorMessage = pesanError(e);
      notifyListeners();
      return false;
    }
  }
}