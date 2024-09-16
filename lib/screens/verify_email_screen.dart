import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class VerifyEmailScreen extends StatefulWidget {
  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _checkEmailVerification();
  }

  void _checkEmailVerification() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) async {
      await user?.reload(); // Refresh the user's details
      user = _auth.currentUser; // Update the current user
      if (user?.emailVerified ?? false) {
        _timer?.cancel();
        Navigator.pushReplacementNamed(context, '/home'); // Redirect to home screen
      }
    });
  }

  Future<void> _resendVerificationEmail() async {
    try {
      await user?.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification email resent. Please check your inbox.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verify Email')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Please verify your email.'),
            Text('A verification email has been sent to ${user?.email}.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resendVerificationEmail,
              child: Text('Resend Verification Email'),
            ),
          ],
        ),
      ),
    );
  }
}
