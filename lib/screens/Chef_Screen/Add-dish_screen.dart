import 'package:flutter/material.dart';

class AddDishScreen extends StatefulWidget {
  @override
  _AddDishScreenState createState() => _AddDishScreenState();
}

class _AddDishScreenState extends State<AddDishScreen> {
  final _formKey = GlobalKey<FormState>();
  String? dishName;
  String? description;
  double? price;
  String? categoryId;
  String? subCategoryId;
  String? preparationTime;
  List<String> ingredients = [];
  String? dishPhotoUrl;

  // Controllers for the TextFormFields
  TextEditingController dishNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController preparationTimeController = TextEditingController();
  TextEditingController ingredientsController = TextEditingController();

  // Mock category and subcategory data (replace with real data)
  List<Map<String, String>> categories = [
    {'id': '1', 'name': 'Main Course'},
    {'id': '2', 'name': 'Desserts'},
  ];

  List<Map<String, String>> subCategories = [
    {'id': '1', 'name': 'Vegetarian', 'categoryId': '1'},
    {'id': '2', 'name': 'Non-Vegetarian', 'categoryId': '1'},
    {'id': '3', 'name': 'Cakes', 'categoryId': '2'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Dish'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: dishNameController,
                decoration: InputDecoration(labelText: 'Dish Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the dish name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the dish description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the dish price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField(
                decoration: InputDecoration(labelText: 'Category'),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category['id'],
                    child: Text(category['name']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    categoryId = value as String;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField(
                decoration: InputDecoration(labelText: 'Subcategory'),
                items: subCategories
                    .where((sub) => sub['categoryId'] == categoryId)
                    .map((subCategory) {
                  return DropdownMenuItem(
                    value: subCategory['id'],
                    child: Text(subCategory['name']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    subCategoryId = value as String;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a subcategory';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: preparationTimeController,
                decoration: InputDecoration(labelText: 'Preparation Time (e.g., 30 mins)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the preparation time';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: ingredientsController,
                decoration: InputDecoration(labelText: 'Ingredients (comma-separated)'),
                onFieldSubmitted: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      ingredients = value.split(',').map((e) => e.trim()).toList();
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Process the data
                    print("Dish Name: $dishName");
                    print("Ingredients: ${ingredients.join(', ')}");
                    // TODO: Add the logic to save the dish to the database
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Dish Added Successfully')),
                    );
                  }
                },
                child: Text('Add Dish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
