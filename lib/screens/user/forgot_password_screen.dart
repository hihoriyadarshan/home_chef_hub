import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;  // Firebase Realtime Database instance

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Send password reset email
        await _auth.sendPasswordResetEmail(email: _emailController.text.trim());

        // Log password reset request in Firebase Realtime Database
        String userEmail = _emailController.text.trim();
        DatabaseReference passwordResetRef = _database.ref().child('password_resets').push();
        await passwordResetRef.set({
          'email': userEmail,
          'timestamp': DateTime.now().toString(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset link sent to your email.')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Forget Password',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFFD32F2F),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 60), // Added margin for top and bottom
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 60),
                // Logo
                CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/chef_logo.png'),
                ),
                SizedBox(height: 30), // Spacing after logo
                Text(
                  'Home Chef Hub',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                SizedBox(height: 10), // Spacing after the title
                Text(
                  'Enter your email to reset your password',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30), // Spacing before email input field
                SizedBox(
                  width: 500,
                  height: 50,
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: UnderlineInputBorder(), // Outlined border for input field
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 30), // Spacing before the button
                ElevatedButton(
                  onPressed: _resetPassword,
                  child: Text(
                    'Forget Password',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: Size(500, 50), // Adjust button width and height
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
