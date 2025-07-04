import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_app/server/auth/signUp.dart';

Future<void> handleSignup({
  required BuildContext context,
  required String email,
  required String name,
  required String password,
}) async {
  try {
    await signup(name ,email, password);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Account created successfully 🎉")),
    );

    Navigator.pushReplacementNamed(context, '/login');
  } on FirebaseAuthException catch (e) {
    String message = "Sign up failed.";
    if (e.code == 'email-already-in-use') {
      message = 'Email is already registered.';
    } else if (e.code == 'invalid-email') {
      message = 'The email address is invalid.';
    } else if (e.code == 'weak-password') {
      message = 'Password is too weak.';
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Unexpected error: ${e.toString()}")),
    );
  }
}
