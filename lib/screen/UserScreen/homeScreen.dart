import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_app/providers/homeDataProvider.dart';
import 'package:food_app/screen/UserScreen/FoodItemDetailScreen.dart';
import 'package:food_app/widget/foodCard.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantAsync = ref.watch(restaurantProvider);
    final popularItemsAsync = ref.watch(popularItemsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: restaurantAsync.when(
          loading: () => _buildLoading('Loading restaurant data...'),
          error: (err, _) => _buildError('Error loading restaurant: $err'),
          data: (restaurant) {
            return popularItemsAsync.when(
              loading: () => _buildLoading('Loading popular items...'),
              error: (err, _) => _buildError('Error loading items: $err'),
              data: (popularItems) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 16),
                    _buildSearchField(),
                    const SizedBox(height: 24),
                    _buildCategoryButtons(),
                    const SizedBox(height: 24),

                    // Carousel slider
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 200,
                        autoPlay: true,
                        viewportFraction: 1.0,
                        enableInfiniteScroll: true,
                      ),
                      items: restaurant.images.map((imageUrl) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, _) =>
                            const Icon(Icons.broken_image),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Popular Items
                    const Text(
                      'Most Popular Food',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (popularItems.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Text('No popular items found.'),
                        ),
                      )
                    else
                      ...popularItems.values.expand((list) => list).map(
                            (item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FoodItemDetailScreen(
                                      item: item,
                                      categoryName:
                                      item.categoryName ?? 'Popular',
                                    ),
                                  ),
                                );
                              },
                              child: PopularFoodItemCard(item: item),
                            ),
                          );
                        },
                      ).toList(),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoading(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          Text(message),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Text(message),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            Icon(Icons.location_on, color: Colors.red),
            SizedBox(width: 4),
            Text(
              "Delhi, India",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Icon(Icons.arrow_drop_down),
          ],
        ),
        const CircleAvatar(
          backgroundImage: NetworkImage(
            'https://static.wikia.nocookie.net/marvelcentral/images/9/97/Tony-Stark.jpg',
          ),
          radius: 16,
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
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
    );
  }

  Widget _buildCategoryButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildCategoryButton(Icons.delivery_dining, "Delivery"),
        _buildCategoryButton(Icons.dining, "Dining Out"),
        _buildCategoryButton(Icons.dining, "Takeaway"),
        _buildCategoryButton(Icons.local_offer, "Offers"),
      ],
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
