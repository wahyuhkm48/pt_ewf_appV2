// services/auth_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/api_client.dart';
import '../models/employee_model.dart';

class AuthService {
  static const _kEmployeeCache = 'employee_cache';

  final ApiClient _client;
  final _storage = const FlutterSecureStorage();
  AuthService(this._client);

  // ---------- sesi tersimpan di perangkat ----------

  Future<bool> hasToken() async => (await _client.readToken()) != null;

  Future<void> _simpanCache(EmployeeModel e) =>
      _storage.write(key: _kEmployeeCache, value: jsonEncode(e.toJson()));

  Future<EmployeeModel?> cachedEmployee() async {
    try {
      final raw = await _storage.read(key: _kEmployeeCache);
      if (raw == null) return null;
      return EmployeeModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null; // cache rusak: anggap tidak ada
    }
  }

  /// Hapus token dan profil tersimpan.
  Future<void> clearSession() async {
    await _client.clearToken();
    await _storage.delete(key: _kEmployeeCache);
  }

  /// Ambil profil terbaru dari server sekaligus memperbarui cache.
  Future<EmployeeModel> me() async {
    final res = await _client.get('/me');
    final e = EmployeeModel.fromJson(res as Map<String, dynamic>);
    await _simpanCache(e);
    return e;
  }

  // ---------- auth ----------

  Future<EmployeeModel> login(String email, String password) async {
    final res = await _client.post('/login', {'email': email, 'password': password}, withAuth: false);
    await _client.saveToken(res['token']);
    final e = EmployeeModel.fromJson(res['employee']);
    await _simpanCache(e);
    return e;
  }

  Future<EmployeeModel> register({
    required String namaLengkap,
    required String email,
    required String noTelp,
    required String password,
  }) async {
    final res = await _client.post('/register', {
      'nama_lengkap': namaLengkap,
      'email': email,
      'no_telp': noTelp,
      'password': password,
      'password_confirmation': password,
    }, withAuth: false);
    await _client.saveToken(res['token']);
    final e = EmployeeModel.fromJson(res['employee']);
    await _simpanCache(e);
    return e;
  }

  /// Logout butuh internet (token dicabut di server). Kalau server gagal,
  /// exception diteruskan dan sesi TIDAK dihapus.
  Future<void> logout() async {
    await _client.post('/logout', {});
    await clearSession();
  }

  // ---------- profil ----------

  Future<EmployeeModel> updateProfile({String? namaLengkap, String? noTelp}) async {
    final body = <String, dynamic>{};
    if (namaLengkap != null) body['nama_lengkap'] = namaLengkap;
    if (noTelp != null) body['no_telp'] = noTelp;

    final res = await _client.put('/profile', body);
    final e = EmployeeModel.fromJson(res['employee']);
    await _simpanCache(e);
    return e;
  }

  Future<EmployeeModel> updateFoto(List<int> bytes, String filename) async {
    final res = await _client.postMultipart('/profile/foto', fieldName: 'foto', bytes: bytes, filename: filename);
    final e = EmployeeModel.fromJson(res['employee']);
    await _simpanCache(e);
    return e;
  }

  Future<EmployeeModel> deleteFoto() async {
    final res = await _client.delete('/profile/foto');
    final e = EmployeeModel.fromJson(res['employee']);
    await _simpanCache(e);
    return e;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _client.put('/profile/password', {
      'current_password': currentPassword,
      'new_password': newPassword,
      'new_password_confirmation': newPassword,
    });
  }
}