import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:home_chef_hub/models/booking_model.dart';
import 'package:home_chef_hub/models/user_model.dart'; // Import UserModel
import 'package:home_chef_hub/models/dishes_model.dart'; // Import DishModel

class AdminBookingDetailsScreen extends StatefulWidget {
  @override
  _AdminBookingDetailsScreenState createState() =>
      _AdminBookingDetailsScreenState();
}

class _AdminBookingDetailsScreenState extends State<AdminBookingDetailsScreen> {
  final DatabaseReference _bookingRef =
  FirebaseDatabase.instance.ref().child('bookings');
  final DatabaseReference _userRef =
  FirebaseDatabase.instance.ref().child('users'); // User Reference
  final DatabaseReference _dishRef =
  FirebaseDatabase.instance.ref().child('dishes'); // Dish Reference

  List<BookingModel> _bookings = [];
  Map<String, UserModel> _userDetails = {}; // Store User Details
  Map<String, DishModel> _dishDetails = {}; // Store Dish Details
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      DatabaseEvent event = await _bookingRef.once();
      final snapshot = event.snapshot;

      if (snapshot.exists) {
        final bookingsMap = snapshot.value as Map<Object?, Object?>;
        List<BookingModel> bookings = [];

        for (var entry in bookingsMap.entries) {
          final value = entry.value;
          if (value is Map<Object?, Object?>) {
            BookingModel booking = BookingModel.fromMap(value.cast<String, dynamic>());
            bookings.add(booking);

            // Fetch User and Chef details in parallel
            _fetchUserDetails(booking.userId);
            _fetchUserDetails(booking.chefId, isChef: true);

            // Fetch Dish details
            _fetchDishDetails(booking.dishId);
          }
        }

        setState(() {
          _bookings = bookings;
          _isLoading = false;
        });
      } else {
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

  // Fetch User or Chef Details
  Future<void> _fetchUserDetails(String userId, {bool isChef = false}) async {
    try {
      DatabaseEvent event = await _userRef.child(userId).once();
      final snapshot = event.snapshot;

      if (snapshot.exists) {
        final userMap = snapshot.value as Map<Object?, Object?>;
        UserModel user = UserModel.fromMap(userMap.cast<String, dynamic>());

        setState(() {
          _userDetails[userId] = user; // Store the user/chef details
        });
      }
    } catch (error) {
      print("Error fetching user/chef details: $error");
    }
  }

  // Fetch Dish Details
  Future<void> _fetchDishDetails(String dishId) async {
    try {
      DatabaseEvent event = await _dishRef.child(dishId).once();
      final snapshot = event.snapshot;

      if (snapshot.exists) {
        final dishMap = snapshot.value as Map<Object?, Object?>;
        DishModel dish = DishModel.fromMap(dishMap.cast<String, dynamic>());

        setState(() {
          _dishDetails[dishId] = dish; // Store the dish details
        });
      }
    } catch (error) {
      print("Error fetching dish details: $error");
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
          ? Center(child: Text('No bookings available'))
          : ListView.builder(
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          final user = _userDetails[booking.userId];
          final chef = _userDetails[booking.chefId];
          final dish = _dishDetails[booking.dishId];

          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text('Booking ID: ${booking.bookingId}'),
              subtitle: Text(
                'User: ${user?.username ?? 'Loading...'}\n'
                    'User Phone: ${user?.phone ?? 'Loading...'}\n'
                    'Chef: ${chef?.username ?? 'Loading...'}\n'
                    'Chef Phone: ${chef?.phone ?? 'Loading...'}\n'
                    'Dish: ${dish?.dishName ?? 'Loading...'}\n'
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
