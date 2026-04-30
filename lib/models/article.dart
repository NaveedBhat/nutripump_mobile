class Article {
  final String id;
  final String title;
  final String content;
  final String summary;
  final String imageUrl;
  final String category;
  final String author;
  final DateTime publishedAt;
  final int readTimeMinutes;

  const Article({
    required this.id,
    required this.title,
    required this.content,
    required this.summary,
    required this.imageUrl,
    required this.category,
    required this.author,
    required this.publishedAt,
    required this.readTimeMinutes,
  });
}
