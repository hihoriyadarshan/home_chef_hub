import 'package:firebase_database/firebase_database.dart';
import 'package:home_chef_hub/models/booking_model.dart';
import 'package:home_chef_hub/models/user_complaint_model.dart';

class DatabaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Method to generate a unique complaint ID
  String generateComplaintId() {
    DatabaseReference complaintsRef = _database.ref().child('complaints');
    String newComplaintId = complaintsRef.push().key ?? '';
    return newComplaintId;
  }

  // Method to save the user complaint to Firebase
  Future<void> saveUserComplaint(UserComplaint complaint) async {
    DatabaseReference complaintsRef = _database.ref().child('complaints/${complaint.complaintId}');
    await complaintsRef.set(complaint.toMap());
  }

  // Fetch bookings by userId
  Future<DataSnapshot> getBookingsByUserId(String userId) async {
    return await _database.ref().child('bookings').orderByChild('userId').equalTo(userId).get();
  }

  // Fetch a specific booking by bookingId (if needed)
  Future<DataSnapshot> getBookingById(String bookingId) async {
    return await _database.ref().child('bookings/$bookingId').get();
  }

  // Method to update booking status if necessary
  Future<void> updateBookingStatus(String bookingId, String status) async {
    DatabaseReference bookingRef = _database.ref().child('bookings/$bookingId');
    await bookingRef.update({'status': status});
  }

  // Method to update complaint status if necessary
  Future<void> updateComplaintStatus(String complaintId, String status) async {
    DatabaseReference complaintRef = _database.ref().child('complaints/$complaintId');
    await complaintRef.update({'status': status});
  }
}
