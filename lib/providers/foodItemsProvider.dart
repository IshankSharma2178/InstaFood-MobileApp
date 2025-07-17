import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_app/models/FoodItemModel.dart';
import 'package:food_app/server/restaurant/getAllItems.dart';

final categoryItemsProvider = FutureProvider.family<List<FoodItem>, String>((ref, categoryName) async {
  return await fetchItemsForCategory(categoryName);
});
