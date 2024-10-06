import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import '../../models/Booking_model.dart';

class ChefBookingScreen extends StatefulWidget {
  final String userId; // The ID of the user booking the chef
  final String chefId; // The ID of the chef being booked
  final String dishId; // The ID of the dish being booked
  final double totalAmount; // Total amount for the dish

  ChefBookingScreen({
    required this.userId,
    required this.chefId,
    required this.dishId,
    required this.totalAmount,
  });

  @override
  _ChefBookingScreenState createState() => _ChefBookingScreenState();
}

class _ChefBookingScreenState extends State<ChefBookingScreen> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  bool isLoading = false;

  Future<void> _bookChef() async {
    setState(() {
      isLoading = true;
    });

    // Generate a unique booking ID
    String bookingId = Uuid().v4();

    // Create a booking model instance
    BookingModel booking = BookingModel(
      bookingId: bookingId,
      userId: widget.userId,
      chefId: widget.chefId,
      dishId: widget.dishId,
      bookingDate: DateTime.now(),
      status: 'pending',
      totalAmount: widget.totalAmount,
    );

    // Save the booking data to Firebase
    await _database.ref().child('bookings').child(bookingId).set(booking.toMap());

    setState(() {
      isLoading = false;
    });

    // Show a confirmation message
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Booking Confirmed'),
          content: Text('Your booking has been successfully made!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Go back to the previous screen
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Booking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dish: ${widget.dishId}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Total Amount: \$${widget.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            SizedBox(height: 20),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _bookChef,
              child: Text('Confirm Booking'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
