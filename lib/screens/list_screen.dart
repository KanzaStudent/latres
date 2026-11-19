// ==============================================================================
// FILE: lib/screens/list_screen.dart
// DESKRIPSI: Halaman Daftar Konten (News/Blog/Reports) dengan Fitur Filter Author.
// ==============================================================================

import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/space_item.dart';
import 'detail_screen.dart';
import 'favorite_screen.dart';

// Halaman menampilkan daftar item yang diambil secara asynchronous dari API.
// Menerima parameter:
// - `menu`: kategori yang akan di-fetch ('articles', 'blogs', 'reports')
// - `title`: judul header untuk AppBar
class ListScreen extends StatefulWidget {
  final String menu;
  final String title;

  const ListScreen({
    super.key,
    required this.menu,
    required this.title,
  });

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  // State 1: Menyimpan seluruh koleksi data SpaceItem yang didapat dari API
  List<SpaceItem> _items = [];

  // State 2: Menyimpan daftar nama author unik yang diekstrak dari item API (untuk filter chip)
  List<String> _authors = [];

  // State 3: Menyimpan author yang sedang dipilih oleh user (jika string kosong '', berarti 'All')
  String _selectedAuthor = '';

  // State 4: Status loading data (true jika sedang mengambil data jaringan)
  bool _isLoading = true;

  // State 5: Pesan error jika request API gagal
  String _errorMessage = '';

  // Lifecycle method: pertama kali dijalankan saat halaman dibuka
  @override
  void initState() {
    super.initState();
    // Memulai pemanggilan data API
    _fetchItems();
  }

  // ==========================================================================
  // METHOD: _fetchItems()
  // TUJUAN: Mengambil data dari ApiService, lalu menyaring author unik.
  // ==========================================================================
  Future<void> _fetchItems() async {
    try {
      // Memanggil fungsi HTTP GET pada ApiService sesuai kategori (widget.menu)
      final items = await ApiService.getItems(widget.menu);

      // Menggunakan Set agar otomatis menyaring nama author yang duplikat (hanya menyimpan nilai unik)
      final authorSet = <String>{};
      for (var item in items) {
        if (item.author.trim().isNotEmpty && item.author != 'Unknown') {
          authorSet.add(item.author.trim());
        }
      }

      // Memperbarui UI dengan data hasil fetch
      setState(() {
        _items = items;
        _authors = authorSet.toList(); // Mengubah Set menjadi List agar bisa dirender
        _isLoading = false; // Mematikan status loading
      });
    } catch (e) {
      // Menangkap error jika koneksi internet mati atau server bermasalah
      setState(() {
        _errorMessage = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Logika Filtering:
    // Jika _selectedAuthor kosong, tampilkan semua item (_items).
    // Jika _selectedAuthor terisi, saring hanya item yang author-nya sesuai pilihan.
    final displayedItems = _selectedAuthor.isEmpty
        ? _items
        : _items.where((element) => element.author == _selectedAuthor).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBF6FB),
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4C6EF5),
        foregroundColor: Colors.white,
        actions: [
          // Tombol icon hati di AppBar untuk membuka halaman FavoriteScreen
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            tooltip: 'Favorite',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoriteScreen()),
              );
            },
          ),
        ],
      ),
      // Kondisi 1: Tampilkan loader berputar jika data masih diambil
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          // Kondisi 2: Tampilkan pesan error jika request gagal
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              // Kondisi 3: Tampilkan list data dan filter bar
              : Column(
                  children: [
                    // ========================================================
                    // BARIS FILTER MENGGUNAKAN CHOICE CHIP (SCROLL HORIZONTAL)
                    // ========================================================
                    if (_authors.isNotEmpty)
                      Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ListView(
                          scrollDirection: Axis.horizontal, // Scroll mendatar ke samping
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            // Chip opsi 'All' (Menampilkan seluruh data tanpa filter)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: const Text('All'),
                                selected: _selectedAuthor.isEmpty,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedAuthor = ''; // Reset filter
                                  });
                                },
                              ),
                            ),
                            // Mapping setiap author unik menjadi ChoiceChip masing-masing
                            ..._authors.map((author) {
                              final isSelected = _selectedAuthor == author;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(author),
                                  selected: isSelected, // Status aktif jika sesuai yang dipilih
                                  onSelected: (selected) {
                                    setState(() {
                                      // Jika chip diklik, aktifkan author tersebut, jika unselect kembali ke ''
                                      _selectedAuthor = selected ? author : '';
                                    });
                                  },
                                ),
                              );
                            }),
                          ],
                        ),
                      ),

                    // ========================================================
                    // DAFTAR ITEM HASIL FILTER (LISTVIEW BUILDER)
                    // ========================================================
                    Expanded(
                      child: displayedItems.isEmpty
                          ? const Center(child: Text('Tidak ada data ditemukan'))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              itemCount: displayedItems.length, // Jumlah item yang dirender
                              itemBuilder: (context, index) {
                                final item = displayedItems[index];
                                return Card(
                                  color: const Color(0xFFFBF0F7),
                                  elevation: 0,
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: Colors.purple.shade50),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    // Thumbnail gambar artikel di sisi kiri (leading)
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.network(
                                        item.imageUrl,
                                        width: 75,
                                        height: 55,
                                        fit: BoxFit.cover, // Gambar dipotong proporsional memenuhi ukuran
                                        errorBuilder: (context, error, stackTrace) {
                                          // Tampilan fallback jika URL gambar rusak atau gagal dimuat
                                          return Container(
                                            width: 75,
                                            height: 55,
                                            color: Colors.grey.shade300,
                                            child: const Icon(Icons.broken_image, color: Colors.grey),
                                          );
                                        },
                                      ),
                                    ),
                                    // Judul artikel (maksimal 2 baris dengan ellipsis jika kepanjangan)
                                    title: Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    // Nama author / penerbit di bawah judul
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        item.author,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                    // Aksi klik item: membuka DetailScreen dengan parameter ID item tersebut
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailScreen(
                                            menu: widget.menu,
                                            id: item.id,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
