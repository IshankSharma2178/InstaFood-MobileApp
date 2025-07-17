import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_app/storage/userCredential.dart';

Future<void> removeItemFromCart(String itemId) async {
  final userId = await getUserId();
  if (userId == null) return;

  final cartRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('cart');

  final snapshot = await cartRef.where('itemId', isEqualTo: itemId).get();

  for (var doc in snapshot.docs) {
    await doc.reference.delete();
  }
}
