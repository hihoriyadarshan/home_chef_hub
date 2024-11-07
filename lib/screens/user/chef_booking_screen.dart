import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import '../../models/booking_model.dart';

class ChefBookingScreen extends StatefulWidget {
  final String userId; // User booking the chef
  final String chefId; // Chef being booked
  final String dishId; // Dish being booked
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
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final Uuid _uuid = Uuid();
  bool isLoading = false;
  double? userBalance;

  @override
  void initState() {
    super.initState();
    _fetchUserBalance();
  }

  Future<void> _fetchUserBalance() async {
    final userRef = _database.child('users/${widget.userId}/balance');
    final snapshot = await userRef.get();

    setState(() {
      userBalance = snapshot.exists ? double.parse(snapshot.value.toString()) : 0.0;
    });
  }

  Future<void> _bookChef() async {
    if (userBalance == null || userBalance! < widget.totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Insufficient balance. Please add funds.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    String bookingId = _uuid.v4();
    BookingModel booking = BookingModel(
      bookingId: bookingId,
      userId: widget.userId,
      chefId: widget.chefId,
      dishId: widget.dishId,
      bookingDate: DateTime.now(),
      status: 'pending',
      totalAmount: widget.totalAmount,
    );

    try {
      final newBalance = userBalance! - widget.totalAmount;
      await _database.child('users/${widget.userId}/balance').set(newBalance);
      await _database.child('bookings').child(bookingId).set(booking.toMap());

      setState(() {
        userBalance = newBalance;
        isLoading = false;
      });

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Booking Confirmed'),
            content: Text('Your booking has been successfully made!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking failed. Please try again.")),
      );
    }
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
            userBalance == null
                ? Center(child: CircularProgressIndicator())
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Balance: \$${userBalance!.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: userBalance! >= widget.totalAmount ? _bookChef : null,
                  child: Text('Confirm Booking'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
