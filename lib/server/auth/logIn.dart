import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_app/storage/userCredential.dart';

login(String email, password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    String userId = userCredential.user!.uid;
    String? userEmail = userCredential.user!.email;

    await storeUserData(email: userEmail!, uuid: userId);

  } on FirebaseAuthException catch (e) {
    throw e;
  }
}
