import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_app/models/FoodItemModel.dart';

Future<List<FoodItem>> fetchItemsForCategory(String categoryName) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('restaurant')
        .doc('XmDSE2XOT3VqUhJmoN8T')
        .collection(categoryName)
        .get();

    return snapshot.docs.map((doc) => FoodItem.fromFirestore(doc)).toList();
  } catch (e) {
    print('Error fetching items for category $categoryName: $e');
    return [];
  }
}
