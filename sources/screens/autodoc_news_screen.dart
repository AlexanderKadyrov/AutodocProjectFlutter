import 'package:flutter/material.dart';
import '../models/news_item.dart';
import '../services/news_service.dart';
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
  bool _isLoading = true;
  bool _isMoreLoading = false;
  bool _hasMoreData = true;

  int _currentOffset = 1;
  final int _limit = 15;

  @override
  void initState() {
    super.initState();
    _loadInitialNews();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialNews() async {
    final (news, _) = await _newsService.fetchLiveNews(offset: _currentOffset, limit: _limit);
    
    if (mounted) {
      setState(() {
        _newsItems.addAll(news);
        _isLoading = false;
        _hasMoreData = news.length == _limit;
      });
    }
  }

  Future<void> _loadMoreNews() async {
    if (_isMoreLoading || !_hasMoreData) return;

    setState(() => _isMoreLoading = true);
    _currentOffset += _limit; 
    
    final (news, _) = await _newsService.fetchLiveNews(offset: _currentOffset, limit: _limit);

    if (mounted) {
      setState(() {
        _newsItems.addAll(news);
        _isMoreLoading = false;
        _hasMoreData = news.length == _limit;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreNews();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(strokeWidth: 4)));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Новости', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: true,
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
              itemBuilder: (context, index) => NewsCard(newsItem: _newsItems[index]),
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
