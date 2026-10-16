import 'package:flutter/material.dart';

import '../news_bridge.dart';
import '../widgets/news_card.dart';
import '../generated/news.pb.dart' as proto;

class AutodocNewsScreen extends StatefulWidget {
  const AutodocNewsScreen({super.key});

  @override
  State<AutodocNewsScreen> createState() => _AutodocNewsScreenState();
}

class _AutodocNewsScreenState extends State<AutodocNewsScreen> {
  final NewsBridge _newsBridge = NewsBridge();
  final ScrollController _scrollController = ScrollController();

  List<proto.NewsItem> _newsItems = [];
  bool _isLoading = true;
  bool _isMoreLoading = false;
  String? _errorMessage;

  int _currentOffset = 1;
  final int _limit = 15;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  Future<void> _loadInitialData() async {
    try {
      _currentOffset = 1;
      final response = await _newsBridge.fetchLiveNews(
        offset: _currentOffset,
        limit: _limit,
      );
      setState(() {
        _newsItems = response.news;
        _isLoading = false;
        _hasMoreData = response.news.length == _limit;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка связи с сервером обновлений киоска';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreData() async {
    if (_isMoreLoading || !_hasMoreData) return;

    setState(() {
      _isMoreLoading = true;
    });

    try {
      final nextOffset = _currentOffset + 1;
      final response = await _newsBridge.fetchLiveNews(
        offset: nextOffset,
        limit: _limit,
      );

      setState(() {
        _currentOffset = nextOffset;
        _newsItems.addAll(response.news);
        _isMoreLoading = false;
        _hasMoreData = response.news.length == _limit;
      });
    } catch (e) {
      setState(() {
        _isMoreLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(strokeWidth: 4)),
      );
    }

    if (_errorMessage != null && _newsItems.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(fontSize: 24, color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Новости',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
              itemBuilder: (context, index) {
                final item = _newsItems[index];
                return NewsCard(newsItem: item);
              },
            ),
          ),
          if (_isMoreLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 4)),
            ),
        ],
      ),
    );
  }
}
