import 'package:flutter/material.dart';

import '../services/news_service.dart';
import '../models/news_item.dart';
import '../widgets/news_card.dart';

class AutodocNewsScreen extends StatefulWidget {
  const AutodocNewsScreen({super.key});

  @override
  State<AutodocNewsScreen> createState() => _AutodocNewsScreenState();
}

class _AutodocNewsScreenState extends State<AutodocNewsScreen> {
  final NewsService _newsService = NewsService();
  final ScrollController _scrollController = ScrollController();

  final List<NewsItem> _newsItems = [];
  bool _hasMoreData = false;
  bool _isLoading = false;

  final int _limit = 15;

  @override
  void initState() {
    super.initState();
    _loadNews(isRefresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadNews({bool isRefresh = false}) async {
    if (_isLoading || (!isRefresh && !_hasMoreData)) return;

    setState(() => _isLoading = true);

    final int currentOffset = isRefresh || _newsItems.isEmpty
        ? 1
        : _newsItems.length;
    final (news, _) = await _newsService.fetchLiveNews(
      offset: currentOffset,
      limit: _limit,
    );

    if (mounted) {
      setState(() {
        if (isRefresh) _newsItems.clear();

        _newsItems.addAll(news);
        _hasMoreData = news.length == _limit;

        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadNews(isRefresh: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _newsItems.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Новости'), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              itemCount: _newsItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) =>
                  NewsCard(newsItem: _newsItems[index]),
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
