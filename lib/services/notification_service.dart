// ==============================================================================
// FILE: lib/services/notification_service.dart
// DESKRIPSI: Service pengelola Notifikasi Lokal (Immediate & Scheduled Notification).
// ==============================================================================

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

// Class yang mengelola seluruh konfigurasi dan operasi notifikasi lokal di perangkat.
// Menerapkan pola "Singleton Pattern" agar hanya ada satu instance service di memori.
class NotificationService {
  // Instance privat statis untuk pola Singleton
  static final NotificationService _instance = NotificationService._internal();

  // Factory constructor yang selalu mengembalikan instance privat yang sama
  factory NotificationService() => _instance;

  // Named private constructor untuk mencegah instansiasi bebas dari luar class
  NotificationService._internal();

  // Objek plugin inti dari package `flutter_local_notifications`
  final FlutterLocalNotificationsPlugin notificationPlugin =
      FlutterLocalNotificationsPlugin();

  // ==========================================================================
  // METHOD: init()
  // TUJUAN: Menyiapkan segala kebutuhan notifikasi saat aplikasi baru berjalan.
  // ==========================================================================
  Future<void> init() async {
    // 1. Inisialisasi database zona waktu dunia dari package `timezone`
    tz.initializeTimeZones();
    // Mengatur lokasi zona waktu lokal aplikasi ke 'Asia/Jakarta' (WIB)
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    // 2. Konfigurasi platform Android: menggunakan icon launcher default aplikasi
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Menyatukan pengaturan platform ke dalam satu objek InitializationSettings
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    // Menjalankan inisialisasi plugin notifikasi dengan pengaturan yang sudah disiapkan
    await notificationPlugin.initialize(initSettings);

    // 3. Mengakses implementasi spesifik Android untuk perizinan dan channel
    final androidPlatform = notificationPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Menampilkan dialog popup izin notifikasi pada perangkat Android 13 (API level 33) ke atas
    await androidPlatform?.requestNotificationsPermission();

    // Membuat "Notification Channel" (kategori notifikasi yang wajib pada Android 8.0+)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'latres_channel', // ID unik channel (digunakan untuk mencocokkan saat posting notif)
      'Latres Notifications', // Nama channel yang dibaca user di pengaturan aplikasi
      description: 'Channel untuk notifikasi aplikasi Latres', // Deskripsi tujuan channel
      importance: Importance.high, // Prioritas tinggi agar memicu pop-up (heads-up banner)
    );

    // Mendaftarkan channel notifikasi ke sistem operasi Android
    await androidPlatform?.createNotificationChannel(channel);
  }

  // ==========================================================================
  // METHOD: showInstantNotification()
  // TUJUAN: Menampilkan notifikasi langsung (Immediate) saat fungsi ini dipanggil.
  // Digunakan saat: User menambahkan/menghapus berita dari daftar favorit.
  // ==========================================================================
  Future<void> showInstantNotification({
    required String title, // Judul notifikasi yang tebal di atas
    required String body, // Pesan isi/keterangan di bawah judul
  }) async {
    // Menentukan detail perilaku notifikasi untuk Android
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'latres_channel', // Harus sama persis dengan ID channel yang dibuat saat init()
      'Latres Notifications',
      importance: Importance.high, // Menentukan agar ada suara & getaran
      priority: Priority.high, // Prioritas tinggi di status bar
    );

    // Membungkus pengaturan platform Android ke dalam NotificationDetails
    const NotificationDetails notifDetails =
        NotificationDetails(android: androidDetails);

    // Menampilkan notifikasi ke layar perangkat
    await notificationPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // ID notif acak/unik berbasis timestamp
      title, // Teks judul
      body, // Teks pesan
      notifDetails, // Pengaturan channel & display
    );
  }

  // ==========================================================================
  // METHOD: scheduleNotification()
  // TUJUAN: Menjadwalkan notifikasi agar muncul otomatis di waktu yang ditentukan
  // (Scheduled Notification), tetap menyala meskipun aplikasi telah ditutup.
  // ==========================================================================
  Future<void> scheduleNotification({
    required int id, // ID spesifik untuk membedakan jadwal reminder
    required String title, // Judul notifikasi
    required String body, // Pesan notifikasi
    required DateTime scheduledTime, // Waktu (tanggal, jam, menit) kapan notif harus berbunyi
  }) async {
    // Pengaturan detail notifikasi Android
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'latres_channel',
      'Latres Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails notifDetails =
        NotificationDetails(android: androidDetails);

    // Mendaftarkan jadwal notifikasi ke alarm manager sistem operasi Android
    await notificationPlugin.zonedSchedule(
      id,
      title,
      body,
      // Mengonversi waktu DateTime standar menjadi format TZDateTime sesuai zona waktu lokal
      tz.TZDateTime(
        tz.local,
        scheduledTime.year,
        scheduledTime.month,
        scheduledTime.day,
        scheduledTime.hour,
        scheduledTime.minute,
      ),
      notifDetails,
      // Mode eksekusi alarm: tetap membunyikan notif tepat waktu meskipun perangkat dalam kondisi idle/sleep
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
