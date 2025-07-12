import 'package:flutter/material.dart';
// import '../screens/resturant_detail_screen.dart';

class RestaurantCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String tags;
  final String rating;
  final String time;
  final String price;

  const RestaurantCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.tags,
    required this.rating,
    required this.time,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: () {
      //   // 🔁 Navigate to detail screen
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => RestaurantDetailScreen(
      //         imageUrl: imageUrl,
      //         name: name,
      //         tags: tags,
      //         rating: rating,
      //         time: time,
      //         price: price,
      //       ),
      //     ),
      //   );
      // },

      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            // 📍 Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),
                  Text(
                    tags,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),

                  const SizedBox(height: 8),

                  // ⭐ Rating, ⏱️ Time, 💲 Cost
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.green,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              rating,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
