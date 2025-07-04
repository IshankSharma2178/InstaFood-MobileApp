class PopularFoodItem {
  final String name;
  final String price;
  final String weight;
  final String ratings;
  final String description;
  final bool available;
  final List<String> images;

  PopularFoodItem({
    required this.name,
    required this.price,
    required this.weight,
    required this.ratings,
    required this.description,
    required this.available,
    required this.images,
  });

  factory PopularFoodItem.fromMap(Map<String, dynamic> map) {
    return PopularFoodItem(
      name: map['name'] ?? '',
      price: map['price']?.toString() ?? '',
      weight: map['weight'] ?? '',
      ratings: map['ratings']?.toString() ?? '',
      description: map['Description'] ?? '',
      available: map['available'] is bool
          ? map['available']
          : (map['available'].toString().toLowerCase() == 'true'),
      images: List<String>.from(map['images'] ?? []),
    );
  }

}
