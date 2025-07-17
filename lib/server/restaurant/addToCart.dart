import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_app/models/FoodItemModel.dart';

Future<void> addItemToCart({
  required String userId,
  required FoodItem item,
  required String itemId,
  required String categoryName,
}) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('cart')
      .doc(itemId)
      .set({
    'itemId': itemId,
    'name': item.name,
    'image': item.images.isNotEmpty ? item.images.first : '',
    'amount': '₹${item.price.toStringAsFixed(2)}',
    'date': Timestamp.now(),
    'itemCategory': categoryName,
  });
}
