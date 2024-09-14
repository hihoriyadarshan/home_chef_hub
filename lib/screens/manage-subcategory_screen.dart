import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:html' as html;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/sub-category_model.dart';

class ManageSubCategoryScreen extends StatefulWidget {
  @override
  _ManageSubCategoryScreenState createState() => _ManageSubCategoryScreenState();
}

class _ManageSubCategoryScreenState extends State<ManageSubCategoryScreen> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  List<SubCategoryModel> _subCategories = [];

  @override
  void initState() {
    super.initState();
    _fetchSubCategories();
  }

  Future<void> _fetchSubCategories() async {
    final snapshot = await _database.ref().child('subcategories').once();
    final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      setState(() {
        _subCategories = data.values.map((value) => SubCategoryModel.fromMap(Map<String, dynamic>.from(value))).toList();
      });
    }
  }

  Future<void> _deleteSubCategory(String scid) async {
    try {
      await _database.ref().child('subcategories').child(scid).remove();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Subcategory deleted successfully')));
      _fetchSubCategories(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _openUpdateSubCategoryForm(SubCategoryModel subCategory) {
    showDialog(
      context: context,
      builder: (context) {
        return UpdateSubCategoryForm(
          subCategory: subCategory,
          onUpdate: _fetchSubCategories, // Refresh after update
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Subcategories'),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        itemCount: _subCategories.length,
        itemBuilder: (context, index) {
          final subCategory = _subCategories[index];
          return Card(
            child: ListTile(
              leading: subCategory.subCategoryPhotoUrl != null
                  ? Image.network(subCategory.subCategoryPhotoUrl!, width: 50, height: 50, fit: BoxFit.cover)
                  : SizedBox(width: 50, height: 50), // Placeholder if no photo
              title: Text(subCategory.subCategory),
              subtitle: Text('Category ID: ${subCategory.categoryId}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _openUpdateSubCategoryForm(subCategory),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteSubCategory(subCategory.scid),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class UpdateSubCategoryForm extends StatefulWidget {
  final SubCategoryModel subCategory;
  final VoidCallback onUpdate;

  UpdateSubCategoryForm({required this.subCategory, required this.onUpdate});

  @override
  _UpdateSubCategoryFormState createState() => _UpdateSubCategoryFormState();
}

class _UpdateSubCategoryFormState extends State<UpdateSubCategoryForm> {
  final TextEditingController _subCategoryNameController = TextEditingController();
  File? _subcategoryImage;
  html.File? _webImage;

  // Define FirebaseStorage instance
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _subCategoryNameController.text = widget.subCategory.subCategory;
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
      uploadInput.click();

      uploadInput.onChange.listen((e) {
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

  Future<void> _updateSubCategory() async {
    final subCategoryName = _subCategoryNameController.text.trim();
    if (subCategoryName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Subcategory name cannot be empty')));
      return;
    }

    try {
      String? subCategoryPhotoUrl = await _uploadImage(widget.subCategory.scid) ?? widget.subCategory.subCategoryPhotoUrl;

      SubCategoryModel updatedSubCategory = SubCategoryModel(
        scid: widget.subCategory.scid,
        subCategory: subCategoryName,
        categoryId: widget.subCategory.categoryId,
        subCategoryPhotoUrl: subCategoryPhotoUrl,
      );

      await FirebaseDatabase.instance
          .ref()
          .child('subcategories')
          .child(widget.subCategory.scid)
          .set(updatedSubCategory.toMap());

      Navigator.of(context).pop(); // Close the pop-up form
      widget.onUpdate(); // Trigger update callback
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update Subcategory'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: _subCategoryNameController,
              decoration: InputDecoration(labelText: 'Sub-Category Name'),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _updateSubCategory,
          child: Text('Update'),
        ),
      ],
    );
  }
}
