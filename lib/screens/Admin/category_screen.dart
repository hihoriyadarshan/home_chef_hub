import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import '../../models/category_model.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final TextEditingController _categoryNameController = TextEditingController();
  File? _categoryImage;
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
          _categoryImage = File(pickedFile.path);
        });
      }
    }
  }

  Future<String?> _uploadImage(String cid) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('category_photos').child('$cid.jpg');

      if (kIsWeb && _webImage != null) {
        final uploadTask = storageRef.putBlob(_webImage!);
        final snapshot = await uploadTask.whenComplete(() {});
        return await snapshot.ref.getDownloadURL();
      } else if (!kIsWeb && _categoryImage != null) {
        final uploadTask = storageRef.putFile(_categoryImage!);
        final snapshot = await uploadTask.whenComplete(() {});
        return await snapshot.ref.getDownloadURL();
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
    return null;
  }

  Future<bool> _checkCategoryExists(String categoryName) async {
    final snapshot = await _database
        .ref()
        .child('categories')
        .orderByChild('category')
        .equalTo(categoryName)
        .once();
    return snapshot.snapshot.exists;
  }

  void createCategory() async {
    final categoryName = _categoryNameController.text.trim();

    if (categoryName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    // Check if the category already exists
    final exists = await _checkCategoryExists(categoryName);
    if (exists) {
      _showAlertDialog('Category already exists');
      return;
    }

    try {
      final cid = DateTime.now().millisecondsSinceEpoch.toString(); // Unique ID
      String? categoryPhotoUrl = await _uploadImage(cid);

      CategoryModel categoryModel = CategoryModel(
        cid: cid,
        category: categoryName,
        categoryPhotoUrl: categoryPhotoUrl,
      );

      await _database.ref().child('categories').child(cid).set(categoryModel.toMap());

      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigates back to the previous screen
          },
        ),
        title: Text('Create Category'),
        backgroundColor: Colors.red,
      ),
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

              // Create Category Text
              Text(
                'CREATE CATEGORY',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),

              // Input Fields
              _buildTextField(_categoryNameController, 'Category Name'),
              SizedBox(height: 20),

              // Category Image Picker
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
                        : Image.network(html.Url.createObjectUrl(_webImage!),
                        height: 100, width: 100, fit: BoxFit.cover))
                        : (_categoryImage == null
                        ? Icon(Icons.add_a_photo, size: 50)
                        : Image.file(_categoryImage!,
                        height: 100, width: 100, fit: BoxFit.cover)),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Create Button
              ElevatedButton(
                onPressed: createCategory,
                child: Text('Create Category'),
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
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Color(0xFF565458)), // Custom border color
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Color(0xFF565458)), // Custom border color
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Color(0xFF565458)), // Custom border color
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
