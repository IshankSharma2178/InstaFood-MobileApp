import 'package:flutter/material.dart';
import 'package:food_app/models/FoodItemModel.dart';
import 'package:food_app/server/restaurant/addToCart.dart';
import 'package:food_app/server/user/orderItem.dart';
import 'package:food_app/storage/userCredential.dart';

class FoodItemDetailScreen extends StatelessWidget {
  final FoodItem item;
  final String categoryName;
  final bool fromCart;

  const FoodItemDetailScreen({
    super.key,
    required this.item,
    required this.categoryName,
    this.fromCart = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (item.images.isNotEmpty)
              Image.network(
                item.images.first,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        "₹${item.price.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        item.weight,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 6),
                      Text(item.ratings.toStringAsFixed(1), style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (!item.available)
                    const Text(
                      "Not Available",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            if (!fromCart)
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final userId = await getUserId();
                    if (userId != null) {
                      await addItemToCart(
                        userId: userId,
                        item: item,
                        itemId: item.id,
                        categoryName: categoryName,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to Cart')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text("Add to Cart"),
                ),
              ),
            if (!fromCart) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  final userId = await getUserId();
                  if (userId != null) {
                    try {
                      await placeOrder(
                        userId: userId,
                        itemId: item.id,
                        name: item.name,
                        image: item.images.isNotEmpty ? item.images.first : '',
                        itemCategory: categoryName,
                        amount: '₹${item.price.toStringAsFixed(2)}',
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order placed successfully')),
                      );

                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to place order: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Buy Now"),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
