// services/histori_service.dart
import '../core/api_client.dart';
import '../models/histori_data_model.dart';

class HistoriService {
  final ApiClient _client;
  HistoriService(this._client);

  Future<List<HistoriDataModel>> gold() async {
    final res = await _client.get('/histori/gold?limit=10');
    return (res['data'] ?? res).map<HistoriDataModel>((e) => HistoriDataModel.fromJson(e)).toList();
  }

  Future<List<HistoriDataModel>> nikkei() async {
    final res = await _client.get('/histori/nikkei?limit=10');
    return (res['data'] ?? res).map<HistoriDataModel>((e) => HistoriDataModel.fromJson(e)).toList();
  }

  Future<List<HistoriDataModel>> hangseng() async {
    final res = await _client.get('/histori/hangseng?limit=10');
    return (res['data'] ?? res).map<HistoriDataModel>((e) => HistoriDataModel.fromJson(e)).toList();
  }
}