import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import '../models/sub-category_model.dart';
import '../models/category_model.dart';

class SubCategoryScreen extends StatefulWidget {
  @override
  _SubCategoryScreenState createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController _subCategoryNameController = TextEditingController();
  File? _subcategoryImage;
  html.File? _webImage;
  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final snapshot = await _database.ref().child('categories').once();
    final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      setState(() {
        _categories = data.values.map((value) => CategoryModel.fromMap(Map<String, dynamic>.from(value))).toList();
      });
    }
  }

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
          _subcategoryImage = File(pickedFile.path);
        });
      }
    }
  }

  Future<String?> _uploadImage(String scid) async {
    try {
      final storageRef = _storage.ref().child('subcategory_photos').child('$scid.jpg');

      if (kIsWeb && _webImage != null) {
        final uploadTask = storageRef.putBlob(_webImage!);
        final snapshot = await uploadTask.whenComplete(() {});
        return await snapshot.ref.getDownloadURL();
      } else if (!kIsWeb && _subcategoryImage != null) {
        final uploadTask = storageRef.putFile(_subcategoryImage!);
        final snapshot = await uploadTask.whenComplete(() {});
        return await snapshot.ref.getDownloadURL();
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
    return null;
  }

  Future<void> _createSubCategory() async {
    final subCategoryName = _subCategoryNameController.text.trim();

    if (subCategoryName.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a subcategory name and select a category')),
      );
      return;
    }

    try {
      final scid = DateTime.now().millisecondsSinceEpoch.toString(); // Unique ID
      String? subCategoryPhotoUrl = await _uploadImage(scid);

      SubCategoryModel subCategoryModel = SubCategoryModel(
        scid: scid,
        subCategory: subCategoryName,
        categoryId: _selectedCategory!.cid,
        subCategoryPhotoUrl: subCategoryPhotoUrl,
      );

      await _database.ref().child('subcategories').child(scid).set(subCategoryModel.toMap());

      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Sub-Category',
          style: TextStyle(
            // fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        backgroundColor: Colors.red, // You can adjust the color as per your design
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40),

              //Logo

              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/chef_logo.png'),
              ),
              SizedBox(height: 20),

              Text(
                'CREATE SUB-CATEGORY',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),


              // Category Dropdown with Photo
              DropdownButton<CategoryModel>(
                value: _selectedCategory,
                hint: Text('Select Category'),
                items: _categories.map((category) {
                  return DropdownMenuItem<CategoryModel>(
                    value: category,
                    child: Row(
                      children: [
                        category.categoryPhotoUrl != null
                            ? Image.network(
                          category.categoryPhotoUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        )
                            : SizedBox(width: 40, height: 40), // Placeholder if no photo
                        SizedBox(width: 10),
                        Text(category.category),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              SizedBox(height: 20),

              // Input Fields
              _buildTextField(_subCategoryNameController, 'Sub-Category Name'),
              SizedBox(height: 20),

              // Subcategory Image Picker
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
                        : (_subcategoryImage == null
                        ? Icon(Icons.add_a_photo, size: 50)
                        : Image.file(_subcategoryImage!, height: 100, width: 100, fit: BoxFit.cover)),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Create Button
              ElevatedButton(
                onPressed: _createSubCategory,
                child: Text('Create Sub-Category'),
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
