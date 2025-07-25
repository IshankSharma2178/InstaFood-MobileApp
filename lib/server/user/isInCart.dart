import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> isInCart(String userId, String itemId) async {
  final cartRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('cart')
      .doc(itemId);

  final doc = await cartRef.get();
  return doc.exists;
}
