// viewmodels/news_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../services/news_service.dart';
import '../models/news_model.dart';

class NewsViewModel extends ChangeNotifier {
  final NewsService _service;
  NewsViewModel(this._service);

  bool isLoading = false;
  String? errorMessage;
  List<NewsModel>? articles;

  Future<void> loadNews({bool forceRefresh = false}) async {
    if (articles != null && articles!.isNotEmpty && !forceRefresh) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      articles = await _service.getNews();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}