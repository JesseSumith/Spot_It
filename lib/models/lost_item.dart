class LostItem {
  String id;
  String email;
  String photoUrl; // asset or network URL
  String type; // Lost / Found
  String itemName;
  String location;
  DateTime date;
  String details;
  String contactName;
  String contactMethod;

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
}
