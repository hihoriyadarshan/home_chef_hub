import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:home_chef_hub/models/dishes_model.dart';
import 'package:home_chef_hub/models/user_model.dart';

class AdminShowAllDishes extends StatefulWidget {
  @override
  _AdminShowAllDishesState createState() => _AdminShowAllDishesState();
}

class _AdminShowAllDishesState extends State<AdminShowAllDishes> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  List<DishModel> _dishes = [];
  List<DishModel> _filteredDishes = []; // List for filtered dishes
  Map<String, UserModel> _chefDetails = {};
  String _searchQuery = '';
  int _itemsPerPage = 10; // Number of items to load per page
  bool _isLoadingMore = false;
  bool _hasMoreItems = true; // To check if there are more items to load

  @override
  void initState() {
    super.initState();
    _fetchPaginatedDishes();
  }

  // Fetch paginated dishes from Firebase
  Future<void> _fetchPaginatedDishes() async {
    if (!_hasMoreItems || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    final snapshot = await _database
        .ref()
        .child('dishes')
        .orderByKey()
        .limitToFirst(_dishes.length + _itemsPerPage)
        .once();

    final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      final List<DishModel> newDishes = data.values
          .map((dishData) => DishModel.fromMap(Map<String, dynamic>.from(dishData)))
          .toList();

      // Fetch chef details for new dishes
      await _fetchChefDetails(newDishes);

      setState(() {
        _dishes = newDishes;
        _filteredDishes = _applySearchFilter(); // Apply search filter on new dishes

        _isLoadingMore = false;
        _hasMoreItems = newDishes.length == _dishes.length + _itemsPerPage;
      });
    }
  }

  // Fetch chef details for the given dishes
  Future<void> _fetchChefDetails(List<DishModel> dishes) async {
    for (var dish in dishes) {
      if (!_chefDetails.containsKey(dish.chefId)) {
        final snapshot = await _database.ref().child('users').child(dish.chefId).once();
        final userData = snapshot.snapshot.value as Map<dynamic, dynamic>?;

        if (userData != null) {
          _chefDetails[dish.chefId] = UserModel.fromMap(Map<String, dynamic>.from(userData));
        }
      }
    }
  }

  // Search filter method
  List<DishModel> _applySearchFilter() {
    if (_searchQuery.isEmpty) {
      return _dishes;
    } else {
      return _dishes
          .where((dish) => dish.dishName.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  // Search input handler
  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
      _filteredDishes = _applySearchFilter();
    });
  }

  // Function to display a detailed card with dish and chef details
  void _showDishDetails(DishModel dish) {
    final chef = _chefDetails[dish.chefId];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(dish.dishName),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (dish.dishImageUrl != null)
                  Image.network(dish.dishImageUrl!, height: 150, fit: BoxFit.cover),
                SizedBox(height: 10),
                Text('Description: ${dish.dishDescription}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Text('Price: \$${dish.dishPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                if (chef != null) ...[
                  Text('Chef: ${chef.username}', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Chef Email: ${chef.email}'),
                  Text('Chef Phone: ${chef.phone}'),
                  Text('Chef Address: ${chef.address}'),

                  // Add any additional chef details here
                ] else
                  Text('Loading chef details...', style: TextStyle(fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateDishDialog(DishModel dish) {
    final TextEditingController nameController = TextEditingController(text: dish.dishName);
    final TextEditingController descriptionController = TextEditingController(text: dish.dishDescription);
    final TextEditingController priceController = TextEditingController(text: dish.dishPrice.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Dish'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Dish Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Dish Description'),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Dish Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final updatedDish = dish.copyWith(
                  dishName: nameController.text,
                  dishDescription: descriptionController.text,
                  dishPrice: double.tryParse(priceController.text) ?? dish.dishPrice,

                );
                await _updateDish(updatedDish);
                Navigator.pop(context);
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateDish(DishModel dish) async {
    await _database.ref().child('dishes').child(dish.dishId!).set(dish.toMap());
    setState(() {
      final index = _dishes.indexWhere((d) => d.dishId == dish.dishId);
      _dishes[index] = dish;
      _filteredDishes = _applySearchFilter();
    });
  }

  Future<void> _deleteDish(DishModel dish) async {
    await _database.ref().child('dishes').child(dish.dishId!).remove();
    setState(() {
      _dishes.removeWhere((d) => d.dishId == dish.dishId);
      _filteredDishes = _applySearchFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context); // Navigates back to the previous screen
            },
          ),
        title: Text(
          'All Dishes',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFFD32F2F),

      ),


      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by Dish Name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: _handleSearch,
            ),
          ),
          Expanded(
            child: _filteredDishes.isEmpty
                ? Center(child: CircularProgressIndicator())
                : NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent && !_isLoadingMore) {
                  _fetchPaginatedDishes();
                  return true;
                }
                return false;
              },
              child: ListView.builder(
                itemCount: _filteredDishes.length,
                itemBuilder: (context, index) {
                  final dish = _filteredDishes[index];
                  final chef = _chefDetails[dish.chefId];
                  return ListTile(
                    title: Text(dish.dishName),
                    subtitle: chef != null ? Text('Chef: ${chef.username}') : Text('Loading...'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.visibility), // Eye button to view details
                          onPressed: () => _showDishDetails(dish),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _showUpdateDishDialog(dish),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteDish(dish),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          if (_isLoadingMore) CircularProgressIndicator(),
        ],
      ),
    );
  }
}
