import 'package:food_app/storage/restaurantCredentials.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _restaurantIdKey = 'restaurantId';
const String _userEmailKey = 'email';
const String _userUUIDKey = 'UUID';

Future<void> storeUserData({
  required String email,
  required String uuid,
}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userUUIDKey, uuid);
    await saveRestaurantId("XmDSE2XOT3VqUhJmoN8T");
  } catch (e) {
    print('SharedPrefsService: Error storing user data: $e');
  }
}

Future<String?> getUserId() async {
final prefs = await SharedPreferences.getInstance();
return prefs.getString(_userUUIDKey);
}

Future<void> clearAllUserData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userUUIDKey);
    print('SharedPrefsService: Cleared all user data');
  } catch (e) {
    print('SharedPrefsService: Error clearing user data: $e');
  }
}
