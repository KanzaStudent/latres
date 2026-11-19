// ==============================================================================
// FILE: lib/screens/register_screen.dart
// DESKRIPSI: Halaman Pendaftaran Akun Pengguna Baru ke penyimpanan lokal.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Menggunakan StatefulWidget untuk mengelola controller input pendaftaran
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controller untuk membaca input Username pendaftar
  final _usernameController = TextEditingController();

  // Controller untuk membaca input Password pendaftar
  final _passwordController = TextEditingController();

  // ==========================================================================
  // METHOD: _register()
  // TUJUAN: Memvalidasi input dan menyimpan username & password ke SharedPreferences.
  // ==========================================================================
  void _register() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Validasi form: memastikan username dan password tidak boleh kosong
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username dan Password tidak boleh kosong!'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Berhenti jika tidak valid
    }

    // Mendapatkan instance SharedPreferences lokal
    final prefs = await SharedPreferences.getInstance();

    // Menyimpan kredensial pendaftaran ke key 'registered_username' dan 'registered_password'
    await prefs.setString('registered_username', username);
    await prefs.setString('registered_password', password);

    // Memberitahu pengguna bahwa pendaftaran berhasil dan kembali ke halaman Login
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan login.'),
          backgroundColor: Colors.green,
        ),
      );
      // Menutup halaman register dan kembali ke halaman LoginScreen sebelumnya
      Navigator.pop(context);
    }
  }

  // Membersihkan resource controller saat widget dihancurkan
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF6FB),
      appBar: AppBar(
        title: const Text('Register', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4C6EF5),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Judul formulir pendaftaran
              const Text(
                'Daftar Akun Baru',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 28),

              // Input TextField untuk nama akun baru
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Masukkan username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Input TextField untuk password baru (disamarkan)
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Masukkan password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),

              // Tombol untuk memicu pendaftaran akun
              ElevatedButton(
                onPressed: _register,
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
                child: const Text('Daftar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
