import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Db {
  final CollectionReference users = FirebaseFirestore.instance.collection('users');
  final String userId;

  Db() : userId = FirebaseAuth.instance.currentUser?.uid ?? "";

  Future<bool> userExists(String email) async {
    try {
      QuerySnapshot querySnapshot = await users.where('email', isEqualTo: email).get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking if user exists: $e");
      return false;
    }
  }

  Future<void> addUser(Map<String, dynamic> data, context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentReference docRef = await users.add(data);
        print("User Added with ID: ${docRef.id}"); // Print the document ID

        // Check if the user was successfully added to the database
        bool exists = await userExists(data['email']);
        if (exists) {
          print("User creation process is successful");
        } else {
          print("User creation process failed: User not found in database");
        }
      } else {
        throw Exception("User not authenticated");
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Sign up Failed"),
            content: Text("Error adding user to database: $error"),
          );
        },
      );
      print("Error adding user to database: $error");
    }
  }
}
