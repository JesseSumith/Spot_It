class LostItem {
  // 🔴 IMPORTANT: Change this based on your device!
  // Android Emulator: 'http://10.0.2.2:8000'
  // Real Phone (ADB Reverse): 'http://127.0.0.1:8000'
  // Real Phone (Wi-Fi): 'http://192.168.1.XX:8000' (Your PC IP)
  static const String apiBase = 'http://127.0.0.1:8000';

  final int id;
  final String email;
  final String photoUrl;
  final String type; // "lost" or "found"
  final String itemName;
  final String location;
  final DateTime date;
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
      fullImageUrl = '$apiBase$rawImage';
    }

    final bool isLost = json['is_lost'] == true || json['is_lost'] == 'true';

    return LostItem(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      email: '', // Not stored in backend usually
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

  // Data to send to Django
  Map<String, dynamic> toCreateJson() {
    return {
      'is_lost': type == 'lost', // boolean true/false
      'title': itemName,
      'description': details,
      'location_text': location,
      'contact_name': contactName,
      'contact_method': contactMethod,
    };
  }

  Map<String, dynamic> toUpdateJson() => toCreateJson();
}
