import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_app/models/popularItemsModel.dart';
import 'package:food_app/models/restaurantModel.dart';
import 'package:food_app/providers/laoding.dart';
import 'package:food_app/server/restaurant/getPopularItems.dart';
import 'package:food_app/server/restaurant/getRestaurantData.dart';
import 'package:food_app/storage/restaurantCredentials.dart';

class homeScreen extends ConsumerStatefulWidget {
  const homeScreen({super.key});

  @override
  ConsumerState<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends ConsumerState<homeScreen> {
  Restaurant? restaurant;
  Map<String, List<PopularFoodItem>> mostPopularItems = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() => loadRestaurantData());
  }

  Future<void> loadRestaurantData() async {
    ref.read(loadingProvider.notifier).state = true;

    try {
      final result = await getRestaurantData();
      final restaurantId = await getRestaurantId();
      if (restaurantId == null) {
        throw Exception('No restaurant ID found in SharedPreferences.');
      }
      final rawPopularItems = await fetchPopularItems(restaurantId);

      print(result);
      print(rawPopularItems);

      if (result != null) {
        setState(() {
          restaurant = result;
          mostPopularItems = rawPopularItems;
        });
      }
    } catch (e) {
      print("Error fetching restaurant: $e");
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading restaurant data...'),
            ],
          ),
        ),
      );
    }

    if (restaurant == null) {
      return const Scaffold(body: Center(child: Text("Restaurant not found.")));
    }

    // Task : create home screen ui
    return MaterialApp();
  }
}
