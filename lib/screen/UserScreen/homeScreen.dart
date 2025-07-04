import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_app/models/restaurantModel.dart';
import 'package:food_app/providers/laoding.dart';
import 'package:food_app/server/restaurant/getRestaurantData.dart';

class homeScreen extends ConsumerStatefulWidget {
  const homeScreen({super.key});

  @override
  ConsumerState<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends ConsumerState<homeScreen> {
  Restaurant? restaurant;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => loadRestaurantData());
  }

  Future<void> loadRestaurantData() async {
    ref.read(loadingProvider.notifier).state = true;

    try {
      final result = await getRestaurantData();
      if (result != null) {
        setState(() => restaurant = result);
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

    return Scaffold(
      appBar: AppBar(title: Text(restaurant!.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Address: ${restaurant!.address}'),
            Text('Open: ${restaurant!.openTiming} - Close: ${restaurant!.closingTime}'),
            Text('Rating: ${restaurant!.ratings}'),
            Text('Total Seats: ${restaurant!.totalSeats}'),
            const SizedBox(height: 16),

            const Text('Food Categories:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...restaurant!.foodCategory.map((category) => Text('- $category')),
            const SizedBox(height: 16),

            const Text('Images:', style: TextStyle(fontWeight: FontWeight.bold)),
            if (restaurant!.images.isNotEmpty)
              SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: restaurant!.images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return Image.network(
                      restaurant!.images[index],
                      width: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 50),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            else
              const Text('No images available.'),
          ],
        ),
      ),
    );
  }
}
