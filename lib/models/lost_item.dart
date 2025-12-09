class LostItem {
  static const String apiBase =
      'http://10.0.2.2:8000'; // use 10.0.2.2 for Android emulator

  final int id;
  final String email; // UI only, not stored in Django
  final String photoUrl;
  final String type; // "lost" or "found"
  final String itemName;
  final String location;
  final DateTime date; // UI only, we’ll just use created_at from server
  final String details;
  final String contactName;
  final String contactMethod;

  LostItem({
    required this.id,
    required this.email,
    required this.photoUrl,
    required this.type,
    required this.itemName,
    required this.location,
    required this.date,
    required this.details,
    required this.contactName,
    required this.contactMethod,
  });

  factory LostItem.fromJson(Map<String, dynamic> json) {
    final rawImage = json['image'] as String?;
    String fullImageUrl;

    if (rawImage == null || rawImage.isEmpty) {
      fullImageUrl = 'https://via.placeholder.com/150';
    } else if (rawImage.startsWith('http')) {
      fullImageUrl = rawImage;
    } else {
      fullImageUrl =
          '$apiBase$rawImage'; // '/media/...' -> 'http://10.0.2.2:8000/media/...'
    }

    final bool isLost = json['is_lost'] == true || json['is_lost'] == 'true';

    return LostItem(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      email:
          '', // backend has no email field, keep empty or infer from contact_method if you want
      photoUrl: fullImageUrl,
      type: isLost ? 'lost' : 'found',
      itemName: json['title'] ?? '',
      location: json['location_text'] ?? '',
      date: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      details: json['description'] ?? '',
      contactName: json['contact_name'] ?? '',
      contactMethod: json['contact_method'] ?? '',
    );
  }

  /// What we send to Django when creating/updating.
  /// Only include fields that the ItemPost model actually has.
  Map<String, dynamic> toCreateJson() {
    return {
      'is_lost': type == 'lost', // bool -> DRF BooleanField
      'title': itemName,
      'description': details,
      'location_text': location,
      'contact_name': contactName,
      'contact_method': contactMethod,
      // image is sent separately in multipart, not here
    };
  }

  Map<String, dynamic> toUpdateJson() => toCreateJson();
}
