class NewsItem {
  final int id;
  final String? title;
  final String? description;
  final String? publishedDate;
  final String? categoryUrl;
  final String? imageUrl;

  NewsItem({
    required this.id,
    this.title,
    this.description,
    this.publishedDate,
    this.categoryUrl,
    this.imageUrl,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'] as int? ?? 0, 
      title: json['title'] as String?,
      description: json['description'] as String?,
      publishedDate: json['publishedDate'] as String?,
      categoryUrl: json['url'] as String?,
      imageUrl: json['titleImageUrl'] as String?,
    );
  }
}