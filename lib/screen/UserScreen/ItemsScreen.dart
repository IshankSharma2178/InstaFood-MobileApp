import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_app/providers/foodItemsProvider.dart';
import 'package:food_app/screen/UserScreen/FoodItemDetailScreen.dart';
import 'package:food_app/widget/foodCard.dart';

class CategoryItemsScreen extends ConsumerWidget {
  final String categoryName;

  const CategoryItemsScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(categoryItemsProvider(categoryName));

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.orange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: SafeArea(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.brunch_dining_sharp, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      categoryName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),


      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No items found in this category.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final popularItem = (item);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FoodItemDetailScreen(categoryName:categoryName ,item: item),
                      ),
                    );
                  },
                  child: PopularFoodItemCard(item: popularItem),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
