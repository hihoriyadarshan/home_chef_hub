class BookingModel {
  final String bookingId;
  final String userId; // Foreign Key to User
  final String chefId; // Foreign Key to Chef (User with role 'chef')
  final String dishId; // Foreign Key to Dish
  final DateTime bookingDate;
  final String status; // E.g., 'pending', 'confirmed', 'completed', 'canceled'
  final double totalAmount;

  BookingModel({
    required this.bookingId,
    required this.userId,
    required this.chefId,
    required this.dishId,
    required this.bookingDate,
    required this.status,
    required this.totalAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'chefId': chefId,
      'dishId': dishId,
      'bookingDate': bookingDate.toIso8601String(),
      'status': status,
      'totalAmount': totalAmount,
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      bookingId: map['bookingId'],
      userId: map['userId'],
      chefId: map['chefId'],
      dishId: map['dishId'],
      bookingDate: DateTime.parse(map['bookingDate']),
      status: map['status'],
      totalAmount: map['totalAmount'],
    );
  }
}
