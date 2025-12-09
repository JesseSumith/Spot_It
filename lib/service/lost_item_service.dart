import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/lost_item.dart';

class LostItemService {
  // Change to 'http://127.0.0.1:8000' if you're using adb reverse on a real device.
  static const String baseUrl = 'http://127.0.0.1:8000';

  /// GET /posts/
  Future<List<LostItem>> fetchItems() async {
    final uri = Uri.parse('$baseUrl/posts/');

    final response = await http.get(uri);

    print('⬅️ FETCH status: ${response.statusCode}');
    print('⬅️ FETCH body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to load items: ${response.statusCode}');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => LostItem.fromJson(json)).toList();
  }

  /// POST /posts/ – JSON create (no image)
  Future<LostItem> createItem(LostItem item) async {
    final uri = Uri.parse('$baseUrl/posts/');

    final bodyMap = item.toCreateJson(); // only Django fields
    print('📝 CREATE(JSON) body: $bodyMap');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bodyMap),
    );

    print('⬅️ CREATE(JSON) status: ${response.statusCode}');
    print('⬅️ CREATE(JSON) body: ${response.body}');

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
        'Failed to create item: ${response.statusCode} ${response.body}',
      );
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return LostItem.fromJson(data);
  }

  /// POST /posts/ – Multipart create (with image file)
  Future<LostItem> createItemWithImage(LostItem item, String imagePath) async {
    final uri = Uri.parse('$baseUrl/posts/');

    final request = http.MultipartRequest('POST', uri);

    // Text fields (must match Django model: is_lost, title, description, location_text, contact_name, contact_method)
    final data = item.toCreateJson();
    print('📷 CREATE(MULTIPART) fields: $data, imagePath=$imagePath');

    data.forEach((key, value) {
      request.fields[key] = value.toString(); // bool -> "true"/"false"
    });

    // File field name must match Django ImageField: "image"
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imagePath,
        filename: imagePath.split('/').last,
      ),
    );

    // Do NOT set Content-Type manually, MultipartRequest does it.
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    print('⬅️ CREATE(MULTIPART) status: ${response.statusCode}');
    print('⬅️ CREATE(MULTIPART) body: ${response.body}');

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
        'Failed to create item with image: ${response.statusCode} ${response.body}',
      );
    }

    final Map<String, dynamic> json = jsonDecode(response.body);
    return LostItem.fromJson(json);
  }

  /// PATCH /posts/{id}/ – JSON text-only update (no image change)
  Future<LostItem> updateItem(LostItem item) async {
    final uri = Uri.parse('$baseUrl/posts/${item.id}/');

    final bodyMap = item.toUpdateJson();
    print('🛠 UPDATE(JSON) body: $bodyMap');

    final response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bodyMap),
    );

    print('⬅️ UPDATE(JSON) status: ${response.statusCode}');
    print('⬅️ UPDATE(JSON) body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update item: ${response.statusCode} ${response.body}',
      );
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return LostItem.fromJson(data);
  }

  /// PATCH /posts/{id}/ – Multipart update with image
  Future<LostItem> updateItemWithImage(LostItem item, String imagePath) async {
    final uri = Uri.parse('$baseUrl/posts/${item.id}/');

    final request = http.MultipartRequest('PATCH', uri);

    final data = item.toUpdateJson();
    print('📷 UPDATE(MULTIPART) fields: $data, imagePath=$imagePath');

    data.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imagePath,
        filename: imagePath.split('/').last,
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    print('⬅️ UPDATE(MULTIPART) status: ${response.statusCode}');
    print('⬅️ UPDATE(MULTIPART) body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update item image: ${response.statusCode} ${response.body}',
      );
    }

    final Map<String, dynamic> json = jsonDecode(response.body);
    return LostItem.fromJson(json);
  }

  /// DELETE /posts/{id}/
  Future<void> deleteItem(int id) async {
    final uri = Uri.parse('$baseUrl/posts/$id/');

    final response = await http.delete(uri);

    print('⬅️ DELETE status: ${response.statusCode}');
    print('⬅️ DELETE body: ${response.body}');

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(
        'Failed to delete item: ${response.statusCode} ${response.body}',
      );
    }
  }
}
