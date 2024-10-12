class DishModel {
  String? dishId;
  String dishName;
  String dishDescription;
  double dishPrice;
  String? dishImageUrl;
  String subCategoryId;
  String categoryId;
  String chefId;// Foreign Key to Chef (User with role 'chef')

  DishModel({
    required this.dishId,
    required this.dishName,
    required this.dishDescription,
    required this.dishPrice,
    required this.subCategoryId,
    required this.categoryId,
    required this.chefId,
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
      'categoryId': categoryId,
      'chefId': chefId,
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
      categoryId: map['categoryId'],
      chefId: map['chefId'],
      dishImageUrl: map['dishImageUrl'],
    );
  }

  // Add a copyWith method to allow partial updates of the DishModel object
  DishModel copyWith({
    String? dishId,
    String? dishName,
    String? dishDescription,
    double? dishPrice,
    String? dishImageUrl,
    String? subCategoryId,
    String? categoryId,
    String? chefId,
  }) {
    return DishModel(
      dishId: dishId ?? this.dishId,
      dishName: dishName ?? this.dishName,
      dishDescription: dishDescription ?? this.dishDescription,
      dishPrice: dishPrice ?? this.dishPrice,
      dishImageUrl: dishImageUrl ?? this.dishImageUrl,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      categoryId: categoryId ?? this.categoryId,
      chefId: chefId ?? this.chefId,
    );
  }
}
