// dishes_model.dart

class DishModel {
  String? dishId;
  String dishName;
  String dishDescription;
  double dishPrice;
  String? dishImageUrl;
  String subCategoryId;
  String categoryId; // Add categoryId here
  String chefId; // Add chefId here

  DishModel({
    required this.dishId,
    required this.dishName,
    required this.dishDescription,
    required this.dishPrice,
    required this.subCategoryId,
    required this.categoryId, // Initialize categoryId
    required this.chefId, // Initialize chefId
    this.dishImageUrl,
  });

  // Convert a Dish object into a Map
  Map<String, dynamic> toMap() {
    return {
      'dishId': dishId,
      'dishName': dishName,
      'dishDescription': dishDescription,
      'dishPrice': dishPrice,
      'subCategoryId': subCategoryId,
      'categoryId': categoryId, // Include categoryId in the map
      'chefId': chefId, // Include chefId in the map
      'dishImageUrl': dishImageUrl,
    };
  }

  // Create a Dish object from a Map
  factory DishModel.fromMap(Map<String, dynamic> map) {
    return DishModel(
      dishId: map['dishId'],
      dishName: map['dishName'],
      dishDescription: map['dishDescription'],
      dishPrice: map['dishPrice'],
      subCategoryId: map['subCategoryId'],
      categoryId: map['categoryId'], // Extract categoryId from the map
      chefId: map['chefId'], // Extract chefId from the map
      dishImageUrl: map['dishImageUrl'],
    );
  }
}
