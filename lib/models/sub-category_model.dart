class SubCategoryModel {
  final String scid;
  final String subCategory;
  final String categoryId; // Foreign Key
  final String? subCategoryPhotoUrl;

  SubCategoryModel({
    required this.scid,
    required this.subCategory,
    required this.categoryId,
    this.subCategoryPhotoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'scid': scid,
      'subCategory': subCategory,
      'categoryId': categoryId,
      'subCategoryPhotoUrl': subCategoryPhotoUrl,
    };
  }

  factory SubCategoryModel.fromMap(Map<String, dynamic> map) {
    return SubCategoryModel(
      scid: map['scid'],
      subCategory: map['subCategory'],
      categoryId: map['categoryId'],
      subCategoryPhotoUrl: map['subCategoryPhotoUrl'],
    );
  }
}
