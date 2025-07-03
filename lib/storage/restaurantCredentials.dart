import 'package:shared_preferences/shared_preferences.dart';

Future<void> restaurantData(String id) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('restaurantId' , "XmDSE2XOT3VqUhJmoN8T");
}
