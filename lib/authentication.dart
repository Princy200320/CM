import 'package:cashmate/dashboard.dart';
import 'package:cashmate/db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class auth {
  final Db db = Db();

  Future<void> create(Map<String, dynamic> data, BuildContext context) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data['email'],
        password: data['password'],
      );
      
// Extract user ID from userCredential
      String userId = userCredential.user!.uid;

      // Add user ID to data
      data['userId'] = userId;

      // Add user data to Firestore
      await db.addUser(data, context);

      // Navigate to the Dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: ((context) => const Dashboard())),
      );
    } catch (e) {
      // Handle errors
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Signup was unsuccessful"),
            content: Text(e.toString()),
          );
        },
      );
      print("Error in create: $e");
    }
  }

  Future<void> login(Map<String, dynamic> data, BuildContext context) async {
    try {
      // Attempt to sign in with the provided email and password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: data['email'],
        password: data['password'],
      );

      // If successful, navigate to the Dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: ((context) => const Dashboard())),
      );
    } on FirebaseAuthException catch (e) {
      // If the error code is 'user-not-found' or 'wrong-password',
      // display an error message indicating invalid credentials
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Login failed"),
              content: const Text("Invalid email or password."),
            );
          },
        );
      } else {
        // For other FirebaseAuth exceptions, display a generic error message
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Login failed"),
              content: Text(e.message ?? "An error occurred."),
            );
          },
        );
      }
      print("Error during login: ${e.message}");
    } catch (e) {
      // Handle other exceptions
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Login failed"),
            content: Text("An unexpected error occurred."),
          );
        },
      );
      print("Error during login: $e");
    }
  }


}
