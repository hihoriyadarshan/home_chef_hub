import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import '../../models/dishes_model.dart'; // Import the updated DishModel here
import '../../models/sub-category_model.dart';
import '../../models/category_model.dart'; // Import the CategoryModel
import 'package:firebase_auth/firebase_auth.dart'; // For getting current user's ID

class AddDishScreen extends StatefulWidget {
  @override
  _AddDishScreenState createState() => _AddDishScreenState();
}

class _AddDishScreenState extends State<AddDishScreen> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // For current user

  final TextEditingController _dishNameController = TextEditingController();
  final TextEditingController _dishDescriptionController = TextEditingController();
  final TextEditingController _dishPriceController = TextEditingController();

  File? _dishImage;
  html.File? _webImage;

  List<SubCategoryModel> _subCategories = [];
  List<CategoryModel> _categories = [];
  List<SubCategoryModel> _filteredSubCategories = []; // List for filtered subcategories
  SubCategoryModel? _selectedSubCategory;
  CategoryModel? _selectedCategory; // To hold the selected category
  String? _chefId; // To store the current chefId

  @override
  void initState() {
    super.initState();
    _fetchCategoriesAndSubCategories();
    _getCurrentChefId();
  }

  Future<void> _getCurrentChefId() async {
    // Assuming user is already authenticated
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _chefId = user.uid; // Get the current user's UID as chefId
      });
    }
  }

  Future<void> _fetchCategoriesAndSubCategories() async {
    await _fetchCategories();
    await _fetchSubCategories();
  }

  Future<void> _fetchCategories() async {
    final snapshot = await _database.ref().child('categories').once();
    final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      setState(() {
        _categories = data.values
            .map((value) => CategoryModel.fromMap(Map<String, dynamic>.from(value)))
            .toList();
      });
    }
  }

  Future<void> _fetchSubCategories() async {
    final snapshot = await _database.ref().child('subcategories').once();
    final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      setState(() {
        _subCategories = data.values
            .map((value) => SubCategoryModel.fromMap(Map<String, dynamic>.from(value)))
            .toList();
      });
    }
  }

  // Function to filter subcategories based on the selected category
  void _filterSubCategoriesByCategory(CategoryModel selectedCategory) {
    setState(() {
      _filteredSubCategories = _subCategories
          .where((subCategory) => subCategory.categoryId == selectedCategory.cid)
          .toList();
      _selectedSubCategory = null; // Reset subcategory selection when category changes
    });
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
          _dishImage = File(pickedFile.path);
        });
      }
    }
  }

  Future<String?> _uploadImage(String dishId) async {
    try {
      final storageRef = _storage.ref().child('dish_photos').child('$dishId.jpg');

      if (kIsWeb && _webImage != null) {
        final uploadTask = storageRef.putBlob(_webImage!);
        final snapshot = await uploadTask.whenComplete(() {});
        return await snapshot.ref.getDownloadURL();
      } else if (!kIsWeb && _dishImage != null) {
        final uploadTask = storageRef.putFile(_dishImage!);
        final snapshot = await uploadTask.whenComplete(() {});
        return await snapshot.ref.getDownloadURL();
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
    return null;
  }

  Future<void> _createDish() async {
    final dishName = _dishNameController.text.trim();
    final dishDescription = _dishDescriptionController.text.trim();
    final dishPrice = _dishPriceController.text.trim();

    if (dishName.isEmpty || _selectedSubCategory == null || _selectedCategory == null || dishPrice.isEmpty || _chefId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields and ensure you are signed in')),
      );
      return;
    }

    try {
      final dishId = DateTime.now().millisecondsSinceEpoch.toString(); // Unique ID
      String? dishImageUrl = await _uploadImage(dishId);

      // Pass chefId and categoryId when creating the dish
      DishModel dishModel = DishModel(
        dishId: dishId,
        dishName: dishName,
        dishDescription: dishDescription,
        dishPrice: double.tryParse(dishPrice) ?? 0.0,
        subCategoryId: _selectedSubCategory!.scid,
        categoryId: _selectedCategory!.cid, // Assign the categoryId
        chefId: _chefId!, // Assign the chefId (userId)
        dishImageUrl: dishImageUrl,
      );

      await _database.ref().child('dishes').child(dishId).set(dishModel.toMap());

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
          'Add Dish',
          style: TextStyle(fontSize: 24),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        backgroundColor: Colors.red,
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

              // Logo
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/chef_logo.png'),
              ),
              SizedBox(height: 20),

              Text(
                'ADD DISH',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              // Category Dropdown
              DropdownButton<CategoryModel>(
                value: _selectedCategory,
                hint: Text('Select Category'),
                items: _categories.map((category) {
                  return DropdownMenuItem<CategoryModel>(
                    value: category,
                    child: Text(category.category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                  if (_selectedCategory != null) {
                    _filterSubCategoriesByCategory(_selectedCategory!); // Filter subcategories
                  }
                },
              ),

              SizedBox(height: 20),

              // Subcategory Dropdown (Filtered based on the selected category)
              DropdownButton<SubCategoryModel>(
                value: _selectedSubCategory,
                hint: Text('Select Sub-Category'),
                items: _filteredSubCategories.map((subCategory) {
                  return DropdownMenuItem<SubCategoryModel>(
                    value: subCategory,
                    child: Row(
                      children: [
                        subCategory.subCategoryPhotoUrl != null
                            ? Image.network(
                          subCategory.subCategoryPhotoUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        )
                            : SizedBox(width: 40, height: 40), // Placeholder if no photo
                        SizedBox(width: 10),
                        Text(subCategory.subCategory),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedSubCategory = newValue;
                  });
                },
              ),

              SizedBox(height: 20),

              // Dish Name
              TextField(
                controller: _dishNameController,
                decoration: InputDecoration(labelText: 'Dish Name'),
              ),

              // Dish Description
              TextField(
                controller: _dishDescriptionController,
                decoration: InputDecoration(labelText: 'Dish Description'),
              ),

              // Dish Price
              TextField(
                controller: _dishPriceController,
                decoration: InputDecoration(labelText: 'Dish Price'),
                keyboardType: TextInputType.number,
              ),

              SizedBox(height: 20),

              // Upload Dish Image Button
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image),
                label: Text('Upload Dish Image'),
              ),

              SizedBox(height: 20),

              // Create Dish Button
              ElevatedButton(
                onPressed: _createDish,
                child: Text('Create Dish'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
