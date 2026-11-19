// ==============================================================================
// FILE: lib/screens/favorite_screen.dart
// DESKRIPSI: Halaman Daftar Berita Favorit yang Disimpan di Database Lokal Hive.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/space_item.dart';
import 'detail_screen.dart';

// Halaman menampilkan kumpulan artikel yang telah dibookmark/difavoritkan.
// Menggunakan StatelessWidget karena perubahan state dikelola langsung oleh
// ValueListenableBuilder yang mendengarkan perubahan data di Hive box.
class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF6FB),
      appBar: AppBar(
        title: const Text('Favorite', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4C6EF5),
        foregroundColor: Colors.white,
      ),

      // ======================================================================
      // VALUE LISTENABLER BUILDER
      // Mendengarkan perubahan data pada box 'favorites'. Setiap kali ada data
      // yang di-add atau di-delete dari Hive, builder ini otomatis me-render ulang UI.
      // ======================================================================
      body: ValueListenableBuilder(
        valueListenable: Hive.box('favorites').listenable(),
        builder: (context, Box box, child) {
          // Kondisi jika belum ada data yang difavoritkan
          if (box.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada data favourite',
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            );
          }

          // Mengambil semua key (kunci unik / ID artikel) yang tersimpan di dalam box
          final keys = box.keys.toList();

          // Menampilkan data favorit dalam bentuk ListView
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: keys.length, // Jumlah item favorit tersimpan
            itemBuilder: (context, index) {
              final key = keys[index];
              // Mengambil data mentah (Map) berdasarkan key
              final raw = box.get(key);

              // Jika data null/kosong, render widget kosong
              if (raw == null) return const SizedBox.shrink();

              // Mengonversi Map mentah dari Hive menjadi objek model SpaceItem
              final item = SpaceItem.fromMap(raw is Map ? raw : Map<dynamic, dynamic>.from(raw));

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

                  // Gambar thumbnail artikel di sisi kiri (leading)
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      item.imageUrl,
                      width: 75,
                      height: 55,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 75,
                          height: 55,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        );
                      },
                    ),
                  ),

                  // Judul artikel favorit (maksimal 2 baris)
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

                  // Nama penulis / sumber berita
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

                  // Tombol Hapus Favorit di sisi kanan (trailing)
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    tooltip: 'Hapus Favorite',
                    onPressed: () {
                      // Menghapus data dari database Hive berdasarkan key ID-nya
                      box.delete(key);

                      // Menampilkan feedback SnackBar bahwa item telah dihapus
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dihapus dari favorite')),
                      );
                    },
                  ),

                  // Saat kartu ditekan: navigasi ke DetailScreen untuk membaca rincian artikel
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(
                          menu: item.menu, // Kategori asal item
                          id: item.id, // ID item
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
