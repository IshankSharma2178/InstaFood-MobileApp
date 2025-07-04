import 'package:cloud_firestore/cloud_firestore.dart';

class Restaurant {
  final String id;
  final String address;
  final String closingTime;
  final List<String> foodCategory;
  final List<String> images;
  final String name;
  final String openTiming;
  final String ratings; 
  final int totalSeats;

  Restaurant({
    required this.id,
    required this.address,
    required this.closingTime,
    required this.foodCategory,
    required this.images,
    required this.name,
    required this.openTiming,
    required this.ratings,
    required this.totalSeats,
  });

  factory Restaurant.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) {
      throw Exception("Restaurant data is null!");
    }
    return Restaurant(
      id: snapshot.id,
      name: data['name'] ?? 'N/A',
      address: data['Address'] ?? 'N/A',
      openTiming: data['openTiming'] ?? 'N/A',
      closingTime: data['closingTime'] ?? 'N/A',
      ratings: data['ratings'] ?? 'N/A',
      totalSeats: data['totalSeats'] ?? 0,
      foodCategory: List<String>.from(data['foodCategory'] ?? []),
      images: List<String>.from(data['images'] ?? []),
    );
  }

   Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'Address': address,
      'openTiming': openTiming,
      'closingTime': closingTime,
      'ratings': ratings,
      'totalSeats': totalSeats,
      'foodCategory': foodCategory,
      'images': images,
    };
  }
}
