// ==============================================================================
// FILE: lib/main.dart
// DESKRIPSI: Entry point (titik awal eksekusi) seluruh aplikasi Flutter.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/login_screen.dart';
import 'services/notification_service.dart';

// Fungsi utama yang pertama kali dijalankan oleh Dart runtime saat aplikasi dibuka.
// Diberi modifier `async` karena ada proses inisialisasi yang membutuhkan waktu (asynchronous).
void main() async {
  // Memastikan bahwa framework engine Flutter telah siap sebelum menjalankan kode async lainnya
  // (wajib dipanggil jika ada inisialisasi plugin/storage sebelum `runApp`).
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi service notifikasi lokal (meminta izin, konfigurasi timezone, dan membuat channel Android).
  await NotificationService().init();

  // Inisialisasi library Hive untuk penyimpanan data lokal berbasis key-value NoSQL.
  await Hive.initFlutter();

  // Membuka box (tabel/koleksi) bernama 'favorites' agar siap digunakan untuk CRUD data favorit.
  await Hive.openBox('favorites');

  // Menjalankan widget root (induk) aplikasi ke layar.
  runApp(const MainApp());
}

// Widget utama yang membungkus keseluruhan struktur MaterialApp.
// Menggunakan StatelessWidget karena properti tema dan konfigurasi dasarnya statis.
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Judul aplikasi yang muncul pada task switcher sistem operasi.
      title: 'SpaceFlight News App',

      // Menghilangkan banner merah bertuliskan "DEBUG" di pojok kanan atas layar.
      debugShowCheckedModeBanner: false,

      // Konfigurasi tema global aplikasi dengan palet warna dasar biru modern (0xFF4C6EF5).
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4C6EF5)),
        useMaterial3: true, // Mengaktifkan spesifikasi desain Material 3
      ),

      // Menetapkan halaman pertama kali yang tampil saat aplikasi dibuka (halaman Login).
      home: const LoginScreen(),
    );
  }
}
