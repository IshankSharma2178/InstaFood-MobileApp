import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id;
  final String name;
  final String amount;
  final String image;
  final String itemId;
  final String itemCategory;
  final DateTime date;

  CartItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.image,
    required this.itemId,
    required this.itemCategory,
    required this.date,
  });

  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItem(
      id: doc.id,
      name: data['name'] ?? '',
      amount: data['amount'] ?? '',
      image: data['image'] ?? '',
      itemId: data['itemId'] ?? '',
      itemCategory: data['itemCategory'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }
}
