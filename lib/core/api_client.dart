import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'connectivity_service.dart';

class ApiClient {
  static const String baseUrl = 'https://pt-ewf-backend.vercel.app/api';
  static const Duration _timeout = Duration(seconds: 30);

  final ConnectivityService? connectivity;
  ApiClient({this.connectivity});

  final _storage = const FlutterSecureStorage();

  /// Dipanggil saat server menolak token (401). Diisi di main.dart.
  Future<void> Function(bool digantikan)? onUnauthorized;

  Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Client': 'flutter',
    };
    if (withAuth) {
      final token = await _storage.read(key: 'auth_token');
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Semua request lewat sini:
  /// - sudah diketahui offline -> langsung gagal (tidak menunggu timeout)
  /// - gagal jaringan -> cek ulang koneksi; kalau memang offline lempar OfflineException
  Future<http.Response> _kirim(Future<http.Response> Function() request) async {
    if (connectivity?.isOffline ?? false) throw OfflineException();
    try {
      return await request().timeout(_timeout);
    } on SocketException catch (e) {
      return _gagalJaringan(e);
    } on http.ClientException catch (e) {
      return _gagalJaringan(e);
    } on TimeoutException catch (e) {
      return _gagalJaringan(e);
    }
  }

  Future<Never> _gagalJaringan(Object e) async {
    await connectivity?.check();
    if (connectivity?.isOffline ?? false) throw OfflineException();
    throw e; // online tapi server bermasalah: biarkan pesanError() yang menjelaskan
  }

  Future<dynamic> get(String path) async {
    final headers = await _headers();
    final res = await _kirim(() => http.get(Uri.parse('$baseUrl$path'), headers: headers));
    return _handle(res);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body, {bool withAuth = true}) async {
    final headers = await _headers(withAuth: withAuth);
    final res = await _kirim(() => http.post(
          Uri.parse('$baseUrl$path'),
          headers: headers,
          body: jsonEncode(body),
        ));
    return _handle(res, withAuth: withAuth);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final headers = await _headers();
    final res = await _kirim(() => http.put(
          Uri.parse('$baseUrl$path'),
          headers: headers,
          body: jsonEncode(body),
        ));
    return _handle(res);
  }

  Future<dynamic> delete(String path) async {
    final headers = await _headers();
    final res = await _kirim(() => http.delete(Uri.parse('$baseUrl$path'), headers: headers));
    return _handle(res);
  }

  Future<dynamic> postMultipart(
    String path, {
    required String fieldName,
    required List<int> bytes,
    required String filename,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _headers();
    headers.remove('Content-Type'); // biar package http yang atur boundary multipart otomatis

    final res = await _kirim(() async {
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);
      request.files.add(http.MultipartFile.fromBytes(fieldName, bytes, filename: filename));
      final streamed = await request.send();
      return http.Response.fromStream(streamed);
    });
    return _handle(res);
  }

  dynamic _handle(http.Response res, {bool withAuth = true}) {
    // Server menolak token: sesi berakhir. Login dengan password salah tidak
    // lewat sini (withAuth = false, dan backend membalas 422).
    if (res.statusCode == 401 && withAuth) {
      String? kode;
      try {
        final b = jsonDecode(res.body);
        if (b is Map) kode = b['code']?.toString();
      } catch (_) {}
      final digantikan = kode == 'session_replaced';

      onUnauthorized?.call(digantikan);
      throw ApiException(
        digantikan ? 'Akun kamu login di perangkat lain.' : 'Sesi kamu berakhir. Silakan login lagi.',
        statusCode: 401,
      );
    }

    final decoded = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return decoded;
    }
    final message = decoded is Map && decoded['message'] != null
        ? decoded['message']
        : 'Terjadi kesalahan (${res.statusCode})';
    throw ApiException(message.toString(), statusCode: res.statusCode);
  }

  Future<String?> readToken() async => _storage.read(key: 'auth_token');
  Future<void> saveToken(String token) async => _storage.write(key: 'auth_token', value: token);
  Future<void> clearToken() async => _storage.delete(key: 'auth_token');
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

/// Dilempar saat request tidak bisa dikirim karena perangkat offline.
class OfflineException implements Exception {
  final String message = 'Tidak ada koneksi internet. Sambungkan ke internet lalu coba lagi.';
  @override
  String toString() => message;
}