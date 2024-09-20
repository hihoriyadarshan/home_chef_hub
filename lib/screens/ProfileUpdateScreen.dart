import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data'; // For web usage, where dart:io is not available
import 'dart:io' if (dart.library.html) 'dart:html'; // Conditional import for web
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
  final FirebaseStorage _storage = FirebaseStorage.instance; // Initialize Firebase Storage
  final _formKey = GlobalKey<FormState>();
  XFile? _image; // Change to XFile for web compatibility
  Uint8List? _imageBytes; // Bytes for web upload
  late String _username;
  late String _phone;
  late String _dob;
  late String _address;
  bool _isUploading = false; // State to manage image uploading

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
        _image = pickedFile;
      });

      if (kIsWeb) {
        // For web, read bytes directly
        _imageBytes = await pickedFile.readAsBytes();
      }
    }
  }

  Future<String?> _uploadImageToStorage() async {
    if (_image != null) {
      try {
        setState(() {
          _isUploading = true;
        });

        // Create a reference to Firebase Storage
        String fileName = _auth.currentUser!.uid + "_profile_image";
        Reference ref = _storage.ref().child("profile_images/$fileName");

        if (kIsWeb) {
          // For web, upload the bytes
          UploadTask uploadTask = ref.putData(_imageBytes!);
          TaskSnapshot snapshot = await uploadTask;

          // Get the download URL of the uploaded image
          String downloadUrl = await snapshot.ref.getDownloadURL();
          return downloadUrl;
        } else {
          // For mobile, upload the file directly
          File imageFile = File(_image!.path); // Convert XFile to File for mobile
          UploadTask uploadTask = ref.putFile(imageFile);
          TaskSnapshot snapshot = await uploadTask;

          // Get the download URL of the uploaded image
          String downloadUrl = await snapshot.ref.getDownloadURL();
          return downloadUrl;
        }
      } catch (e) {
        print('Error uploading image: $e');
        return null;
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    }
    return null;
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

        // Upload new profile image if selected and update profilePhotoUrl
        if (_image != null) {
          String? newImageUrl = await _uploadImageToStorage();
          if (newImageUrl != null) {
            updateData['profilePhotoUrl'] = newImageUrl;
          } else {
            print('Image upload failed');
          }
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
      body: _isUploading
          ? Center(child: CircularProgressIndicator()) // Show loader while uploading image
          : SingleChildScrollView(
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
                        color: Color(0xFF00CFFF), // The wave background color
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
                                  ? (kIsWeb
                                  ? MemoryImage(_imageBytes!)
                                  : FileImage(File(_image!.path))) // For web/mobile
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
                    backgroundColor: Color(0xFF00CFFF),
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
