// ==============================================================================
// FILE: lib/screens/login_screen.dart
// DESKRIPSI: Halaman Autentikasi Login Pengguna dengan fitur Auto-Login.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'register_screen.dart';

// Menggunakan StatefulWidget karena halaman ini mengelola state dinamis
// (input text controller, validasi error, dan pengecekan sesi login).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller untuk membaca dan mengontrol teks input field Username
  final _usernameController = TextEditingController();

  // Controller untuk membaca dan mengontrol teks input field Password
  final _passwordController = TextEditingController();

  // Lifecycle method: dipanggil otomatis satu kali saat widget pertama kali dibuat
  @override
  void initState() {
    super.initState();
    // Memeriksa status login yang tersimpan sebelumnya (fitur auto-login)
    _checkLogin();
  }

  // ==========================================================================
  // METHOD: _checkLogin()
  // TUJUAN: Mengecek apakah pengguna sebelumnya sudah berhasil login.
  // Jika ya, langsung bypass/arahkan ke HomeScreen tanpa perlu input ulang.
  // ==========================================================================
  void _checkLogin() async {
    // Membuka instance penyimpanan preferensi lokal (SharedPreferences)
    final prefs = await SharedPreferences.getInstance();

    // Membaca boolean status login (default false jika belum pernah disimpan)
    final isLoggedIn = prefs.getBool('loginData') ?? false;

    // Membaca nama pengguna yang tersimpan
    final username = prefs.getString('username') ?? '';

    // `mounted` memastikan widget masih aktif di layar sebelum navigasi dijalankan
    if (isLoggedIn && mounted) {
      // Mengganti halaman Login dengan HomeScreen (menghapus riwayat back)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(username: username)),
      );
    }
  }

  // ==========================================================================
  // METHOD: _login()
  // TUJUAN: Memvalidasi kredensial login pengguna terhadap data pendaftaran.
  // ==========================================================================
  void _login() async {
    // Mengambil nilai teks input dan membersihkan spasi di awal/akhir
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Membaca data akun yang tersimpan dari SharedPreferences saat Register
    final prefs = await SharedPreferences.getInstance();
    final regUser = prefs.getString('registered_username');
    final regPass = prefs.getString('registered_password');

    // Kondisi 1: Jika belum pernah ada akun yang didaftarkan sama sekali
    if (regUser == null || regPass == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Gagal! Pastikan sudah Register atau cek password.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Kondisi 2: Kredensial cocok dengan data yang terdaftar
    if (username.isNotEmpty && username == regUser && password == regPass) {
      // Menyimpan status bahwa user sudah dalam kondisi login aktif
      await prefs.setBool('loginData', true);
      // Menyimpan nama username sesi saat ini
      await prefs.setString('username', username);

      if (mounted) {
        // Navigasi ke HomeScreen dan menghapus halaman login dari stack
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(username: username)),
        );
      }
    } else {
      // Kondisi 3: Username atau password salah
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Gagal! Pastikan sudah Register atau cek password.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Lifecycle method: membersihkan resource controller dari memori saat widget dihancurkan
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF6FB), // Latar belakang abu/ungu lembut
      appBar: AppBar(
        title: const Text('Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4C6EF5), // Warna biru tema utama
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      body: Center(
        // SingleChildScrollView mencegah layout overflow saat keyboard virtual HP muncul
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Judul teks sambutan
              const Text(
                'Silakan Login',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 28),

              // Form Input Field untuk Username
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'rahman',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20), // Border melengkung (rounded)
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Form Input Field untuk Password
              TextField(
                controller: _passwordController,
                obscureText: true, // Menyembunyikan karakter password dengan tanda bintang/titik
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: '•••••',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),

              // Tombol untuk memicu eksekusi method _login
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEFE6F3),
                  foregroundColor: Colors.black87,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Colors.black12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: const Text('Login'),
              ),
              const SizedBox(height: 12),

              // Tombol navigasi menuju halaman Registrasi jika belum punya akun
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                child: const Text(
                  'Belum punya akun? Daftar di sini',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
