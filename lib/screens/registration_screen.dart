import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'dart:io';
import 'package:intl/intl.dart';
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
  final _formKey = GlobalKey<FormState>();  // Form key for validation

  File? _profileImage;
  html.File? _webImage;

  String? _selectedRole;

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
    if (_formKey.currentState!.validate()) {
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
            role: _selectedRole,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,  // Wrap with Form widget and assign the key
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

                // Input Fields with validation
                _buildTextField(_usernameController, 'Username', validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                }),
                SizedBox(height: 20),
                _buildTextField(_emailController, 'Email', validator: (value) {
                  if (value == null || value.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                }),
                SizedBox(height: 20),
                _buildTextField(_passwordController, 'Password', obscureText: true, validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                }),
                SizedBox(height: 20),
                _buildTextField(_dobController, 'Date of Birth (dd/MM/yyyy)', validator: (value) {
                  if (value == null || value.isEmpty || !RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
                    return 'Please enter a valid date (dd/MM/yyyy)';
                  }
                  return null;
                }),
                SizedBox(height: 20),
                _buildTextField(_phoneController, 'Phone Number', validator: (value) {
                  if (value == null || value.isEmpty || !RegExp(r'^\d+$').hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                }),
                SizedBox(height: 20),
                _buildTextField(_addressController, 'Address', validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                }),
                SizedBox(height: 20),

                // Role Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedRole = newValue;
                    });
                  },
    // items: ['User', 'Chef', 'Admin'].map((role) {

                  items: ['User', 'Chef'].map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Select Role',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Color(0xFF565458)), // Custom border color
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a role';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Profile Image Picker
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF565458), width: 2), // Border color and width
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                    ),
                    child: Center(
                      child: kIsWeb
                          ? (_webImage == null
                          ? Icon(Icons.add_a_photo, size: 50)
                          : Image.network(html.Url.createObjectUrl(_webImage!), height: 100, width: 100, fit: BoxFit.cover))
                          : (_profileImage == null
                          ? Icon(Icons.add_a_photo, size: 50)
                          : Image.file(_profileImage!, height: 100, width: 100, fit: BoxFit.cover)),
                    ),
                  ),
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
                  child: Text('Register'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {bool obscureText = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Color(0xFF565458)), // Custom border color
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator,
    );
  }
}
