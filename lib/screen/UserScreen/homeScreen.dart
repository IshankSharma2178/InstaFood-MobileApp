import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_app/models/FoodItemModel.dart';
import 'package:food_app/providers/homeDataProvider.dart';
import 'package:food_app/screen/UserScreen/FoodItemDetailScreen.dart';
import 'package:food_app/screen/UserScreen/profile_screen.dart';
import 'package:food_app/widget/foodCard.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<FoodItem> _searchResults = [];
  bool _isSearching = false;

  Future<List<FoodItem>> searchFoodItems(String query) async {
    final categories = ['Chinese', 'Italian', 'Mexican', 'South Indian', 'Sweets'];
    final List<FoodItem> results = [];

    final restaurantId = 'XmDSE2XOT3VqUhJmoN8T'; // your restaurant document ID
    final lowerQuery = query.toLowerCase();

    for (final category in categories) {
      final snapshot = await FirebaseFirestore.instance
          .collection('restaurant')
          .doc(restaurantId)
          .collection(category)
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final name = (data['name'] ?? '').toString().toLowerCase();

        if (name.contains(lowerQuery)) {
          final foodItem = FoodItem.fromFirestoreWithCategory(data, doc.id, category);
          results.add(foodItem);
        }
      }
    }

    return results;
  }



  @override
  Widget build(BuildContext context) {
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
                    _buildTopBar(context),
                    const SizedBox(height: 16),
                    _buildSearchField(),
                    const SizedBox(height: 24),
                    _buildCategoryButtons(),
                    const SizedBox(height: 24),
                    if (_isSearching) _buildSearchResults(),
                    if (!_isSearching) ...[
                      Text(
                        "🔥 Hot Deals",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.redAccent,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              blurRadius: 4.0,
                              color: Colors.black26,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      CarouselSlider(
                        options: CarouselOptions(
                          height: 200,
                          autoPlay: true,
                          viewportFraction: 0.95,
                          enlargeCenterPage: true,
                          autoPlayInterval: const Duration(seconds: 4),
                          autoPlayAnimationDuration: const Duration(milliseconds: 800),
                          enableInfiniteScroll: true,
                        ),
                        items: restaurant.images.map((imageUrl) {
                          return Builder(
                            builder: (context) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      loadingBuilder: (context, child, progress) {
                                        if (progress == null) return child;
                                        return Container(
                                          color: Colors.grey[200],
                                          child: const Center(child: CircularProgressIndicator()),
                                        );
                                      },
                                      errorBuilder: (context, error, _) => Container(
                                        color: Colors.grey[300],
                                        alignment: Alignment.center,
                                        child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '🍽️ Our Popular Dishes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.deepOrange,
                          letterSpacing: 1.0,
                          shadows: [
                            Shadow(
                              blurRadius: 3.0,
                              color: Colors.black26,
                              offset: Offset(1, 1),
                            ),
                          ],
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
                                        categoryName: item.categoryName ?? 'Popular',
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
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 16),
        child: Center(child: Text('No results found')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _searchResults.map((item) {
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FoodItemDetailScreen(
                  item: item,
                  categoryName: item.categoryName ?? 'Search',
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: PopularFoodItemCard(item: item),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (query) async {
        setState(() {
          _isSearching = query.isNotEmpty;
        });

        final results = await searchFoodItems(query);
        setState(() {
          _searchResults = results;
        });
      },
      decoration: InputDecoration(
        hintText: "Search for restaurants, dishes...",
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _searchController.clear();
            setState(() {
              _isSearching = false;
              _searchResults = [];
            });
          },
        ),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }


  Widget _buildTopBar(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        String? imageUrl;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          imageUrl = data['profileImage'];
        }

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
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: CircleAvatar(
                radius: 16,
                backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                    ? NetworkImage(imageUrl)
                    : const NetworkImage(
                  'https://static.wikia.nocookie.net/marvelcentral/images/9/97/Tony-Stark.jpg',
                ),
              ),
            ),
          ],
        );
      },
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
}
