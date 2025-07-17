import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> createUser(String uuid, Map<String, dynamic> userData) async {
  try {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    await users.doc(uuid).set(userData);
  } catch (e) {
    print('Error creating user: $e');
    throw e;
  }
}