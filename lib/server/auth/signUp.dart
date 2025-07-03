import 'package:firebase_auth/firebase_auth.dart';

signup(String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    String userId = userCredential.user!.uid;

  } on FirebaseAuthException catch (e) {
    throw e;
  }
}