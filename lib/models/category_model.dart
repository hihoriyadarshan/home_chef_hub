  class CategoryModel {
    final String cid;
    final String category;
    final String? categoryPhotoUrl;

    CategoryModel({
      required this.cid,
      required this.category,
      this.categoryPhotoUrl,

    });

    Map<String, dynamic> toMap() {
      return {
        'cid': cid,
        'category': category,
        'categoryPhotoUrl': categoryPhotoUrl,

      };
    }

    factory CategoryModel.fromMap(Map<String, dynamic> map) {
      return CategoryModel(
        cid: map['cid'],
        category: map['category'],
        categoryPhotoUrl: map['categoryPhotoUrl'],
      );
    }
  }
