import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_app/storage/userCredential.dart';

signin(String email, password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    String userId = userCredential.user!.uid;
    String? userEmail = userCredential.user!.email;

    storeData(userEmail!, userId);

  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      print('No user found for that email.');
    } else if (e.code == 'wrong-password') {
      print('Wrong password provided for that user.');
    }
  }
}