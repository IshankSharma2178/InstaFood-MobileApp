import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> placeOrder({
  required String userId,
  required String itemId,
  required String name,
  required String image,
  required String itemCategory,
  required String amount,
}) async {
  final orderData = {
    'itemId': itemId,
    'name': name,
    'image': image,
    'itemCategory': itemCategory,
    'amount': amount,
    'date': Timestamp.now(),
  };

  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('orders')
      .add(orderData);
}
