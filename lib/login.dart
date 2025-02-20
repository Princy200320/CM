import 'package:cashmate/forgotpass.dart';
import 'package:flutter/material.dart';
import 'package:cashmate/authentication.dart';
import 'signup.dart';

class Login extends StatefulWidget {
  const Login({Key? key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var isLoader = false;
  final _email = TextEditingController();
  final _password = TextEditingController();

  var authe = auth();

  bool _isObscure = true; // Track whether the password is obscured or not

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoader = true;
      });
      var data = {
        "email": _email.text,
        "password": _password.text,
      };
      await authe.login(data, context);

      setState(() {
        isLoader = false;
      });
    }
  }

  String? _validatePass(value) {
    if (value!.isEmpty) {
      return "Please enter a Password";
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 SizedBox(height: 60.0),
                SizedBox(
                  height: 200.0,
                  child: Image.asset('assets/images/logo.png', height: 200.0, width: 200.0),
                ),
                const SizedBox(height: 40.0),
                const Text(
                  "Login",
                  style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  controller: _email,
                  style: const TextStyle(color: Colors.white),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: _buildInputDecoration("Email", Icons.person),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 24.0),
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    TextFormField(
                      controller: _password,
                      style: const TextStyle(color: Colors.white),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: _buildInputDecoration("Password", Icons.lock),
                      validator: _validatePass,
                      obscureText: _isObscure,
                    ),
                    IconButton(
                      icon: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
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
                        ? const Center(child: CircularProgressIndicator())
                        : const Text(
                            "Login",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),
                          ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align widgets horizontally
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordPage()));
                      },
                      child: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(top: 0.0),
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(fontSize: 12, color: Colors.white,fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const Signup()));
                      },
                      child: const Text("Not a user? Sign up", style: TextStyle(fontSize: 12, color: Colors.white,fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData suffixIcon) {
    return InputDecoration(
      fillColor: Colors.grey[900],
      filled: true,
      labelText: label,
      prefixIcon: Icon(suffixIcon, color: Colors.blue),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
    );
  }
}
