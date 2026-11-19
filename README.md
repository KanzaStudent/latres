# 🚀 SpaceFlight News App (Latres Praktikum TPM)

Aplikasi mobile berbasis **Flutter** untuk membaca berita, blog, dan laporan terkini seputar penerbangan luar angkasa dan astronomi secara real-time. Aplikasi ini mengintegrasikan konsumsi API publik, manajemen sesi autentikasi, penyimpanan data lokal (NoSQL), pembacaan web eksternal, dan notifikasi lokal Android.

Data utama diambil langsung dari [Spaceflight News API (SNAPI) v4](https://api.spaceflightnewsapi.net/v4/).

---

## 📋 Daftar Fitur & Kegunaannya

### 1. Registrasi Akun (`RegisterScreen`)
- **Kegunaan:** Memungkinkan pengguna baru mendaftarkan akun secara offline.
- **Cara Kerja:** Menerima input *Username* dan *Password*, memvalidasi agar tidak kosong, lalu menyimpannya ke penyimpanan lokal perangkat via `SharedPreferences`.

### 2. Autentikasi & Auto-Login (`LoginScreen`)
- **Kegunaan:** Memvalidasi identitas pengguna sebelum mengakses menu utama aplikasi.
- **Auto-Login:** Saat aplikasi pertama kali dibuka, sistem otomatis mengecek apakah ada sesi login aktif (`loginData == true`). Jika ada, pengguna langsung diarahkan ke `HomeScreen` tanpa perlu login berulang.
- **Validasi:** Mencocokkan input dengan akun yang terdaftar di `SharedPreferences`. Menampilkan `SnackBar` merah jika salah.

### 3. Dashboard Kategori Konten (`HomeScreen`)
- **Kegunaan:** Halaman beranda interaktif yang menyapa user berdasarkan username-nya (`Hai, {username}!`) dan menyediakan 3 menu kartu:
  - **News (`articles`):** Berita peluncuran roket, satelit, dan industri antariksa.
  - **Blog (`blogs`):** Artikel analisis mendalam dan blog dari komunitas astronomi.
  - **Reports (`reports`):** Laporan data resmi stasiun luar angkasa (ISS) dan misi antariksa.
- **Logout:** Menghapus sesi login di `SharedPreferences` dan mengembalikan user ke `LoginScreen`.

### 4. Daftar Konten & Filter Penulis (`ListScreen`)
- **Kegunaan:** Menampilkan kumpulan artikel dari endpoint API terkait dalam bentuk kartu (`Card` dan `ListTile`).
- **Filter Author (ChoiceChip):** Mengekstrak seluruh nama sumber/penulis unik dari data API dan menampilkannya dalam horizontal chip scrollbar (`All`, nama author 1, nama author 2, dst.). User dapat memfilter berita hanya dari author tertentu secara instan.
- **Handling Error & Loading:** Menyediakan indikator loading (`CircularProgressIndicator`) dan penanganan error jika koneksi terputus.

### 5. Detail Berita & Buka Web Asli (`DetailScreen`)
- **Kegunaan:** Menampilkan informasi lengkap artikel: gambar banner besar, judul lengkap, nama sumber/penulis, tanggal terbit, dan ringkasan isi berita.
- **Buka Browser Eksternal:** Tombol *Floating Action Button (FAB)* di pojok kanan bawah membuka tautan URL asli artikel di aplikasi browser eksternal (menggunakan package `url_launcher`).
- **Offline Fallback:** Jika jaringan internet mati saat membuka detail, aplikasi otomatis mencoba membaca data artikel dari database lokal Hive (jika artikel tersebut pernah disimpan ke favorit).

### 6. Bookmark Favorit Lokal NoSQL (`FavoriteScreen`)
- **Kegunaan:** Menyimpan artikel favorit pengguna ke dalam memori internal HP menggunakan database NoSQL cepat `Hive`.
- **Offline Availability:** Artikel yang telah difavoritkan tetap dapat dibaca sewaktu-waktu meskipun perangkat dalam mode offline (tanpa koneksi internet).
- **Reactivity:** Menggunakan `ValueListenableBuilder` sehingga perubahan data (tambah/hapus) langsung tercermin di UI secara otomatis tanpa perlu refresh manual.

### 7. Notifikasi Lokal (`NotificationService`)
- **Kegunaan:** Memberikan notifikasi sistem di status bar perangkat Android.
- **Immediate Notification:** Muncul secara instan saat pengguna menekan tombol favorit (menambahkan atau menghapus artikel).
- **Scheduled Notification:** Mendukung penjadwalan notifikasi di jam/tanggal tertentu dengan `timezone` (Asia/Jakarta) yang tetap berbunyi meskipun aplikasi telah ditutup.

---

## 🔄 Alur Kerja Aplikasi (Application Flow)

```
[Buka Aplikasi]
       │
       ▼
[Inisialisasi di main.dart] ── (Hive.init, NotificationService.init)
       │
       ▼
[LoginScreen] ── (Cek status auto-login di SharedPreferences)
   ├── Sudah Login  ──► Langsung menuju [HomeScreen]
   └── Belum Login  ──► Tampilkan Form Login / Register
                            │
                            ▼
                    [RegisterScreen] ── (Simpan akun ke SharedPreferences)
                            │
                            ▼
                       [HomeScreen]
         ┌──────────────────┼──────────────────┐
         ▼                  ▼                  ▼
   [Menu: News]       [Menu: Blog]      [Menu: Reports]
         └──────────────────┼──────────────────┘
                            ▼
                      [ListScreen]
                  (Fetch API via HTTP)
              (Filter Penulis via ChoiceChip)
                            │
                            ▼ (Tap Item)
                     [DetailScreen]
         ┌──────────────────┴──────────────────┐
         ▼                                     ▼
[Tombol Favorit]                         [Tombol Buka Web]
(Simpan/Hapus di Hive)                  (Buka browser eksternal)
(Kirim Notifikasi Lokal)
         │
         ▼
[FavoriteScreen] (Menampilkan daftar semua artikel tersimpan secara offline)
```

---

## 📁 Struktur File & Peranannya

| Direktori / File | Peran & Tanggung Jawab Utama |
|---|---|
| [`lib/main.dart`](file:///d:/semester%205/prak%20mobile/latres/lib/main.dart) | Entry point aplikasi. Menginisialisasi service notifikasi, Hive database, dan konfigurasi tema Material 3. |
| [`lib/api/api_service.dart`](file:///d:/semester%205/prak%20mobile/latres/lib/api/api_service.dart) | Modul HTTP Client. Menangani request GET ke endpoint Spaceflight News API (`/articles/`, `/blogs/`, `/reports/`). |
| [`lib/models/space_item.dart`](file:///d:/semester%205/prak%20mobile/latres/lib/models/space_item.dart) | Data model SpaceItem. Memiliki fungsi parser JSON (`fromJson`), serialisasi Map (`toMap`), dan deserialisasi (`fromMap`). |
| [`lib/services/notification_service.dart`](file:///d:/semester%205/prak%20mobile/latres/lib/services/notification_service.dart) | Singleton service untuk mengelola izin notifikasi, pembuatan Android notification channel, serta trigger notifikasi instan & terjadwal. |
| [`lib/screens/login_screen.dart`](file:///d:/semester%205/prak%20mobile/latres/lib/screens/login_screen.dart) | Tampilan login, validasi akun, dan pengecekan sesi auto-login dari SharedPreferences. |
| [`lib/screens/register_screen.dart`](file:///d:/semester%205/prak%20mobile/latres/lib/screens/register_screen.dart) | Tampilan registrasi untuk mendaftarkan akun baru ke SharedPreferences. |
| [`lib/screens/home_screen.dart`](file:///d:/semester%205/prak%20mobile/latres/lib/screens/home_screen.dart) | Dashboard navigasi utama untuk memilih kategori News, Blog, atau Reports, serta tombol Logout. |
| [`lib/screens/list_screen.dart`](file:///d:/semester%205/prak%20mobile/latres/lib/screens/list_screen.dart) | Menampilkan daftar artikel dari API beserta fitur interaktif filter penulis menggunakan ChoiceChip. |
| [`lib/screens/detail_screen.dart`](file:///d:/semester%205/prak%20mobile/latres/lib/screens/detail_screen.dart) | Menampilkan rincian lengkap artikel, aksi bookmark favorit (Hive), trigger notifikasi, dan tombol buka link eksternal. |
| [`lib/screens/favorite_screen.dart`](file:///d:/semester%205/prak%20mobile/latres/lib/screens/favorite_screen.dart) | Menampilkan daftar artikel favorit yang tersimpan di Hive secara offline dan menyediakan tombol hapus favorit. |

---

## 🛠️ Package & Dependensi

- **`http: ^1.6.0`**: Melakukan request API jaringan (REST HTTP GET).
- **`shared_preferences: ^2.5.6`**: Penyimpanan data ringan persisten (sesi login & akun).
- **`hive: ^2.2.3` & `hive_flutter: ^1.1.0`**: Database NoSQL berbasis key-value super cepat untuk bookmark offline.
- **`url_launcher: ^6.3.3`**: Membuka URL website di browser eksternal.
- **`flutter_local_notifications: ^19.0.0`**: Menampilkan notifikasi lokal di perangkat Android.
- **`timezone: ^0.10.0`**: Pengelolaan zona waktu lokal untuk penjadwalan alarm/notifikasi.

---

## 🚀 Panduan Menjalankan Proyek

1. **Clone repositori:**
   ```bash
   git clone <repo-url>
   cd latres
   ```

2. **Pasang seluruh dependensi:**
   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi (disarankan di emulator atau HP fisik):**
   ```bash
   flutter run
   ```
tambahan
git clone -b buat-responsi 
