import 'package:shared_preferences/shared_preferences.dart';

Future<void> storeData(String email , String UUID) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('email', email);
  await prefs.setString('UUID' , UUID);
}
