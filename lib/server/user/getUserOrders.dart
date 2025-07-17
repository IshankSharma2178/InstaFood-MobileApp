import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_app/storage/userCredential.dart';

Future<List<Map<String, dynamic>>> fetchOrders() async {
  final userId = await getUserId();
  if (userId == null) return [];

  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('orders')
      .orderBy('date', descending: true)
      .get();

  return snapshot.docs.map((doc) => doc.data()).toList();
}