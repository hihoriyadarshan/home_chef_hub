import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:html' as html;
import 'dart:io';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
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
  DateTime? _selectedDate;

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
      uploadInput.click();
      uploadInput.onChange.listen((e) async {
        final files = uploadInput.files;
        if (files != null && files.isNotEmpty) {
          final reader = html.FileReader();
          reader.readAsDataUrl(files[0]);
          reader.onLoadEnd.listen((_) {
            setState(() {
              _webImage = files[0];
            });
          });
        }
      });
    } else {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    }
  }

  Future<String?> _uploadImage(String uid) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('profile_photos/$uid.jpg');
      if (kIsWeb && _webImage != null) {
        final uploadTask = storageRef.putBlob(_webImage!);
        final snapshot = await uploadTask.whenComplete(() {});
        return await snapshot.ref.getDownloadURL();
      } else if (_profileImage != null) {
        final uploadTask = storageRef.putFile(_profileImage!);
        final snapshot = await uploadTask.whenComplete(() {});
        return await snapshot.ref.getDownloadURL();
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
    return null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dobController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
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
            status: 'active',
          );

          await _database.ref().child('users').child(user.uid).set(userModel.toMap());
          await user.sendEmailVerification();
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VerifyEmailScreen()));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _buildImagePicker() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[200],
          backgroundImage: _getImageProvider(),
          child: _getImageProvider() == null
              ? Icon(Icons.person, size: 60, color: Colors.grey[400])
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 4,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
              padding: EdgeInsets.all(8),
              child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  ImageProvider? _getImageProvider() {
    if (kIsWeb && _webImage != null) {
      return NetworkImage(html.Url.createObjectUrlFromBlob(_webImage!));
    } else if (_profileImage != null) {
      return FileImage(_profileImage!);
    }
    return null;
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {bool obscureText = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up'), backgroundColor: Colors.red),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 40),
              _buildImagePicker(),
              SizedBox(height: 20),
              Text('SIGN UP', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              _buildTextField(_usernameController, 'Username', validator: (value) => value!.isEmpty ? 'Please enter a username' : null),
              SizedBox(height: 20),
              _buildTextField(_emailController, 'Email', validator: (value) => value!.isEmpty ? 'Please enter a valid email' : null),
              SizedBox(height: 20),
              _buildTextField(_passwordController, 'Password', obscureText: true, validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters long' : null),
              SizedBox(height: 20),
              TextFormField(
                controller: _dobController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  labelText: 'Date of Birth (dd/MM/yyyy)',
                  suffixIcon: Icon(Icons.calendar_today),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                ),
                validator: (value) => value!.isEmpty ? 'Please select your date of birth' : null,
              ),
              SizedBox(height: 20),
              _buildTextField(_phoneController, 'Phone Number', validator: (value) => value!.isEmpty ? 'Please enter a valid phone number' : null),
              SizedBox(height: 20),
              _buildTextField(_addressController, 'Address', validator: (value) => value!.isEmpty ? 'Please enter your address' : null),
              SizedBox(height: 30),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: ['User', 'Chef'].map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
                decoration: InputDecoration(labelText: 'Select Role', enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red))),
                onChanged: (String? value) => setState(() => _selectedRole = value),
                validator: (value) => value == null ? 'Please select a role' : null,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: registerUser,
                child: Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12)),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
