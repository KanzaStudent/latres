// ==============================================================================
// FILE: lib/screens/home_screen.dart
// DESKRIPSI: Halaman Beranda Utama Aplikasi (Dashboard Pemilihan Kategori).
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'list_screen.dart';

// Halaman utama setelah login berhasil.
// Menerima parameter `username` untuk ditampilkan sebagai salam di AppBar.
class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ==========================================================================
  // METHOD: _logout()
  // TUJUAN: Menghapus status login aktif di SharedPreferences dan redirect ke Login.
  // ==========================================================================
  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Mengubah flag loginData menjadi false agar sesi login dianggap selesai
    await prefs.setBool('loginData', false);

    if (mounted) {
      // Mengarahkan kembali ke LoginScreen dan menghapus seluruh tumpukan route sebelumnya
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false, // false = buang semua route sebelumnya agar tidak bisa di-back
      );
    }
  }

  // ==========================================================================
  // WIDGET HELPER: _menuCard()
  // TUJUAN: Template UI reusable untuk membuat kartu menu kategori berpenampilan rapi.
  // Parameter:
  // - icon: IconData simbol representasi menu.
  // - title: Judul menu (News, Blog, Reports).
  // - description: Penjelasan singkat mengenai isi kategori tersebut.
  // - onTap: Callback aksi saat kartu diklik.
  // ==========================================================================
  Widget _menuCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      color: const Color(0xFFFBF0F7), // Warna latar belakang kartu soft lavender/pink
      elevation: 0, // Kartu flat tanpa bayangan berlebihan
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Sudut membulat
        side: BorderSide(color: Colors.purple.shade50), // Garis tepi halus
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap, // Menjalankan navigasi saat area kartu ditekan
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kotak pembungkus ikon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE7F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF673AB7), size: 28),
              ),
              const SizedBox(width: 16),

              // Kolom teks judul dan keterangan menu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF6FB),
      appBar: AppBar(
        // Menampilkan sapaan dinamis berdasarkan username yang login
        title: Text(
          'Hai, ${widget.username}!',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4C6EF5),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Menghilangkan tombol arrow back di AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          children: [
            // ================================================================
            // MENU 1: NEWS (Endpoint: 'articles')
            // ================================================================
            _menuCard(
              icon: Icons.newspaper,
              title: 'News',
              description:
                  'Get an overview of the latest SpaceFlight news, from various sources! Easily link your users to the right websites.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ListScreen(
                      menu: 'articles', // Mengirim parameter endpoint artikel ke ListScreen
                      title: 'News', // Mengatur judul halaman list
                    ),
                  ),
                );
              },
            ),

            // ================================================================
            // MENU 2: BLOG (Endpoint: 'blogs')
            // ================================================================
            _menuCard(
              icon: Icons.article,
              title: 'Blog',
              description:
                  'Blogs often provide a more detailed overview of launches and missions. A must-have for the serious spaceflight enthusiast.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ListScreen(
                      menu: 'blogs', // Mengirim parameter endpoint blog
                      title: 'Blog',
                    ),
                  ),
                );
              },
            ),

            // ================================================================
            // MENU 3: REPORTS (Endpoint: 'reports')
            // ================================================================
            _menuCard(
              icon: Icons.bar_chart,
              title: 'Reports',
              description:
                  'Space stations and other missions often publish their data. With SNAPI, you can include it in your app.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ListScreen(
                      menu: 'reports', // Mengirim parameter endpoint report
                      title: 'Reports',
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Tombol Logout untuk keluar dari aplikasi
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935), // Warna merah peringatan
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 10),
                elevation: 1,
              ),
              child: const Text(
                'Log Out',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
