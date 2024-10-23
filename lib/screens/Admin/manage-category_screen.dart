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
  final TextEditingController _searchController = TextEditingController(); // Controller for search bar

  List<CategoryModel> _categories = []; // Full list of categories
  List<CategoryModel> _filteredCategories = []; // Filtered list based on search
  File? _categoryImage;
  html.File? _webImage;

  @override
  void initState() {
    super.initState();
    _loadCategories(); // Load categories on init
  }

  Future<void> _loadCategories() async {
    final snapshot = await _database.ref().child('categories').get();
    if (snapshot.exists) {
      Map<dynamic, dynamic> categoriesMap = Map<dynamic, dynamic>.from(snapshot.value as Map);
      List<CategoryModel> categories = categoriesMap.entries.map((entry) {
        Map<String, dynamic> categoryData = Map<String, dynamic>.from(entry.value);
        return CategoryModel.fromMap(categoryData);
      }).toList();

      setState(() {
        _categories = categories;
        _filteredCategories = categories;
      });
    }
  }

  void _filterCategories(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredCategories = _categories;
      });
    } else {
      setState(() {
        _filteredCategories = _categories
            .where((category) => category.category.toLowerCase().contains(query.toLowerCase()))
            .toList();
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
                setState(() {
                  _loadCategories();
                });
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
      setState(() {
        _loadCategories();
      });
    } catch (e) {
      print('Error deleting category: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Manage Categories',
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
            )),
        backgroundColor: Color(0xFFD32F2F),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Categories',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (query) => _filterCategories(query),
            ),
          ),
          Expanded(
            child: _buildDataTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Color(0xFFF1F1F1)),
            columnSpacing: 100,
            horizontalMargin: 100,
            dividerThickness: 4,
            columns: [
              DataColumn(
                  label: Text(
                    'S.No',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              DataColumn(
                  label: Text(
                    'Image',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              DataColumn(
                  label: Text(
                    'Category Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              DataColumn(
                  label: Text(
                    'Edit',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              DataColumn(
                  label: Text(
                    'Delete',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
            ],
            rows: _filteredCategories.asMap().entries.map((entry) {
              int index = entry.key;
              CategoryModel category = entry.value;
              bool isOdd = index % 2 == 0;
              return DataRow(
                color: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                      return isOdd ? Colors.grey[200] : null;
                    }),
                cells: [
                  DataCell(Text('${index + 1}')), // Auto-incremented S.No.
                  DataCell(Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: category.categoryPhotoUrl != null
                        ? Image.network(category.categoryPhotoUrl!,
                        width: 70, height: 70, fit: BoxFit.cover)
                        : Icon(Icons.image),
                  )),
                  DataCell(Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(category.category),
                  )),
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
                ],
              );
            }).toList(),
          ),
        ),
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
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
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
          borderSide: BorderSide(color: Color(0xFF565458)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Color(0xFF565458)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Color(0xFF565458)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
