// ==============================================================================
// FILE: lib/api/api_service.dart
// DESKRIPSI: Service HTTP yang menangani komunikasi jaringan (networking) ke API.
// ==============================================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/space_item.dart';

// Class statis yang berfungsi sebagai penyedia layanan API (Spaceflight News API v4).
// Menggunakan static method agar fungsi bisa langsung dipanggil tanpa instansiasi objek (misal: ApiService.getItems()).
class ApiService {
  // Alamat dasar (endpoint utama) dari API publik Spaceflight News versi 4.
  static const String baseUrl = 'https://api.spaceflightnewsapi.net/v4';

  // Method untuk mengambil daftar banyak item (list) dari API.
  // Parameter:
  // - [menu]: string kategori endpoint yang ingin diakses ('articles', 'blogs', atau 'reports').
  // Return value:
  // - Future bertipe List objek SpaceItem yang sudah di-parse dari JSON.
  static Future<List<SpaceItem>> getItems(String menu) async {
    // Melakukan HTTP GET request ke URL: https://api.spaceflightnewsapi.net/v4/{menu}/
    final response = await http.get(Uri.parse('$baseUrl/$menu/'));

    // Cek apakah status response adalah 200 (OK / Berhasil)
    if (response.statusCode == 200) {
      // Mengubah string mentah JSON response body menjadi tipe data Map/List Dart
      final data = jsonDecode(response.body);

      // Struktur JSON API SNAPI v4 membungkus data list di dalam properti key 'results'
      final List rawList = data['results'] ?? [];

      // Melakukan iterasi (mapping) dari setiap JSON objek menjadi objek model SpaceItem, lalu diubah ke List
      return rawList.map((e) => SpaceItem.fromJson(e, menu: menu)).toList();
    } else {
      // Melempar error/exception jika status code selain 200 (misal: 404, 500)
      throw Exception('Failed to load $menu');
    }
  }

  // Method untuk mengambil detail satu item secara spesifik berdasarkan ID.
  // Parameter:
  // - [menu]: string kategori endpoint ('articles', 'blogs', atau 'reports').
  // - [id]: integer ID unik dari item yang dicari.
  // Return value:
  // - Future bertipe objek tunggal SpaceItem.
  static Future<SpaceItem> getSingleItem(String menu, int id) async {
    // Melakukan HTTP GET request ke URL spesifik: https://api.spaceflightnewsapi.net/v4/{menu}/{id}/
    final response = await http.get(Uri.parse('$baseUrl/$menu/$id/'));

    // Cek apakah data berhasil didapatkan
    if (response.statusCode == 200) {
      // Decode isi response JSON menjadi Map<String, dynamic>
      final data = jsonDecode(response.body);

      // Parse Map JSON menjadi satu objek SpaceItem lengkap
      return SpaceItem.fromJson(data, menu: menu);
    } else {
      // Melempar error jika gagal mengambil detail item
      throw Exception('Failed to load item detail');
    }
  }
}
