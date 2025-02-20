import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> passwordReset() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Success"),
            content: Text("Password reset link sent! Check your email."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } 
    on FirebaseException catch (e) {
      print("Failed to send password reset email: ${e.message}");
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Failed to send password reset link: ${e.message}. Please try again."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Forgot Password",style:TextStyle(color: Colors.white),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Enter Your Email and we will send you a password reset link",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              style: TextStyle(color: Colors.white),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                fillColor: Colors.grey[900],
                filled: true,
                labelText: "Email",
                prefixIcon: Icon(Icons.email, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: _validateEmail,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: passwordReset,
              child: Text('Reset Password'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                onPrimary: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter an Email";
    }
    RegExp emailRegExp = RegExp(r'^[\w\-\.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegExp.hasMatch(value)) {
      return "Please enter a valid Email.";
    }
    return null;
  }
}
