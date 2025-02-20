import 'package:cashmate/authentication.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var isLoader = false;
  var isTermsAccepted = false; // Track whether the terms are accepted
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  var authe = auth();

  bool _isObscure = true; // Track whether the password is obscured or not

  void _showTermsOfService() {
    // Implement your logic to display the Terms of Service page
    // For example:
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TermsOfServicePage()), // Create TermsOfServicePage widget
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (!isTermsAccepted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Terms of Service"),
              content: Text("Please accept the Terms of Service to proceed."),
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
        return;
      }
      
      setState(() {
        isLoader = true;
      });
      var data = {
        "userId": FirebaseAuth.instance.currentUser?.uid ?? "", // Add the current user's ID
        "username": _username.text,
        "email": _email.text,
        "password": _password.text,
        "remaining balance": 0,
        "total_Credit": 0,
        "total_Debit": 0,
      };
      await authe.create(data, context);

      setState(() {
        isLoader = false;
      });
    }
  }

  String? _validateName(value) {
    if (value!.isEmpty) {
      return "Please enter a Username";
    }
    if (value.length < 2) {
      return "Username too short";
    }
    if (value.length > 12) {
      return "Username too long";
    }
    RegExp usernameRegExp = RegExp(r'^[a-zA-Z]+$'); // Allow only alphabets and limit to 12 characters
    if (!usernameRegExp.hasMatch(value)) {
      return "Username can contain alphabets only.";
    }
    return null;
  }

  String? _validatePass(value) {
    if (value!.isEmpty) {
      return "Please enter a Password";
    }
    if (value.length < 6) {
      return "Password too short";
    }
    if (value.length > 11) {
      return "Password too long";
    }
    RegExp passwordRegExp = RegExp(r'^[a-zA-Z0-9]+$'); // Allow only alphabets and numbers
    if (!passwordRegExp.hasMatch(value)) {
      return "Password should contain only alphabets and numbers";
    }
    return null;
  }

  String? _validateConfirmPass(value) {
    if (value!.isEmpty) {
      return "Please confirm your Password";
    }
    if (value != _password.text) {
      return "Passwords do not match";
    }
    return null;
  }

  String? _validateEmail(value) {
    if (value!.isEmpty) {
      return "Please enter an Email";
    }
    RegExp emailRegExp = RegExp(r'^[\w\-\.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegExp.hasMatch(value)) {
      return "Please enter a valid Email.";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 60.0),
              Container(
                height: 200.0,
                child: Image.asset('assets/images/logo.png', height: 200.0, width: 200.0),
              ),
              SizedBox(height: 20.0),

              Text(
                "Sign Up",
                style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _username,
                      style: TextStyle(color: Colors.white),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: _buildInputDecoration("Username", Icons.person),
                      validator: _validateName,
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _email,
                      style: TextStyle(color: Colors.white),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: _buildInputDecoration("Email", Icons.email),
                      validator: _validateEmail,
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _password,
                      style: TextStyle(color: Colors.white),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: _buildInputDecoration("Password", Icons.lock),
                      validator: _validatePass,
                      obscureText: _isObscure,
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _confirmPassword,
                      style: TextStyle(color: Colors.white),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: _buildInputDecoration("Confirm Password", Icons.lock),
                      validator: _validateConfirmPass,
                      obscureText: _isObscure,
                    ),
                    SizedBox(height: 4.0),
                    Row(
                      children: [
                        Checkbox(
                          value: isTermsAccepted,
                          onChanged: (value) {
                            setState(() {
                              isTermsAccepted = value!;
                            });
                          },
                        ),
                        Flexible(
                          child: Text(
                            'I accept the ',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        TextButton(
                          onPressed: _showTermsOfService,
                          child: Text(
                            'Terms of Service',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.0),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onPressed: () {
                          isLoader ? print("Loading") : _submitForm();
                        },
                        child: isLoader
                            ? Center(child: CircularProgressIndicator())
                            : Text("Sign Up", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()));
                },
                child: Text("Login", style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData prefixIcon) {
    return InputDecoration(
      fillColor: Colors.grey[900],
      filled: true,
      labelText: label,
      prefixIcon: Icon(prefixIcon, color: Colors.blue),
      suffixIcon: prefixIcon == Icons.lock
          ? IconButton(
              icon: Icon(
                _isObscure ? Icons.visibility : Icons.visibility_off,
                color: Colors.blue,
              ),
              onPressed: () {
                setState(() {
                  _isObscure = !_isObscure;
                });
              },
            )
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class TermsOfServicePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Terms of Service',style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'CashMate Expense Tracker Terms of Service Agreement\n\n'
              'Welcome to CashMate! These Terms of Service ("Terms") govern your use of CashMate, including all related websites, applications, and services (collectively referred to as the "Service"). By accessing or using the Service, you agree to be bound by these Terms. If you do not agree to these Terms, please do not access or use the Service.\n\n'
              '1. Use of the Service\n\n'
             
              '1.1. Registration: In order to access certain features of the Service, you may be required to create an account. You agree to provide accurate and complete information when creating your account and to keep your account information updated.\n\n'
              '1.2. Acceptable Use: You agree to use the Service in compliance with all applicable laws, regulations, and these Terms. You agree not to engage in any conduct that could damage, disable, or impair the operation of the Service.\n\n'
              '2. Privacy\n\n'
              '2.1. Privacy Policy: Your privacy is important to us. Our Privacy Policy explains how we collect, use, and disclose information about you. By using the Service, you agree to the collection, use, and disclosure of your information as described in our Privacy Policy.\n\n'
              '3. Content\n\n'
              '3.1. User Content: You retain ownership of any content that you upload, submit, or otherwise make available on or through the Service ("User Content"). By submitting User Content, you grant CashMate a non-exclusive, transferable, sublicensable, royalty-free, worldwide license to use, reproduce, modify, adapt, publish, translate, distribute, and display such User Content in connection with the Service.\n\n'
              '3.2. Prohibited Content: You agree not to submit any User Content that is unlawful, harmful, threatening, abusive, harassing, defamatory, vulgar, obscene, or otherwise objectionable.\n\n'
              '4. Intellectual Property\n\n'
              '4.1. Ownership: CashMate and its licensors retain all rights, title, and interest in and to the Service, including all intellectual property rights.\n\n'
              '4.2. Trademarks: "CashMate" and the CashMate logo are trademarks of CashMate. You agree not to use, display, or reproduce these trademarks without our prior written permission.\n\n'
              '5. Termination\n\n'
              '5.1. Termination by CashMate: CashMate may terminate or suspend your access to the Service at any time, with or without cause, and with or without notice.\n\n'
              '5.2. Termination by You: You may terminate your account at any time by contacting us or using the account deletion feature available through the Service.\n\n'
              '6. Disclaimer of Warranties\n\n'
              '6.1. No Warranties: THE SERVICE IS PROVIDED "AS IS" AND "AS AVAILABLE" WITHOUT WARRANTIES OF ANY KIND, WHETHER EXPRESS OR IMPLIED. TO THE FULLEST EXTENT PERMITTED BY APPLICABLE LAW, CASHMATE DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.\n\n'
              '7. Limitation of Liability\n\n'
              '7.1. Limitation of Liability: TO THE FULLEST EXTENT PERMITTED BY APPLICABLE LAW, CASHMATE SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, OR ANY LOSS OF PROFITS OR REVENUES, WHETHER INCURRED DIRECTLY OR INDIRECTLY, OR ANY LOSS OF DATA, USE, GOODWILL, OR OTHER INTANGIBLE LOSSES, ARISING OUT OF OR IN CONNECTION WITH YOUR ACCESS TO OR USE OF, OR INABILITY TO ACCESS OR USE, THE SERVICE.\n\n'
              '8. Governing Law\n\n'
              '8.1. Governing Law: These Terms shall be governed by and construed in accordance with the laws of [Jurisdiction], without regard to its conflict of law principles.\n\n'
              '9. Changes to the Terms\n\n'
              '9.1. Changes: CashMate reserves the right to modify or revise these Terms at any time. If we make material changes to these Terms, we will provide notice of such changes by posting the revised Terms on the Service or by other means. Your continued use of the Service following the posting of the revised Terms constitutes your acceptance of such changes.',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
