// viewmodels/pivot_point_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../services/pivot_point_service.dart';
import '../models/pivot_point_model.dart';

class PivotPointViewModel extends ChangeNotifier {
  final PivotPointService _service;
  PivotPointViewModel(this._service);

  bool isLoading = false;
  String? errorMessage;
  PivotPointModel? result;

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
      result = null; // jangan tampilkan hasil lama di samping pesan error
      errorMessage = e.toString();
    } finally {
      if (id == _permintaan) {
        isLoading = false;
        notifyListeners();
      }
    }
  }
}