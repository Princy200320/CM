import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cashmate/authlog.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Adjust the duration as needed
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: 1.5, 
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
    Timer(
      const Duration(seconds: 3), 
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Authlog()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child:Image.asset('assets/images/logo.png', height: 200.0, width: 200.0)
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
