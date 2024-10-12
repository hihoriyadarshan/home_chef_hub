import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/dishes_model.dart';

class MyDishesScreen extends StatefulWidget {
  @override
  _MyDishesScreenState createState() => _MyDishesScreenState();
}

class _MyDishesScreenState extends State<MyDishesScreen> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<DishModel> _myDishes = [];

  @override
  void initState() {
    super.initState();
    _fetchMyDishes();
  }

  Future<void> _fetchMyDishes() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _database.ref().child('dishes').orderByChild('chefId').equalTo(user.uid).once();
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        setState(() {
          _myDishes = data.values
              .map((value) => DishModel.fromMap(Map<String, dynamic>.from(value)))
              .toList();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Dishes'),
        backgroundColor: Colors.red,
      ),
      body: _myDishes.isEmpty
          ? Center(child: Text('No dishes created yet!'))
          : ListView.builder(
        itemCount: _myDishes.length,
        itemBuilder: (context, index) {
          final dish = _myDishes[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              leading: dish.dishImageUrl != null
                  ? Image.network(dish.dishImageUrl!, width: 50, height: 50, fit: BoxFit.cover)
                  : SizedBox(width: 50, height: 50), // Placeholder
              title: Text(dish.dishName),
              subtitle: Text('\$${dish.dishPrice.toString()}'),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  await _deleteDish(dish.dishId!);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteDish(String dishId) async {
    await _database.ref().child('dishes').child(dishId).remove();
    setState(() {
      _myDishes.removeWhere((dish) => dish.dishId == dishId);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dish deleted!')));
  }
}
