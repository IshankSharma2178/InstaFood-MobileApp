import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_app/server/auth/logIn.dart';


Future<void> handleLogin({
  required BuildContext context,
  required String email,
  required String password,
}) async {
  try {
    await login(email, password);
    Navigator.pushReplacementNamed(context, '/home');
  } on FirebaseAuthException catch (e) {
    String errorMessage = 'Login failed.';
    if (e.code == 'user-not-found') {
      errorMessage = 'No user found for that email.';
    } else if (e.code == 'wrong-password') {
      errorMessage = 'Wrong password provided.';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  }
}
