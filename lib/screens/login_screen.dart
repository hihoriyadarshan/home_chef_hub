import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'user/home_screen.dart';
import 'Admin/admin_screen.dart';
import 'Chef_Screen/chef_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Invalid Email ID/Password', style: TextStyle(color: Colors.red)),
        content: Text("You have entered an invalid username or password"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _signIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          User? user = userCredential.user;
          DatabaseReference userRef = _database.ref().child('users').child(user!.uid);
          DataSnapshot snapshot = await userRef.get();

          if (snapshot.exists) {
            Map<String, dynamic> userData = Map<String, dynamic>.from(snapshot.value as Map);
            String? role = userData['role'];
            String? status = userData['status'];

            if (status == 'suspended') {
              _showErrorDialog('Your account has been suspended. Please contact admin.');
              return;
            } else if (status == 'disabled') {
              _showErrorDialog('Your account has been disabled. Please contact admin.');
              return;
            }

            if (role == 'Admin') {
              Navigator.pushReplacementNamed(context, '/Admin-dashboard');
            } else if (role == 'Chef') {
              Navigator.pushReplacementNamed(context, '/chef-home');
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          } else {
            _showErrorDialog('No user data found. Please contact admin.');
          }
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password') {
          _showErrorDialog('Incorrect password. Please try again.');
        } else if (e.code == 'user-not-found') {
          _showErrorDialog('No user found with this email.');
        } else {
          _showErrorDialog('Error: ${e.message}');
        }
      } catch (e) {
        _showErrorDialog('An unexpected error occurred. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign In',
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        backgroundColor: Color(0xFFD32F2F),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 50),
              CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/chef_logo.png'),
              ),
              SizedBox(height: 20),
              Text(
                'Home Chef Hub',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              // Email Text Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Password Text Field
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              // Sign In Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Sign In',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Don’t have an account?'),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                    child: Text('Sign Up', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Forgot your password?'),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/forget-password'),
                    child: Text('Reset Password', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
