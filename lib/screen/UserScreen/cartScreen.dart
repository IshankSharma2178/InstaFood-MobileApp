import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:food_app/models/cartModel.dart';
import 'package:food_app/models/FoodItemModel.dart';
import 'package:food_app/screen/UserScreen/FoodItemDetailScreen.dart';
import 'package:food_app/server/restaurant/getCartItems.dart';
import 'package:food_app/server/user/orderItem.dart';
import 'package:food_app/server/user/removeFromCart.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<List<CartItem>> _cartItemsFuture;
  List<CartItem> _cartItems = [];
  bool _isPlacingOrder = false;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _cartItemsFuture = fetchCartItems();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _refreshCart() {
    setState(() {
      _cartItemsFuture = fetchCartItems();
    });
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      for (var item in _cartItems) {
        await placeOrder(
          userId: user.uid,
          itemId: item.itemId,
          name: item.name,
          image: item.image,
          itemCategory: item.itemCategory,
          amount: '₹${(double.tryParse(item.amount.replaceAll('₹', '')) ?? 0.0) * item.quantity}',
        );
        await removeItemFromCart(item.itemId);
      }
      Fluttertoast.showToast(
        msg: '🎉 Order placed successfully!',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green.shade600,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      _refreshCart();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Order failed: $e');
    } finally {
      setState(() => _isPlacingOrder = false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: 'Payment failed. Please try again.');
    setState(() => _isPlacingOrder = false);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: 'External Wallet selected');
  }


  double _calculateTotalAmount() {
    double total = 0.0;
    for (var item in _cartItems) {
      double price = double.tryParse(item.amount.replaceAll('₹', '')) ?? 0.0;
      total += price * item.quantity;
    }
    return total;
  }

  Future<void> updateItemQuantity(String itemId, int newQuantity) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart');

    final snapshot = await cartRef.where('itemId', isEqualTo: itemId).get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'quantity': newQuantity});
    }
  }

  @override
  Widget build(BuildContext context) {
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
                children: const [
                  Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Your Cart',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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

          _cartItems = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = _cartItems[index];
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
                    final itemPrice = foodItem.price * cartItem.quantity;

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
                          padding: const EdgeInsets.all(12),
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
                                  errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image, size: 70),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(cartItem.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text('₹${foodItem.price} x ${cartItem.quantity}', style: const TextStyle(fontSize: 14)),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: () async {
                                            if (cartItem.quantity > 1) {
                                              setState(() {
                                                cartItem.quantity -= 1;
                                              });
                                              await updateItemQuantity(cartItem.itemId, cartItem.quantity);
                                            }
                                          },
                                        ),
                                        Text(cartItem.quantity.toString(), style: const TextStyle(fontSize: 16)),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () async {
                                            setState(() {
                                              cartItem.quantity += 1;
                                            });
                                            await updateItemQuantity(cartItem.itemId, cartItem.quantity);
                                          },
                                        ),
                                      ],
                                    ),
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
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2)),
                ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('₹${_calculateTotalAmount().toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isPlacingOrder
                          ? null
                          : () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) return;

                        setState(() => _isPlacingOrder = true);
                        Fluttertoast.showToast(msg: 'Opening payment gateway...', toastLength: Toast.LENGTH_SHORT);

                        final totalAmount = (_calculateTotalAmount() * 100).toInt(); // in paise

                        var options = {
                          'key':"rzp_test_Klke2pJ4rcNIaM", // replace with your Razorpay key
                          'amount': totalAmount,
                          'name': FirebaseAuth.instance.currentUser?.displayName ?? 'User',
                          'description': 'Payment for food items',
                          'prefill': {
                            'contact': user.phoneNumber ?? '1234567890',
                            'email': user.email ?? 'test@example.com',
                          },
                        };

                        try {
                          _razorpay.open(options);
                        } catch (e) {
                          Fluttertoast.showToast(msg: 'Error: $e');
                          setState(() => _isPlacingOrder = false);
                        }
                      },

                      child: Text(
                        _isPlacingOrder ? 'Processing...' : 'Proceed to Checkout',
                        style: const TextStyle(fontSize: 16 ,color: Colors.white ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
