import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_app/models/FoodItemModel.dart';
import 'package:food_app/models/restaurantModel.dart';
import 'package:food_app/server/restaurant/getPopularItems.dart';
import 'package:food_app/server/restaurant/getRestaurantData.dart';
import 'package:food_app/storage/restaurantCredentials.dart';

final restaurantProvider = FutureProvider<Restaurant>((ref) async {
  final restaurant = await getRestaurantData();
  if (restaurant == null) {
    throw Exception('No restaurant data found');
  }
  return restaurant;
});

final popularItemsProvider = FutureProvider<Map<String, List<FoodItem>>>((ref) async {
  final restaurantId = await getRestaurantId();
  if (restaurantId == null) throw Exception('No restaurant ID found');
  return await fetchPopularItems(restaurantId);
});

final menuProvider = FutureProvider<Map<String, String>>((ref) async {
  final restaurant = await ref.watch(restaurantProvider.future);
  return restaurant.foodCategoryMap;
});
