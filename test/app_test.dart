import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latres/models/space_item.dart';
import 'package:latres/screens/login_screen.dart';
import 'package:latres/screens/register_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SpaceItem Model Tests', () {
    test('fromJson parses correctly with news_site', () {
      final json = {
        'id': 101,
        'title': 'Test Rocket Launch',
        'url': 'https://example.com/launch',
        'image_url': 'https://example.com/image.jpg',
        'news_site': 'NASA',
        'summary': 'This is a test summary for the launch.',
        'published_at': '2026-11-18T10:00:00Z',
        'authors': [
          {'name': 'John Doe'}
        ],
      };

      final item = SpaceItem.fromJson(json, menu: 'articles');
      expect(item.id, 101);
      expect(item.title, 'Test Rocket Launch');
      expect(item.url, 'https://example.com/launch');
      expect(item.imageUrl, 'https://example.com/image.jpg');
      expect(item.newsSite, 'NASA');
      expect(item.author, 'NASA');
      expect(item.summary, 'This is a test summary for the launch.');
      expect(item.publishedAt, '2026-11-18T10:00:00Z');
      expect(item.menu, 'articles');
    });

    test('toMap and fromMap work correctly for local storage', () {
      final original = SpaceItem(
        id: 202,
        title: 'Blog Post',
        url: 'https://example.com/blog',
        imageUrl: 'https://example.com/blog.png',
        newsSite: 'SpaceX',
        summary: 'Blog summary',
        publishedAt: '2026-11-18T12:00:00Z',
        author: 'SpaceX',
        menu: 'blogs',
      );

      final map = original.toMap();
      final restored = SpaceItem.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.url, original.url);
      expect(restored.imageUrl, original.imageUrl);
      expect(restored.newsSite, original.newsSite);
      expect(restored.author, original.author);
      expect(restored.summary, original.summary);
      expect(restored.publishedAt, original.publishedAt);
      expect(restored.menu, original.menu);
    });
  });

  group('Login & Register UI Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('LoginScreen renders UI correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      expect(find.text('Silakan Login'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Login'), findsNWidgets(2)); // AppBar and Button
      expect(find.text('Belum punya akun? Daftar di sini'), findsOneWidget);
    });

    testWidgets('LoginScreen shows red snackbar on failed login', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Tap Login button directly without registered account
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Login Gagal! Pastikan sudah Register atau cek password.'), findsOneWidget);
    });

    testWidgets('RegisterScreen validates empty fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterScreen(),
        ),
      );

      expect(find.text('Daftar Akun Baru'), findsOneWidget);

      // Tap Daftar without input
      await tester.tap(find.widgetWithText(ElevatedButton, 'Daftar'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Username dan Password tidak boleh kosong!'), findsOneWidget);
    });
  });
}
