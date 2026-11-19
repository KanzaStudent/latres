// ==============================================================================
// FILE: lib/screens/detail_screen.dart
// DESKRIPSI: Halaman Detail Konten, Bookmark Favorit (Hive), dan Notifikasi Lokal.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api_service.dart';
import '../models/space_item.dart';
import '../services/notification_service.dart';

// Halaman untuk menampilkan rincian lengkap dari suatu artikel/blog/report.
// Menerima parameter:
// - `menu`: kategori konten ('articles', 'blogs', 'reports')
// - `id`: ID unik item yang akan diambil detailnya dari API atau Hive
class DetailScreen extends StatefulWidget {
  final String menu;
  final int id;

  const DetailScreen({
    super.key,
    required this.menu,
    required this.id,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // Objek model SpaceItem yang menampung data rincian
  SpaceItem? _item;

  // Status indikator loading
  bool _isLoading = true;

  // Pesan error jika data gagal dimuat
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Memulai pemanggilan detail data saat halaman dibuka
    _fetchDetail();
  }

  // ==========================================================================
  // METHOD: _fetchDetail()
  // TUJUAN: Mengambil data detail item dari API.
  // FITUR KHUSUS (FALLBACK OFFLINE):
  // Jika koneksi internet error/gagal, method ini otomatis mencari ke Hive
  // apakah data dengan ID ini pernah disimpan ke favorit. Jika ada, data lokal ditampilkan!
  // ==========================================================================
  Future<void> _fetchDetail() async {
    try {
      // 1. Mencoba mengambil data terbaru dari API secara online
      final item = await ApiService.getSingleItem(widget.menu, widget.id);
      setState(() {
        _item = item;
        _isLoading = false;
      });
    } catch (e) {
      // 2. Jika request online gagal, cek box penyimpanan lokal Hive
      final box = Hive.box('favorites');
      if (box.containsKey(widget.id.toString())) {
        final raw = box.get(widget.id.toString());
        setState(() {
          // Mengonversi data Map lokal menjadi objek SpaceItem
          _item = SpaceItem.fromMap(raw is Map ? raw : Map<dynamic, dynamic>.from(raw));
          _isLoading = false;
        });
      } else {
        // 3. Jika tidak ada di internet maupun di Hive, tampilkan pesan error
        setState(() {
          _errorMessage = 'Gagal memuat detail: $e';
          _isLoading = false;
        });
      }
    }
  }

  // ==========================================================================
  // METHOD: _launchUrl()
  // TUJUAN: Membuka link/URL artikel asli di aplikasi browser eksternal (Chrome, dll).
  // Menggunakan package `url_launcher`.
  // ==========================================================================
  Future<void> _launchUrl() async {
    if (_item != null && _item!.url.isNotEmpty) {
      final uri = Uri.parse(_item!.url);
      // Memeriksa apakah perangkat memiliki aplikasi untuk membuka URL ini
      if (await canLaunchUrl(uri)) {
        // Membuka tautan menggunakan browser eksternal (externalApplication)
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak dapat membuka link berita'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF6FB),
      appBar: AppBar(
        title: const Text('Detail', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4C6EF5),
        foregroundColor: Colors.white,
        actions: [
          // ==================================================================
          // TOMBOL FAVORIT DENGAN VALUE LISTENABLE BUILDER (HIVE)
          // Komponen ini otomatis me-rebuild dirinya saat box 'favorites' diubah.
          // ==================================================================
          ValueListenableBuilder(
            valueListenable: Hive.box('favorites').listenable(),
            builder: (context, box, child) {
              // Cek apakah ID item ini sudah tersimpan sebagai key di Hive box
              final isFav = box.containsKey(widget.id.toString());

              return IconButton(
                // Jika sudah favorit: icon hati merah penuh (favorite)
                // Jika belum favorit: icon garis hati putih (favorite_border)
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.white,
                ),
                tooltip: isFav ? 'Hapus Favorite' : 'Tambah Favorite',
                onPressed: () {
                  if (_item == null) return;

                  if (isFav) {
                    // AKSI 1: HAPUS DARI FAVORIT
                    box.delete(widget.id.toString()); // Menghapus key ID dari database Hive

                    // Memunculkan Immediate Notification lokal
                    NotificationService().showInstantNotification(
                      title: 'Dihapus dari Favorite',
                      body: _item!.title,
                    );

                    // Menampilkan feedback SnackBar di layar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dihapus dari favorite')),
                    );
                  } else {
                    // AKSI 2: TAMBAH KE FAVORIT
                    // Menyimpan data objek yang diubah ke Map ke dalam database Hive
                    box.put(widget.id.toString(), _item!.toMap());

                    // Memunculkan Immediate Notification lokal
                    NotificationService().showInstantNotification(
                      title: 'Ditambahkan ke Favorite! ⭐',
                      body: _item!.title,
                    );

                    // Menampilkan feedback SnackBar di layar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ditambahkan ke favorite')),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _item == null
                  ? const Center(child: Text('Data tidak ditemukan'))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ==================================================
                          // BANNER GAMBAR UTAMA BERUKURAN BESAR
                          // ==================================================
                          Image.network(
                            _item!.imageUrl,
                            width: double.infinity,
                            height: 260,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 260,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                              );
                            },
                          ),

                          // ==================================================
                          // KONTEN TEKS DETAIL ARTIKEL
                          // ==================================================
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Judul Lengkap Artikel
                                Text(
                                  _item!.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Nama Sumber Berita / Penulis
                                Text(
                                  _item!.author,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Tanggal & Waktu Publikasi
                                Text(
                                  _item!.publishedAt,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Ringkasan / Isi Rangkuman Berita
                                Text(
                                  _item!.summary,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.45,
                                    color: Colors.black87,
                                  ),
                                ),

                                const SizedBox(height: 70), // Jarak ruang ekstra agar teks terbawah tidak tertutup FloatingActionButton
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

      // ======================================================================
      // FLOATING ACTION BUTTON (FAB): Buka tautan artikel di web browser
      // ======================================================================
      floatingActionButton: FloatingActionButton(
        tooltip: 'Buka Web',
        backgroundColor: const Color(0xFFF3E5F5),
        foregroundColor: const Color(0xFF8E24AA),
        onPressed: _launchUrl, // Memanggil method _launchUrl saat tombol ditekan
        child: const Icon(Icons.open_in_new),
      ),
    );
  }
}
