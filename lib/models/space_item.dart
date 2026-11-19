// ==============================================================================
// FILE: lib/models/space_item.dart
// DESKRIPSI: Model data yang merepresentasikan satu item berita, blog, atau report.
// ==============================================================================

class SpaceItem {
  final int id; // ID unik dari artikel/blog/report (primary key)
  final String title; // Judul artikel atau berita
  final String url; // Tautan/URL asli menuju website penerbit berita
  final String imageUrl; // URL gambar thumbnail/banner yang disediakan oleh API
  final String newsSite; // Nama situs/penerbit (contoh: SpaceNews, NASA, NASASpaceflight)
  final String summary; // Deskripsi singkat / ringkasan isi berita
  final String publishedAt; // Tanggal dan waktu publikasi artikel (format string ISO)
  final String author; // Nama penulis atau sumber berita (fallback ke newsSite jika kosong)
  final String menu; // Kategori menu item ini berasal ('articles', 'blogs', atau 'reports')

  // Constructor standar untuk inisialisasi semua properti model SpaceItem
  SpaceItem({
    required this.id,
    required this.title,
    required this.url,
    required this.imageUrl,
    required this.newsSite,
    required this.summary,
    required this.publishedAt,
    required this.author,
    this.menu = 'articles', // Nilai default jika parameter kategori tidak diisi
  });

  // Factory constructor: Mengubah data format JSON (Map dari API) menjadi objek SpaceItem.
  // Method ini menangani variasi struktur JSON dari API SNAPI v4.
  factory SpaceItem.fromJson(Map<String, dynamic> json, {String menu = 'articles'}) {
    String authorName = '';

    // Logika penentuan nama author/sumber:
    // 1. Cek properti 'news_site' terlebih dahulu
    if (json['news_site'] != null && json['news_site'].toString().trim().isNotEmpty) {
      authorName = json['news_site'].toString().trim();
    // 2. Jika tidak ada, cek array 'authors' dan ambil nama author pertama
    } else if (json['authors'] != null && (json['authors'] as List).isNotEmpty) {
      authorName = json['authors'][0]['name']?.toString() ?? 'Unknown';
    // 3. Jika keduanya tidak ada, gunakan fallback string 'Unknown'
    } else {
      authorName = 'Unknown';
    }

    // Mengembalikan instance SpaceItem dengan pengamanan null (null safety fallback)
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

  // Method toMap: Mengubah objek SpaceItem menjadi Map<String, dynamic>.
  // Sangat penting untuk menyimpan objek ini ke database lokal Hive (NoSQL key-value store).
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

  // Factory constructor fromMap: Mengonversi kembali Map yang diambil dari Hive menjadi objek SpaceItem.
  // Menggunakan type `Map<dynamic, dynamic>` karena data mentah yang dikembalikan Hive berbentuk map dynamic.
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
