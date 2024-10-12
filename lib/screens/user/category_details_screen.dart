import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../models/sub-category_model.dart';
import 'show_dish_details.dart'; // Import the new screen

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
        _subCategories = data.values
            .map((value) =>
            SubCategoryModel.fromMap(Map<String, dynamic>.from(value)))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildCustomAppBar(),
      body: Column(
        children: [
          _buildCarouselSlider(),
          Expanded(child: _buildSubCategoryGrid()),
        ],
      ),
      bottomNavigationBar: _buildFooter(),
    );
  }

  AppBar _buildCustomAppBar() {
    return AppBar(
      title: Text('${widget.categoryName} Subcategories',
          style: TextStyle(fontWeight: FontWeight.bold)),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red, Colors.orange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      centerTitle: true,
      elevation: 0,
    );
  }

  Widget _buildCarouselSlider() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 150,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 3),
        enlargeCenterPage: true,
      ),
      items: [
        _buildOfferSlide('50% OFF!', Colors.greenAccent),
        _buildOfferSlide('New Add-ons Available', Colors.orangeAccent),
        _buildOfferSlide('Exclusive Deals', Colors.redAccent),
      ],
    );
  }

  Widget _buildOfferSlide(String text, Color bgColor) {
    return Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Responsive subcategory grid with card views
  Widget _buildSubCategoryGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine the number of columns based on screen width
        int crossAxisCount = constraints.maxWidth > 800 ? 4 : 2; // 4 columns for desktop, 2 for mobile

        return _subCategories.isEmpty
            ? Center(
          child: Text('No Subcategories Found',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
        )
            : GridView.builder(
          padding: EdgeInsets.all(10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount, // Responsive column count
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.0,
          ),
          itemCount: _subCategories.length,
          itemBuilder: (context, index) {
            final subCategory = _subCategories[index];
            return _buildSubCategoryBox(subCategory);
          },
        );
      },
    );
  }

  // Individual subcategory card with hover effect and navigation
  Widget _buildSubCategoryBox(SubCategoryModel subCategory) {
    return GestureDetector(
      onTap: () {
        // Navigate to ShowDishDetailsScreen with the selected subCategoryId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ShowDishDetailsScreen(subCategoryId: subCategory.scid),
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() {}),
        onExit: (_) => setState(() {}),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
            border: Border.all(
              color: Colors.white,
              width: 5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              subCategory.subCategoryPhotoUrl != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  subCategory.subCategoryPhotoUrl!,
                  width: 502,
                  height: 320,
                  fit: BoxFit.cover,
                ),
              )
                  : Icon(Icons.category, size: 70, color: Colors.orange),
              SizedBox(height: 8),
              Text(
                subCategory.subCategory,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return BottomAppBar(
      color: Colors.white,
      elevation: 10,
      shape: CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFooterIcon(Icons.home, 'Home'),
          _buildFooterIcon(Icons.category, 'Categories'),
          SizedBox(width: 20),
          _buildFooterIcon(Icons.favorite, 'Favorites'),
          _buildFooterIcon(Icons.account_circle, 'Account'),
        ],
      ),
    );
  }

  Widget _buildFooterIcon(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.red),
          onPressed: () {},
        ),
        Text(label, style: TextStyle(color: Colors.red)),
      ],
    );
  }
}
