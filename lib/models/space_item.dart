class SpaceItem {
  final int id;
  final String title;
  final String url;
  final String imageUrl;
  final String newsSite;
  final String summary;
  final String publishedAt;
  final String author;
  final String menu;

  SpaceItem({
    required this.id,
    required this.title,
    required this.url,
    required this.imageUrl,
    required this.newsSite,
    required this.summary,
    required this.publishedAt,
    required this.author,
    this.menu = 'articles',
  });

  factory SpaceItem.fromJson(Map<String, dynamic> json, {String menu = 'articles'}) {
    String authorName = '';
    if (json['news_site'] != null && json['news_site'].toString().trim().isNotEmpty) {
      authorName = json['news_site'].toString().trim();
    } else if (json['authors'] != null && (json['authors'] as List).isNotEmpty) {
      authorName = json['authors'][0]['name']?.toString() ?? 'Unknown';
    } else {
      authorName = 'Unknown';
    }

    return SpaceItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['image_url'] ?? '',
      newsSite: json['news_site'] ?? authorName,
      summary: json['summary'] ?? '',
      publishedAt: json['published_at'] ?? '',
      author: authorName,
      menu: menu,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'image_url': imageUrl,
      'news_site': newsSite,
      'summary': summary,
      'published_at': publishedAt,
      'author': author,
      'menu': menu,
    };
  }

  factory SpaceItem.fromMap(Map<dynamic, dynamic> map) {
    return SpaceItem(
      id: map['id'] ?? 0,
      title: map['title'] ?? '',
      url: map['url'] ?? '',
      imageUrl: map['image_url'] ?? '',
      newsSite: map['news_site'] ?? '',
      summary: map['summary'] ?? '',
      publishedAt: map['published_at'] ?? '',
      author: map['author'] ?? map['news_site'] ?? 'Unknown',
      menu: map['menu'] ?? 'articles',
    );
  }
}
