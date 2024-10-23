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

  void _signIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          User? user = userCredential.user;

          if (user != null) {
            // Fetch user data from Firebase Realtime Database
            DatabaseReference userRef = _database.ref().child('users').child(user.uid);
            DataSnapshot snapshot = await userRef.get();

            if (snapshot.exists) {
              Map<String, dynamic> userData = Map<String, dynamic>.from(snapshot.value as Map);

              String? role = userData['role'];
              String? status = userData['status'];

              // Check the status of the user
              if (status == 'suspended') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Your account has been suspended. Please contact admin.')),
                );
                return; // Prevent login if the account is suspended
              }

              if (status == 'disabled') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Your account has been disabled. Please contact admin.')),
                );
                return; // Prevent login if the account is disabled
              }

              // Navigate to the appropriate screen based on the user's role
              if (role == 'Admin') {
                Navigator.pushReplacementNamed(context, '/Admin-dashboard');
              } else if (role == 'Chef') {
                Navigator.pushReplacementNamed(context, '/chef-home');
              } else {
                Navigator.pushReplacementNamed(context, '/home');

              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('No user data found. Please contact admin.')),
              );
            }
          }
        }
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
            'Sign In',
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          backgroundColor: Color(0xFFD32F2F),
          automaticallyImplyLeading: false,
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 70),
              // Logo
              CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/chef_logo.png'),
              ),
              SizedBox(height: 20),

              Text(
                'Home Chef Hub',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30), // for margin


                // Email text field
              SizedBox(
                width: 500,  // Set the width of the input field
                height: 50,
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 30), // for margin
              // Password text field
              SizedBox(
                width: 500,
                height: 50,
                child: TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
              ),
              // login button
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: Size( 500,50),
                ),
                child: Text(
                  'Sign In',
                  style: TextStyle(fontSize: 18,
                    color: Colors.white,
                  )

                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Don’t have an account?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Click  to Forget Password'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forget-password');
                    },
                    child: Text(
                      'Forget Password',
                      style: TextStyle(color: Colors.red),
                    ),
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
