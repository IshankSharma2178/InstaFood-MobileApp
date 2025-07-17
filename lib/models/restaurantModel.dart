import 'package:cloud_firestore/cloud_firestore.dart';

class Restaurant {
  final String name;
  final String address;
  final List<String> images;
  final List<String> foodCategory;

  Restaurant({
    required this.name,
    required this.address,
    required this.images,
    required this.foodCategory,
  });

  factory Restaurant.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Restaurant(
      name: data['name'] ?? '',
      address: data['Address'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      foodCategory: List<String>.from(data['foodCategory'] ?? []),

    );
  }

  Map<String, String> get foodCategoryMap {
    final Map<String, String> map = {};
    for (final entry in foodCategory) {
      final parts = entry.split(',');
      if (parts.length >= 2) {
        final name = parts[0].trim();
        final image = parts[1].trim();
        map[name] = image;
      }
    }
    return map;
  }
}
