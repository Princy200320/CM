import 'package:cashmate/MainCard.dart';
import 'package:cashmate/addtrans.dart';
import 'package:cashmate/login.dart';
import 'package:cashmate/recents.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  var isLoad = false;

  Future<void> logout() async {
    setState(() {
      isLoad = true;
    });

    try {
      await FirebaseAuth.instance.signOut();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    } catch (e) {
      print("Error during logout: $e");
    }

    setState(() {
      isLoad = false;
    });
  }

  _dialoBuilder(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          content: AddTrans(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? ''; // Null check for currentUser

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          _dialoBuilder(context);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("CashMate", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {
              logout();
            },
            icon: isLoad
                ? const CircularProgressIndicator()
                : const Icon(Icons.exit_to_app_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MainCard(),
            const SizedBox(height: 16.0),
            Text(
            "Recent Transactions",
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
            ReTransCard(), 
          ],
        ),
      ),
    );
  }
}

