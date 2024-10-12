import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:home_chef_hub/models/booking_model.dart';

class AdminBookingDetailsScreen extends StatefulWidget {
  @override
  _AdminBookingDetailsScreenState createState() =>
      _AdminBookingDetailsScreenState();
}

class _AdminBookingDetailsScreenState
    extends State<AdminBookingDetailsScreen> {
  final DatabaseReference _bookingRef =
  FirebaseDatabase.instance.ref().child('bookings'); // Use ref() to access the database
  List<BookingModel> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      DatabaseEvent event = await _bookingRef.once(); // Use once() to get the data
      final snapshot = event.snapshot;

      if (snapshot.exists) {
        final bookingsMap = snapshot.value as Map<Object?, Object?>;

        // Convert LinkedMap<Object?, Object?> to List<BookingModel>
        List<BookingModel> bookings = [];
        bookingsMap.forEach((key, value) {
          // Ensure we convert the value to a Map<String, dynamic>
          if (value is Map<Object?, Object?>) {
            bookings.add(BookingModel.fromMap(value.cast<String, dynamic>()));
          }
        });

        setState(() {
          _bookings = bookings;
          _isLoading = false;
        });
      } else {
        // If no data exists
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print("Error fetching bookings: $error");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Booking Details'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
          ? Center(child: Text('No bookings available')) // Display message when no bookings are found
          : ListView.builder(
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text('Booking ID: ${booking.bookingId}'),
              subtitle: Text(
                'User ID: ${booking.userId}\n'
                    'Chef ID: ${booking.chefId}\n'
                    'Dish ID: ${booking.dishId}\n'
                    'Date: ${booking.bookingDate}\n'
                    'Status: ${booking.status}\n'
                    'Total Amount: \$${booking.totalAmount.toStringAsFixed(2)}',
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
