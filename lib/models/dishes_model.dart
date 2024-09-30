class DishModel {
  final String dishId;
  final String chefId; // Foreign Key (Chef is also a User with role 'chef')
  final String dishName;
  final String description;
  final String subCategoryId; // Foreign Key to SubCategory
  final double price;
  final String? dishPhotoUrl;

  DishModel({
    required this.dishId,
    required this.chefId,
    required this.dishName,
    required this.description,
    required this.subCategoryId,
    required this.price,
    this.dishPhotoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'dishId': dishId,
      'chefId': chefId,
      'dishName': dishName,
      'description': description,
      'subCategoryId': subCategoryId,
      'price': price,
      'dishPhotoUrl': dishPhotoUrl,
    };
  }

  factory DishModel.fromMap(Map<String, dynamic> map) {
    return DishModel(
      dishId: map['dishId'],
      chefId: map['chefId'],
      dishName: map['dishName'],
      description: map['description'],
      subCategoryId: map['subCategoryId'],
      price: map['price'],
      dishPhotoUrl: map['dishPhotoUrl'],
    );
  }
}
