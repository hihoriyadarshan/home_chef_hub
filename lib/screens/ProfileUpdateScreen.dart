import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user_model.dart';
import 'profile_screen.dart';

class ProfileUpdateScreen extends StatefulWidget {
  final UserModel userModel;

  ProfileUpdateScreen({required this.userModel});

  @override
  _ProfileUpdateScreenState createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final _formKey = GlobalKey<FormState>();
  File? _image;
  late String _username;
  late String _phone;
  late String _dob;
  late String _address;

  @override
  void initState() {
    super.initState();
    _username = widget.userModel.username;
    _phone = widget.userModel.phone;
    _dob = widget.userModel.dob;
    _address = widget.userModel.address;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      User? user = _auth.currentUser;
      if (user != null) {
        DatabaseReference userRef = _database.ref().child('users').child(user.uid);

        Map<String, dynamic> updateData = {
          'username': _username,
          'phone': _phone,
          'dob': _dob,
          'address': _address,
        };

        // Upload new profile image if selected
        if (_image != null) {
          // Here, you would upload the image to Firebase Storage and get the URL
          // For simplicity, we assume the image URL is "new_image_url"
          String newImageUrl = "new_image_url"; // Replace this with actual upload logic
          updateData['profilePhotoUrl'] = newImageUrl;
        }

        await userRef.update(updateData);
        Navigator.pop(context, true); // Return true to indicate profile was updated
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Update Profile',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Stack(
                  children: [
                    ClipPath(
                      clipper: WaveClipper(),
                      child: Container(
                        height: 200,
                        color: Colors.red, // The wave background color
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          SizedBox(height: 50), // Adjusted for wave effect
                          GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: _image != null
                                  ? FileImage(_image!)
                                  : widget.userModel.profilePhotoUrl != null
                                  ? NetworkImage(widget.userModel.profilePhotoUrl!)
                                  : AssetImage('assets/default_avatar.png') as ImageProvider,
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            widget.userModel.username ?? 'N/A',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileUpdateField(
                        icon: Icons.account_circle,
                        label: 'Name',
                        initialValue: _username,
                        onSaved: (value) {
                          _username = value!;
                        },
                      ),
                      ProfileInfoRow(
                        icon: Icons.email,
                        label: 'E-Mail',
                        value: widget.userModel.email,
                      ),
                      ProfileUpdateField(
                        icon: Icons.phone,
                        label: 'Phone no.',
                        initialValue: _phone,
                        onSaved: (value) {
                          _phone = value!;
                        },
                      ),
                      ProfileUpdateField(
                        icon: Icons.calendar_today,
                        label: 'Date of Birth',
                        initialValue: _dob,
                        onSaved: (value) {
                          _dob = value!;
                        },
                      ),
                      ProfileUpdateField(
                        icon: Icons.home,
                        label: 'Address',
                        initialValue: _address,
                        onSaved: (value) {
                          _address = value!;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateProfile,
                  child: Text('Update Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
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

class ProfileUpdateField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String initialValue;
  final Function(String?)? onSaved;

  ProfileUpdateField({
    required this.icon,
    required this.label,
    required this.initialValue,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              initialValue: initialValue,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter $label';
                }
                return null;
              },
              onSaved: onSaved,
            ),
          ),
        ],
      ),
    );
  }
}
