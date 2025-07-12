import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_app/models/popularItemsModel.dart';
import 'package:food_app/models/restaurantModel.dart';
import 'package:food_app/providers/laoding.dart';
import 'package:food_app/server/restaurant/getPopularItems.dart';
import 'package:food_app/server/restaurant/getRestaurantData.dart';
import 'package:food_app/storage/restaurantCredentials.dart';
import '../../widgets/resturant_cards.dart';

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

    final popularItems = mostPopularItems.values.expand((items) => items).toList();

    // Task : create home screen ui
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Top Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.location_on, color: Colors.red),
                        SizedBox(width: 4),
                        Text(
                          "Delhi, India",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                    const CircleAvatar(
                      backgroundImage: NetworkImage(
                          'https://static.wikia.nocookie.net/marvelcentral/images/9/97/Tony-Stark.jpg/revision/latest?cb=20130429010603'),
                      radius: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 🔹 Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search for restaurants, dishes...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: const Icon(Icons.mic),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 🔹 Category Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCategoryButton(Icons.delivery_dining, "Delivery"),
                    _buildCategoryButton(Icons.dining, "Dining Out"),
                    _buildCategoryButton(Icons.local_offer, "Offers"),
                  ],
                ),

                const SizedBox(height: 24),

                // 🔹 Popular Items List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: popularItems.length,
                  itemBuilder: (context, index) {
                    final item = popularItems[index];
                    return RestaurantCard(
                      imageUrl: item.imageUrl ?? '',
                      name: item.name ?? 'Unknown',
                      tags: item.description ?? '',
                      rating: item.ratings?.toString() ?? '4.0',
                      time: '30 mins',
                      price: "₹${item.price ?? '0'} for two",
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.red[50],
          child: Icon(icon, color: Colors.red),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}
