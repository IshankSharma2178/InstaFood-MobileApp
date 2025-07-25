import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_app/screen/UserScreen/navigatorScreen.dart';
import 'package:food_app/server/user/isInCart.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  bool _isAddingToCart = false;
  bool _isInCart = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay()
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _checkCartStatus();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _checkCartStatus() async {
    final userId = await getUserId();
    if (userId == null) return;

    final inCart = await isInCart(userId, widget.item.id);
    if (mounted) {
      setState(() {
        _isInCart = inCart;
      });
    }
  }

  void _startPayment() {
    try {
      final price = (widget.item.price * 100).toInt();
      final email = FirebaseAuth.instance.currentUser?.email ?? '';

      var options = {
        'key': "rzp_test_Klke2pJ4rcNIaM",
        'amount': price,
        'name': FirebaseAuth.instance.currentUser?.displayName ?? 'User',
        'description': 'Food order from InstaFood',
        'prefill': {'contact': '', 'email': email},
      };

      _razorpay.open(options);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Could not open payment gateway.');
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order failed: $e')),
        );
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
    setState(() => _isAddingToCart = true);

    final userId = await getUserId();
    if (userId == null) {
      setState(() => _isAddingToCart = false);
      return;
    }

    try {
      await addItemToCart(
        userId: userId,
        item: widget.item,
        itemId: widget.item.id,
        categoryName: widget.categoryName,
      );

      Fluttertoast.showToast(
        msg: "${widget.item.name} added to cart!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.pink.shade900,
        textColor: Colors.white,
        fontSize: 16,
        timeInSecForIosWeb: 1,
        webBgColor: "linear-gradient(to right, #ff5f6d, #ffc371)",
      );

      setState(() {
        _isInCart = true;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error adding to cart: $e');
    } finally {
      if (mounted) setState(() => _isAddingToCart = false);
    }
  }

  Widget _buildInfoPill(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 14, color: Colors.black)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

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
                  const Icon(Icons.fastfood, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      item.name,
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (item.images.isNotEmpty)
              ClipRRect(
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 280,
                    autoPlay: true,
                    viewportFraction: 1.0,
                  ),
                  items: item.images.map((url) {
                    return Image.network(
                      url,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, _) => const Icon(Icons.broken_image),
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
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "₹${item.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoPill(Icons.star, item.ratings.toStringAsFixed(1), Colors.amber),
                      _buildInfoPill(Icons.scale, '${item.weight}', Colors.green),
                      _buildInfoPill(Icons.timer, '32 mins', Colors.blueGrey),
                    ],
                  ),
                  const SizedBox(height: 16),
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
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            if (!widget.fromCart)
              Expanded(
                child: ElevatedButton(
                  onPressed: _isInCart
                      ? () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainNavigationScreen(initialIndex: 2),
                      ),
                    );
                  }

                      : (_isAddingToCart ? null : _addToCart),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isInCart ? Colors.orange : Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isAddingToCart
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(
                    _isInCart ? "Go to Cart" : "Add to Cart",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            if (!widget.fromCart) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _startPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Buy Now",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      )
          : const SizedBox.shrink(),
    );
  }
}
