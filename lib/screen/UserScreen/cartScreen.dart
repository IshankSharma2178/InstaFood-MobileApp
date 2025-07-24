import 'package:flutter/material.dart';
import 'package:food_app/models/cartModel.dart';
import 'package:food_app/models/FoodItemModel.dart';
import 'package:food_app/screen/UserScreen/FoodItemDetailScreen.dart';
import 'package:food_app/server/restaurant/getCartItems.dart';
import 'package:food_app/server/user/removeFromCart.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<List<CartItem>> _cartItemsFuture;

  @override
  void initState() {
    super.initState();
    _cartItemsFuture = fetchCartItems();
  }

  void _refreshCart() {
    setState(() {
      _cartItemsFuture = fetchCartItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder<List<CartItem>>(
        future: _cartItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }

          final items = snapshot.data!;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final cartItem = items[index];

              final foodItem = FoodItem(
                id: cartItem.itemId,
                name: cartItem.name,
                price: double.tryParse(cartItem.amount.replaceAll('₹', '')) ?? 0.0,
                weight: '200g',
                ratings: 4.5,
                description: 'Delicious food item',
                available: true,
                images: [cartItem.image],
              );

              return Card(
                margin: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FoodItemDetailScreen(
                          item: foodItem,
                          categoryName: cartItem.itemCategory,
                          fromCart: true,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            cartItem.image,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 70),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cartItem.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(cartItem.itemCategory, style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(cartItem.amount, style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${cartItem.date.day}/${cartItem.date.month}/${cartItem.date.year}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 12),
                            IconButton(
                              icon: const Icon(Icons.delete_outlined, color: Colors.red),
                              onPressed: () async {
                                await removeItemFromCart(cartItem.itemId);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Item removed from cart')),
                                );
                                _refreshCart();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
