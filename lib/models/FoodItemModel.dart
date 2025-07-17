import 'package:cloud_firestore/cloud_firestore.dart';

class FoodItem {
  final String id;
  final String name;
  final String description;
  final List<String> images;
  final double price;
  final double ratings;
  final String weight;
  final bool available;
  final String? offerText;
  final String? categoryName;

  FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.price,
    required this.ratings,
    required this.weight,
    required this.available,
    this.offerText,
    this.categoryName,
  });

  /// Parses from Firestore DocumentSnapshot (used for menu item)
  factory FoodItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FoodItem.fromMap(data, id: doc.id);
  }

  /// Generic Map constructor (used for popular item or any other source)
  factory FoodItem.fromMap(Map<String, dynamic> map, {required String id}) {
    return FoodItem(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? map['Description'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      price: _parseDouble(map['price']),
      ratings: _parseDouble(map['ratings']),
      weight: map['weight']?.toString() ?? '',
      available: map['available'] is bool
          ? map['available']
          : (map['available'].toString().toLowerCase() == 'true'),
      offerText: map['offerText'],
      categoryName: map['categoryName'], // optional for filtering, if present
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'images': images,
      'price': price,
      'ratings': ratings,
      'weight': weight,
      'available': available,
      'offerText': offerText,
      'categoryName': categoryName,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  String toString() => toMap().toString();
}
