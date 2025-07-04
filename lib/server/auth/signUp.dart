import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_app/server/user/createUser.dart';

Future<void> signup(String name,String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    String userId = userCredential.user!.uid;

    Map<String, dynamic> userData = {
      'name': name,
      'email' : email,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await createUser(userId, userData);

  } on FirebaseAuthException catch (e) {
    print('FirebaseAuthException during sign up: ${e.code} - ${e.message}');
    throw e;
  } catch (e) {
    print('An unexpected error occurred: $e');
    throw e;
  }
}