import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/sub-category_model.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  CategoryDetailsScreen({required this.categoryId, required this.categoryName});

  @override
  _CategoryDetailsScreenState createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  List<SubCategoryModel> _subCategories = [];

  @override
  void initState() {
    super.initState();
    _fetchSubCategories();
  }

  Future<void> _fetchSubCategories() async {
    final snapshot = await _database
        .ref()
        .child('subcategories')
        .orderByChild('categoryId')
        .equalTo(widget.categoryId)
        .once();

    final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      setState(() {
        _subCategories = data.values.map((value) => SubCategoryModel.fromMap(Map<String, dynamic>.from(value))).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.categoryName} Subcategories'),
        backgroundColor: Colors.red,
      ),
      body: _subCategories.isEmpty
          ? Center(child: Text('No Subcategories Found'))
          : ListView.builder(
        itemCount: _subCategories.length,
        itemBuilder: (context, index) {
          final subCategory = _subCategories[index];
          return ListTile(
            leading: subCategory.subCategoryPhotoUrl != null
                ? Image.network(
              subCategory.subCategoryPhotoUrl!,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            )
                : Icon(Icons.category, size: 50),
            title: Text(subCategory.subCategory),
          );
        },
      ),
    );
  }
}
