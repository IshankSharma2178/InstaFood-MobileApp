import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_app/models/cartModel.dart';
import 'package:food_app/storage/userCredential.dart';

Future<List<CartItem>> fetchCartItems() async {
  final userId = await getUserId();
  if (userId == null || userId.isEmpty) return [];

  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('cart')
      .orderBy('date', descending: true)
      .get();

  return snapshot.docs.map((doc) => CartItem.fromFirestore(doc)).toList();
}
