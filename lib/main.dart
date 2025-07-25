import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_app/screen/UserScreen/navigatorScreen.dart';
import 'package:food_app/screen/authScreen/logInScreen.dart';
import 'package:food_app/screen/authScreen/signUpScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? uuid = prefs.getString('UUID');
  await Firebase.initializeApp();
  runApp(ProviderScope(child: MyApp(uuid: uuid)));
}

class MyApp extends StatelessWidget {
  final String? uuid;

  MyApp({required this.uuid});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute:  FirebaseAuth.instance.currentUser == null ?  '/login' : '/home'  ,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(
              builder: (_) => const logInScreen(),
            );
          case '/signup':
            return MaterialPageRoute(
              builder: (_) => const SignUpPage(),
            );
          case '/home':
            return MaterialPageRoute(
              builder: (_) => const MainNavigationScreen(),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const logInScreen(),
            );
        }
      },
    );
  }
}
