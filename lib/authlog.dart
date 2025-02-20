import 'package:cashmate/dashboard.dart';
import 'package:cashmate/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Authlog extends StatelessWidget{
  const Authlog({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream:FirebaseAuth.instance.authStateChanges(),
      builder:(context, snapshot){
        if(!snapshot.hasData)
        {
          return const Login();
        }
        return const Dashboard();
      });
    }

  
  }