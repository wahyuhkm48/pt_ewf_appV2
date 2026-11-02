// viewmodels/nest_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../services/nest_service.dart';
import '../models/nest_model.dart';

class NestViewModel extends ChangeNotifier {
  final NestService _service;
  NestViewModel(this._service);

  bool isLoading = false;
  String? errorMessage;
  NestModel? result;

  // Penanda permintaan terbaru, supaya hasil permintaan lama diabaikan
  int _permintaan = 0;

  void reset() {
    _permintaan++; // batalkan hasil permintaan yang masih berjalan
    isLoading = false;
    result = null;
    errorMessage = null;
    notifyListeners();
  }

  Future<void> hitung({
    required String asset,
    required DateTime tanggal,
  }) async {
    final id = ++_permintaan;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final hasil = await _service.hitung(asset: asset, tanggal: tanggal);
      if (id != _permintaan) return; // sudah ada permintaan yang lebih baru
      result = hasil;
    } catch (e) {
      if (id != _permintaan) return;
      result = null;
      errorMessage = e.toString();
    } finally {
      if (id == _permintaan) {
        isLoading = false;
        notifyListeners();
      }
    }
  }
}