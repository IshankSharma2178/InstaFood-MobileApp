import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_app/models/popularItemsModel.dart'; // Import your model

Future<Map<String, List<PopularFoodItem>>> fetchPopularItems(String restaurantId) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Map<String, List<PopularFoodItem>> popularItems = {};

  try {
    final mostPopularSnapshot = await firestore
        .collection('restaurant')
        .doc(restaurantId)
        .collection('mostPopular')
        .get();

    for (final categoryDoc in mostPopularSnapshot.docs) {
      String categoryName = categoryDoc.id;
      List<dynamic> ids = categoryDoc.data()['ids'] ?? [];

      List<PopularFoodItem> categoryItems = [];

      for (final dynamic itemId in ids) {
        final itemDoc = await firestore
            .collection('restaurant')
            .doc(restaurantId)
            .collection(categoryName)
            .doc(itemId.toString())
            .get();

        if (itemDoc.exists) {
          try {
            final itemData = itemDoc.data();
            if (itemData != null) {
              final item = PopularFoodItem.fromMap(itemData);
              categoryItems.add(item);
            }
          } catch (e) {
            print('Failed to convert item to model for $itemId: $e');
          }
        }
      }

      popularItems[categoryName] = categoryItems;
    }

    return popularItems;
  } catch (e) {
    print('Error fetching popular items: $e');
    return {};
  }
}
