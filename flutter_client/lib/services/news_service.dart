import 'package:dio/dio.dart';

import '../models/news_item.dart';

class NewsService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://autodoc.ru',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  Future<(List<NewsItem>, int)> fetchLiveNews({
    required int offset,
    required int limit,
  }) async {
    try {
      final response = await _dio.get('/api/news/$offset/$limit');

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        final int totalCount = data['totalCount'] as int? ?? 0;
        final List<dynamic> newsJson = data['news'] as List<dynamic>? ?? [];

        final List<NewsItem> newsList = newsJson
            .map((json) => NewsItem.fromJson(json as Map<String, dynamic>))
            .toList();

        return (newsList, totalCount);
      }
      return (<NewsItem>[], 0);
    } catch (e) {
      return (<NewsItem>[], 0);
    }
  }
}
