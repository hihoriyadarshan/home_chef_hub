import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/dishes_model.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // Rating bar package
import '../user/chef_booking_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShowDishDetailsScreen extends StatefulWidget {
  final String subCategoryId;

  ShowDishDetailsScreen({required this.subCategoryId});

  @override
  _ShowDishDetailsScreenState createState() => _ShowDishDetailsScreenState();
}

class _ShowDishDetailsScreenState extends State<ShowDishDetailsScreen> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  List<DishModel> _dishes = [];

  @override
  void initState() {
    super.initState();
    _fetchDishes();
  }

  Future<void> _fetchDishes() async {
    final snapshot = await _database
        .ref()
        .child('dishes')
        .orderByChild('subCategoryId')
        .equalTo(widget.subCategoryId)
        .once();

    final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      setState(() {
        _dishes = data.values
            .map((value) => DishModel.fromMap(Map<String, dynamic>.from(value)))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildCustomAppBar(),
      body: _dishes.isEmpty
          ? Center(
        child: Text(
          'No Dishes Found',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: _dishes.length,
        itemBuilder: (context, index) {
          final dish = _dishes[index];
          return _buildDishCard(dish, context);
        },
      ),
    );
  }

  AppBar _buildCustomAppBar() {
    return AppBar(
      title: Text(
        'Dishes',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
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

  // Responsive dish card design
  Widget _buildDishCard(DishModel dish, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            screenWidth > 400 ? _buildHorizontalLayout(dish, context) : _buildVerticalLayout(dish, context),
          ],
        ),
      ),
    );
  }

  // Layout for larger screens (image and content side by side)
  Widget _buildHorizontalLayout(DishModel dish, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDishImage(dish),
        SizedBox(width: 10),
        Expanded(child: _buildDishDetails(dish, context)),
      ],
    );
  }

  // Layout for smaller screens (image and content stacked)
  Widget _buildVerticalLayout(DishModel dish, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDishImage(dish),
        SizedBox(height: 10),
        _buildDishDetails(dish, context),
      ],
    );
  }

  // Dish image widget with rounded corners
  Widget _buildDishImage(DishModel dish) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: dish.dishImageUrl != null
          ? Image.network(
        dish.dishImageUrl!,
        height: 180,
        width: 180,
        fit: BoxFit.cover,
      )
          : Icon(Icons.fastfood, size: 100, color: Colors.orange),
    );
  }

  // Dish details widget (name, description, price, rating, and buttons)
  Widget _buildDishDetails(DishModel dish, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dish.dishName,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 5),
        Text(
          dish.dishDescription,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 10),
        Text(
          '\$${dish.dishPrice.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
        ),
        SizedBox(height: 10),
        RatingBar.builder(
          initialRating: 5,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {
            print(rating);
          },
        ),
        SizedBox(height: 10),
        _buildResponsiveButtons(context, dish),
      ],
    );
  }

  // Responsive button layout
  Widget _buildResponsiveButtons(BuildContext context, DishModel dish) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 30 : 15, vertical: 10),
          ),
          onPressed: () async {
            // Get the current authenticated user ID
            final String? userId = FirebaseAuth.instance.currentUser?.uid;

            if (userId != null) {
              // Navigate to the ChefBookingScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChefBookingScreen(
                    userId: userId, // Pass the current user ID
                    chefId: dish.chefId, // Pass the chef's ID
                    dishId: dish.dishId!, // Pass the dish ID
                    totalAmount: dish.dishPrice, // Pass the dish price
                  ),
                ),
              );
            } else {
              // Show error if user is not logged in
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please log in to book a chef.'),
                ),
              );
            }
          },
          child: Text(
            'Book Chef',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.redAccent, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 30 : 15, vertical: 10),
          ),
          onPressed: () {
            // Navigate to dish detail page or perform another action
          },
          child: Text(
            'View More Details',
            style: TextStyle(
              fontSize: 16,
              color: Colors.redAccent,
            ),
          ),
        ),
      ],
    );
  }
}
