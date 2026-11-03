import 'dart:async';
import 'package:flutter/widgets.dart';
import '../services/auth_service.dart';

/// Cek sesi ke server saat app kembali ke depan dan berkala selama app terbuka.
/// Kalau ditolak (401), ApiClient.onUnauthorized yang mengurus logout + dialog.
class SessionWatcher with WidgetsBindingObserver {
  final AuthService _auth;
  final Duration interval;
  Timer? _timer;
  bool _checking = false;

  SessionWatcher(this._auth, {this.interval = const Duration(seconds: 45)});

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(interval, (_) => _cek());
  }

  void stop() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _cek();
  }

  Future<void> _cek() async {
    if (_checking) return;
    _checking = true;
    try {
      if (!await _auth.hasToken()) return; // belum login
      await _auth.me();
    } catch (_) {
      // offline / server bermasalah: abaikan, coba lagi nanti
    } finally {
      _checking = false;
    }
  }
}