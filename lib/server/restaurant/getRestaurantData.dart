import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_app/models/restaurantModel.dart';
import 'package:food_app/storage/restaurantCredentials.dart';
import 'package:food_app/storage/userCredential.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Restaurant?> getRestaurantData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    // final String? restaurantId = prefs.getString('restaurantId');
    // if (restaurantId == null || restaurantId.isEmpty) {
    //   print('Restaurant ID not found in SharedPreferences.');
    //   return null;
    // }

    final String? restaurantId = "XmDSE2XOT3VqUhJmoN8T";
    await saveRestaurantId("XmDSE2XOT3VqUhJmoN8T");


    DocumentSnapshot<Map<String, dynamic>> restaurantSnapshot = await FirebaseFirestore.instance
        .collection('restaurant')
        .doc("XmDSE2XOT3VqUhJmoN8T")
        .get();
  
    if (restaurantSnapshot.exists) {
      Restaurant restaurant = Restaurant.fromFirestore(restaurantSnapshot);
      return restaurant;
    } else {
      print('Restaurant with ID $restaurantId does not exist.');
      return null;
    }
  } catch (e) {
    print('Error fetching restaurant data: $e');
    return null;
  }
}
