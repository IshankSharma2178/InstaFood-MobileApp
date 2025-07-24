import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:food_app/models/FoodItemModel.dart';
import 'package:food_app/server/restaurant/addToCart.dart';
import 'package:food_app/server/user/orderItem.dart';
import 'package:food_app/server/user/removeFromCart.dart';
import 'package:food_app/storage/userCredential.dart';

class FoodItemDetailScreen extends StatefulWidget {
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
  State<FoodItemDetailScreen> createState() => _FoodItemDetailScreenState();
}

class _FoodItemDetailScreenState extends State<FoodItemDetailScreen> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay()
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _startPayment() {
    final price = (widget.item.price * 100).toInt(); // convert to paise
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    var options = {
      'key': '', // Replace with your actual Razorpay key
      'amount': price,
      'name': widget.item.name,
      'description': 'Food order from InstaFood',
      'prefill': {'contact': '', 'email': email},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Payment error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final userId = await getUserId();
    if (userId == null) return;

    try {
      await placeOrder(
        userId: userId,
        itemId: widget.item.id,
        name: widget.item.name,
        image: widget.item.images.isNotEmpty ? widget.item.images.first : '',
        itemCategory: widget.categoryName,
        amount: '₹${widget.item.price.toStringAsFixed(2)}',
      );
      await removeItemFromCart(widget.item.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful & Order placed!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Order failed: $e')));
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment failed. Please try again.')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet: ${response.walletName}')),
    );
  }

  Future<void> _addToCart() async {
    final userId = await getUserId();
    if (userId == null) return;

    await addItemToCart(
      userId: userId,
      item: widget.item,
      itemId: widget.item.id,
      categoryName: widget.categoryName,
    );

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item added to cart')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      appBar: AppBar(title: Text(item.name), backgroundColor: Colors.red),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (item.images.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 300,
                    enlargeCenterPage: false,
                    enableInfiniteScroll: false,
                    viewportFraction: 1.0,
                    autoPlay: true,
                  ),
                  items: item.images.map((imageUrl) {
                    return Builder(
                      builder: (BuildContext context) {
                        return ClipRRect(
                          child: Image.network(
                            imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(item.weight, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 6),
                      Text(
                        item.ratings.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (!item.available)
                    const Text(
                      "Currently Not Available",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: item.available
          ? Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  if (!widget.fromCart)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _addToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text("Add to Cart"),
                      ),
                    ),
                  if (!widget.fromCart) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _startPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text("Buy Now"),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
