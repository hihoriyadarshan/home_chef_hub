import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/category_model.dart';

class ManageCategoryScreen extends StatefulWidget {
  @override
  _ManageCategoryScreenState createState() => _ManageCategoryScreenState();
}

class _ManageCategoryScreenState extends State<ManageCategoryScreen> {
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

  Future<void> _updateCategory(CategoryModel category) async {
    _categoryNameController.text = category.category;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(_categoryNameController, 'Category Name'),
              SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF565458), width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: kIsWeb
                        ? (_webImage == null
                        ? (_categoryImage == null
                        ? Icon(Icons.add_a_photo, size: 50)
                        : Image.network(category.categoryPhotoUrl ?? '',
                        height: 100, width: 100, fit: BoxFit.cover))
                        : Image.network(
                        html.Url.createObjectUrl(_webImage!),
                        height: 100, width: 100, fit: BoxFit.cover))
                        : (_categoryImage == null
                        ? (_categoryImage == null
                        ? Icon(Icons.add_a_photo, size: 50)
                        : Image.file(_categoryImage!,
                        height: 100, width: 100, fit: BoxFit.cover))
                        : Image.file(_categoryImage!,
                        height: 100, width: 100, fit: BoxFit.cover)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String? categoryPhotoUrl = await _uploadImage(category.cid);
                category = CategoryModel(
                  cid: category.cid,
                  category: _categoryNameController.text.trim(),
                  categoryPhotoUrl: categoryPhotoUrl ?? category.categoryPhotoUrl,
                );

                await _database
                    .ref()
                    .child('categories')
                    .child(category.cid)
                    .set(category.toMap());

                Navigator.pop(context);
                // Refresh the page after updating
                setState(() {});
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _uploadImage(String cid) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('category_photos')
          .child('$cid.jpg');

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

  Future<void> _deleteCategory(String cid) async {
    try {
      await _database.ref().child('categories').child(cid).remove();
      await FirebaseStorage.instance.ref().child('category_photos/$cid.jpg').delete();
      // Refresh the page after deleting
      setState(() {});
    } catch (e) {
      print('Error deleting category: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Manage Categories'),
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder<DataSnapshot>(
        future: _database.ref().child('categories').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.value == null) {
            return Center(child: Text('No categories found.'));
          }

          Map<dynamic, dynamic> categoriesMap = Map<dynamic, dynamic>.from(snapshot.data!.value as Map);
          List<CategoryModel> categories = categoriesMap.entries.map((entry) {
            Map<String, dynamic> categoryData = Map<String, dynamic>.from(entry.value);
            return CategoryModel.fromMap(categoryData);
          }).toList();

          return _buildDataTable(categories);
        },
      ),
    );
  }

  // Method to build the DataTable
  Widget _buildDataTable(List<CategoryModel> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Image')),
          DataColumn(label: Text('Category Name')),
          DataColumn(label: Text('Edit')),
          DataColumn(label: Text('Delete')),
        ],
        rows: categories.map((category) {
          return DataRow(cells: [
            DataCell(category.categoryPhotoUrl != null
                ? Image.network(category.categoryPhotoUrl!, width: 50, height: 50, fit: BoxFit.cover)
                : Icon(Icons.image)),
            DataCell(Text(category.category)),
            DataCell(
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _updateCategory(category),
              ),
            ),
            DataCell(
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  bool? confirmDelete = await _showDeleteConfirmDialog();
                  if (confirmDelete == true) {
                    _deleteCategory(category.cid);
                  }
                },
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Category'),
          content: Text('Are you sure you want to delete this category?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); // Dismiss the dialog
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm delete
              },
            ),
          ],
        );
      },
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
