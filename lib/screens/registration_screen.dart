import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'dart:io';
import '../models/user_model.dart';
import 'home_screen.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  File? _profileImage;
  html.File? _webImage;

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
      uploadInput.click();

      uploadInput.onChange.listen((e) async {
        final files = uploadInput.files;
        if (files == null || files.isEmpty) return;
        final reader = html.FileReader();
        reader.readAsDataUrl(files[0]!);
        reader.onLoadEnd.listen((e) {
          setState(() {
            _webImage = files[0];
          });
        });
      });
    } else {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    }
  }

  Future<String?> _uploadImage(String uid) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('profile_photos').child('$uid.jpg');

      if (kIsWeb && _webImage != null) {
        final uploadTask = storageRef.putBlob(_webImage!);
        final snapshot = await uploadTask.whenComplete(() {});
        return await snapshot.ref.getDownloadURL();
      } else if (!kIsWeb && _profileImage != null) {
        final uploadTask = storageRef.putFile(_profileImage!);
        final snapshot = await uploadTask.whenComplete(() {});
        return await snapshot.ref.getDownloadURL();
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
    return null;
  }

  void registerUser() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      User? user = userCredential.user;

      if (user != null) {
        String? profilePhotoUrl = await _uploadImage(user.uid);

        UserModel userModel = UserModel(
          uid: user.uid,
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          dob: _dobController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          profilePhotoUrl: profilePhotoUrl,
        );

        await _database.ref().child('users').child(user.uid).set(userModel.toMap());

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40),

              // Logo
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/chef_logo.png'),
              ),
              SizedBox(height: 20),

              // Sign Up Text
              Text(
                'SIGN UP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),

              // Already have an account and Login button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account', style: TextStyle(fontSize: 16)),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Login', style: TextStyle(color: Colors.red, fontSize: 16)),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Input Fields
              _buildTextField(_usernameController, 'Username'),
              SizedBox(height: 20),
              _buildTextField(_emailController, 'Email'),
              SizedBox(height: 20),
              _buildTextField(_passwordController, 'Password', obscureText: true),
              SizedBox(height: 20),
              _buildTextField(_dobController, 'Date of Birth'),
              SizedBox(height: 20),
              _buildTextField(_phoneController, 'Phone Number'),
              SizedBox(height: 20),
              _buildTextField(_addressController, 'Address'),
              SizedBox(height: 20),

              // Profile Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: kIsWeb
                    ? (_webImage == null
                    ? Icon(Icons.add_a_photo, size: 50)
                    : Image.network(html.Url.createObjectUrl(_webImage!), height: 100, width: 100, fit: BoxFit.cover))
                    : (_profileImage == null
                    ? Icon(Icons.add_a_photo, size: 50)
                    : Image.file(_profileImage!, height: 100, width: 100, fit: BoxFit.cover)),
              ),

              SizedBox(height: 20),

              // Social Media Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {}, // Handle Google login
                    icon: Image.asset('assets/google.png', width: 55, height: 55),
                  ),
                  IconButton(
                    onPressed: () {}, // Handle Facebook login
                    icon: Image.asset('assets/facebook.png', width: 55, height: 55),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Register Button
              ElevatedButton(
                onPressed: registerUser,
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool obscureText = false}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }
}
