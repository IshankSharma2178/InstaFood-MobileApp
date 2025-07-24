import 'package:shared_preferences/shared_preferences.dart';

  const String _restaurantIdKey = 'restaurantId';

  Future<void> saveRestaurantId(String restaurantId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_restaurantIdKey, "XmDSE2XOT3VqUhJmoN8T");
    } catch (e) {
      print('SharedPrefsService: Error saving restaurantId: $e');
    }
  }

  Future<String?> getRestaurantId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString(_restaurantIdKey);
      return id;
    } catch (e) {
      print('SharedPrefsService: Error getting restaurantId: $e');
      return null;
    }
  }

  Future<void> clearRestaurantId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_restaurantIdKey);
    } catch (e) {
      print('SharedPrefsService: Error clearing restaurantId: $e');
    }
  }
