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
import 'user/home_screen.dart';
import 'verify_email_screen.dart';

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
  final _formKey = GlobalKey<FormState>();

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
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Compress the image
      );
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
        // Create user with Firebase Authentication
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        User? user = userCredential.user;

        if (user != null) {
          String? profilePhotoUrl = await _uploadImage(user.uid);

          // Set initial status to 'active'
          UserModel userModel = UserModel(
            uid: user.uid,
            username: _usernameController.text.trim(),
            email: _emailController.text.trim(),
            dob: _dobController.text.trim(),
            phone: _phoneController.text.trim(),
            address: _addressController.text.trim(),
            profilePhotoUrl: profilePhotoUrl,
            role: _selectedRole,
            status: 'active', // Initial status is set to active
          );

          // Save user information to Firebase Database
          await _database.ref().child('users').child(user.uid).set(userModel.toMap());

          // Send email verification
          await user.sendEmailVerification();

          // Redirect to verification screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => VerifyEmailScreen()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildImagePicker() {
    return Stack(
      children: [
        // Profile Image
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[200],
          backgroundImage: _getImageProvider(),
          child: _getImageProvider() == null
              ? Icon(
            Icons.person,
            size: 60,
            color: Colors.grey[400],
          )
              : null,
        ),
        // Edit Icon
        Positioned(
          bottom: 0,
          right: 4,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  ImageProvider? _getImageProvider() {
    if (kIsWeb && _webImage != null) {
      return NetworkImage(html.Url.createObjectUrlFromBlob(_webImage!));
    } else if (!kIsWeb && _profileImage != null) {
      return FileImage(_profileImage!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFFD32F2F),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 40),
                _buildImagePicker(),
                SizedBox(height: 20),
                Text(
                  'SIGN UP',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account', style: TextStyle(fontSize: 16)),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Sign In',
                          style: TextStyle(color: Colors.red, fontSize: 16)),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _buildTextField(_usernameController, 'Username', validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                }),
                SizedBox(height: 20),
                _buildTextField(_emailController, 'Email', validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                }),
                SizedBox(height: 20),
                _buildTextField(_passwordController, 'Password',
                    obscureText: true, validator: (value) {
                      if (value == null || value.isEmpty || value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    }),
                SizedBox(height: 20),
                _buildTextField(_dobController, 'Date of Birth (dd/MM/yyyy)', validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      !RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
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
                    return 'Please enter your address';
                  }
                  return null;
                }),
                SizedBox(height: 30),

            Container(
              width: 500,
              height: 50,

              child: DropdownButtonFormField<String>(
                  value: _selectedRole,
                  items: ['User', 'Chef'].map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Select Role',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                  hint: Text('Select Role'),
                  onChanged: (String? value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a role';
                    }
                    return null;
                  },
                ),
            ),
              SizedBox(height: 30),
                ElevatedButton(
                  onPressed: registerUser,
                  child: Text('Sign Up',
                  style: TextStyle(fontSize: 18,
                      color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(

                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.red,

                    minimumSize: Size(500, 50),
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {bool obscureText = false, String? Function(String?)? validator}) {
    return Container(
      width: 500,
      height: 50,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.black), // Label color if needed
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey), // Default underline color
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red), // Underline color when focused
          ),
        ),
        obscureText: obscureText,
        validator: validator,
      ),
    );
  }
}
