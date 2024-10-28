import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/booking_model.dart';
import '../../models/dishes_model.dart';
import '../../models/user_model.dart';

class MyBookingScreen extends StatefulWidget {
  final String userId;

  MyBookingScreen({required this.userId});

  @override
  _MyBookingScreenState createState() => _MyBookingScreenState();
}

class _MyBookingScreenState extends State<MyBookingScreen> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  List<BookingModel> currentBookings = [];
  List<Map<String, dynamic>> bookingDetails = []; // List to store bookings with chef and dish info
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final snapshot = await _databaseRef.child('bookings').orderByChild('userId').equalTo(widget.userId).get();

      if (snapshot.exists) {
        List<Map<String, dynamic>> details = [];

        for (var bookingSnapshot in snapshot.children) {
          final bookingData = Map<String, dynamic>.from(bookingSnapshot.value as Map);
          BookingModel booking = BookingModel.fromMap(bookingData);

          // Fetch Dish and Chef info
          var dishSnapshot = await _databaseRef.child('dishes').child(booking.dishId).get();
          var chefSnapshot = await _databaseRef.child('users').child(booking.chefId).get();

          if (dishSnapshot.exists && chefSnapshot.exists) {
            DishModel dish = DishModel.fromMap(Map<String, dynamic>.from(dishSnapshot.value as Map));
            UserModel chef = UserModel.fromMap(Map<String, dynamic>.from(chefSnapshot.value as Map));

            details.add({
              'booking': booking,
              'dish': dish,
              'chef': chef,
            });
          }
        }

        setState(() {
          bookingDetails = details;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        print("No bookings found for this user.");
      }
    } catch (e) {
      print("Error loading bookings: $e");
      setState(() => isLoading = false);
    }
  }

  Widget _buildBookingTile(Map<String, dynamic> bookingDetail) {
    BookingModel booking = bookingDetail['booking'];
    DishModel dish = bookingDetail['dish'];
    UserModel chef = bookingDetail['chef'];

    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 25),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Booking ID: ${booking.bookingId}', style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold)),
            Text('Chef: ${chef.username}'),
            chef.profilePhotoUrl != null
                ? Image.network(chef.profilePhotoUrl!, height: 50, width: 50)
                : Icon(Icons.person, size: 50),
            Text('Dish: ${dish.dishName}'),
            dish.dishImageUrl != null
                ? Image.network(dish.dishImageUrl!, height: 100, width: 100)
                : Icon(Icons.image, size: 100),
            Text('Date: ${booking.bookingDate.toLocal()}'),
            Text('Total Amount: \$${booking.totalAmount.toStringAsFixed(2)}', style: TextStyle(color: Colors.red)),
            Text('Status: ${booking.status}', style: TextStyle(color: booking.status == 'canceled' ? Colors.grey : Colors.green)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookings'),
        backgroundColor: Colors.red,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (bookingDetails.isNotEmpty)
              ...bookingDetails.map((bookingDetail) => _buildBookingTile(bookingDetail)).toList(),
            if (bookingDetails.isEmpty)
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No bookings found', style: TextStyle(fontSize: 18)),
              ),
          ],
        ),
      ),
    );
  }
}
