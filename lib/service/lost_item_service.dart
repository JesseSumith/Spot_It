import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../models/lost_item.dart';

class LostItemService {
  // For real device + ADB reverse:
  //   adb reverse tcp:8000 tcp:8000
  static const String baseUrl = 'http://127.0.0.1:8000';

  /// GET /posts/
  Future<List<LostItem>> fetchItems() async {
    final uri = Uri.parse('$baseUrl/posts/');
    print('📥 SERVICE.fetchItems → GET $uri');

    final response = await http.get(uri);
    print('📥 SERVICE.fetchItems → status=${response.statusCode}');

    if (response.statusCode != 200) {
      print('❌ SERVICE.fetchItems → body=${response.body}');
      throw Exception('Failed to load items: ${response.statusCode}');
    }

    final List<dynamic> data = jsonDecode(response.body);
    print('📥 SERVICE.fetchItems → received ${data.length} items');

    return data.map((json) => LostItem.fromJson(json)).toList();
  }

  /// POST /posts/ – JSON create (no image)
  Future<LostItem> createItem(LostItem item) async {
    final uri = Uri.parse('$baseUrl/posts/');
    final bodyMap = item.toCreateJson();
    final bodyJson = jsonEncode(bodyMap);

    print('📝 SERVICE.createItem (JSON only) → POST $uri');
    print('📝 SERVICE.createItem body = $bodyMap');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: bodyJson,
    );

    print(
      '📝 SERVICE.createItem ← status=${response.statusCode}, body=${response.body}',
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to create item: ${response.body}');
    }

    return LostItem.fromJson(jsonDecode(response.body));
  }

  /// POST /posts/ – Multipart create (with image file)
  Future<LostItem> createItemWithImage(LostItem item, String imagePath) async {
    final uri = Uri.parse('$baseUrl/posts/');
    final request = http.MultipartRequest('POST', uri);

    final data = item.toCreateJson();

    print('🟩 SERVICE.createItemWithImage → POST $uri');
    print('🟩 SERVICE.createItemWithImage raw data = $data');
    print('🟩 SERVICE.createItemWithImage imagePath = $imagePath');
    print(
      '🟩 SERVICE.createItemWithImage file exists? ${File(imagePath).existsSync()}',
    );

    // Booleans as "true"/"false" for Django
    data.forEach((key, value) {
      if (value is bool) {
        request.fields[key] = value ? 'true' : 'false';
      } else {
        request.fields[key] = value.toString();
      }
    });

    request.files.add(
      await http.MultipartFile.fromPath(
        'image', // Django ImageField name
        imagePath,
        filename: imagePath.split('/').last,
      ),
    );

    print('🟩 SERVICE.createItemWithImage fields → ${request.fields}');
    print(
      '🟩 SERVICE.createItemWithImage files count → ${request.files.length}',
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    print(
      '🟩 SERVICE.createItemWithImage ← status=${response.statusCode}, body=${response.body}',
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to upload item: ${response.body}');
    }

    return LostItem.fromJson(jsonDecode(response.body));
  }

  /// PATCH /posts/{id}/ – JSON update (no image change)
  Future<LostItem> updateItem(LostItem item) async {
    final uri = Uri.parse('$baseUrl/posts/${item.id}/');
    final bodyMap = item.toUpdateJson();
    final bodyJson = jsonEncode(bodyMap);

    print('✏️ SERVICE.updateItem → PATCH $uri');
    print('✏️ SERVICE.updateItem body = $bodyMap');

    final response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: bodyJson,
    );

    print(
      '✏️ SERVICE.updateItem ← status=${response.statusCode}, body=${response.body}',
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update item: ${response.body}');
    }

    return LostItem.fromJson(jsonDecode(response.body));
  }

  /// DELETE /posts/{id}/
  Future<void> deleteItem(int id) async {
    final uri = Uri.parse('$baseUrl/posts/$id/');
    print('🗑 SERVICE.deleteItem → DELETE $uri');

    final response = await http.delete(uri);

    print(
      '🗑 SERVICE.deleteItem ← status=${response.statusCode}, body=${response.body}',
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete item: ${response.body}');
    }
  }
}
