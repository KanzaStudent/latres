import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/space_item.dart';

class ApiService {
  static const String baseUrl = 'https://api.spaceflightnewsapi.net/v4';

  static Future<List<SpaceItem>> getItems(String menu) async {
    final response = await http.get(Uri.parse('$baseUrl/$menu/'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List rawList = data['results'] ?? [];
      return rawList.map((e) => SpaceItem.fromJson(e, menu: menu)).toList();
    } else {
      throw Exception('Failed to load $menu');
    }
  }

  static Future<SpaceItem> getSingleItem(String menu, int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$menu/$id/'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return SpaceItem.fromJson(data, menu: menu);
    } else {
      throw Exception('Failed to load item detail');
    }
  }
}
