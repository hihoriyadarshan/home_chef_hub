// Importing required files
import 'package:home_chef_hub/models/booking_model.dart'; // Import the BookingModel class
import 'package:home_chef_hub/services/database_service.dart'; // Import the DatabaseService class

class UserComplaint {
  final String complaintId;
  final String userId;
  final String description;
  final DateTime createdAt;
  String? status;

  UserComplaint({
    required this.complaintId,
    required this.userId,
    required this.description,
    required this.createdAt,
    this.status = 'pending', // Default status to pending
  });

  // Convert the object to a map to save in the database
  Map<String, dynamic> toMap() {
    return {
      'complaintId': complaintId,
      'userId': userId,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  // Create the UserComplaint object from a map (useful when fetching data)
  factory UserComplaint.fromMap(Map<String, dynamic> map) {
    return UserComplaint(
      complaintId: map['complaintId'] as String,
      userId: map['userId'] as String,
      description: map['description'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      status: map['status'] as String?,
    );
  }

  // Fetch bookings by userId (additional method)
  static Future<List<BookingModel>> getUserBookings(DatabaseService databaseService, String userId) async {
    // Fetch bookings from the DatabaseService
    final bookings = await databaseService.getBookingsByUserId(userId);
    List<BookingModel> userBookings = [];
    for (var bookingSnapshot in bookings.children) {
      final bookingMap = bookingSnapshot.value as Map<String, dynamic>;
      userBookings.add(BookingModel.fromMap(bookingMap));
    }
    return userBookings;
  }
}
