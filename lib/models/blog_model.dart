class BlogModel {
  final String userId;
  final String blogTitle;
  final String blogContent;
  final String? blogImageUrl;
  final DateTime timestamp;

  BlogModel({
    required this.userId,
    required this.blogTitle,
    required this.blogContent,
    this.blogImageUrl,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'blogTitle': blogTitle,
      'blogContent': blogContent,
      'blogImageUrl': blogImageUrl,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory BlogModel.fromMap(Map<String, dynamic> map) {
    return BlogModel(
      userId: map['userId'] as String,
      blogTitle: map['blogTitle'] as String,
      blogContent: map['blogContent'] as String,
      blogImageUrl: map['blogImageUrl'] as String?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }
}
