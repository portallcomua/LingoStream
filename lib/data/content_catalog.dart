class ContentItem {
  final String title;
  final String category;
  final String level;
  final String url;

  const ContentItem({
    required this.title,
    required this.category,
    required this.level,
    required this.url,
  });
}

const List<ContentItem> contentCatalog = [
  ContentItem(
    title: 'English Songs for Beginners',
    category: 'Пісні',
    level: 'Beginner',
    url: 'https://www.youtube.com/results?search_query=english+songs+with+lyrics+for+beginners',
  ),
  ContentItem(
    title: 'English Movie Scenes with Subtitles',
    category: 'Фільми',
    level: 'Beginner',
    url: 'https://www.youtube.com/results?search_query=english+movie+scenes+with+subtitles',
  ),
  ContentItem(
    title: 'Learn Ukrainian Songs',
    category: 'Українська',
    level: 'Beginner',
    url: 'https://www.youtube.com/results?search_query=ukrainian+songs+with+lyrics',
  ),
  ContentItem(
    title: 'English Cartoons with Subtitles',
    category: 'Мультфільми',
    level: 'Beginner',
    url: 'https://www.youtube.com/results?search_query=english+cartoons+with+subtitles',
  ),
];
