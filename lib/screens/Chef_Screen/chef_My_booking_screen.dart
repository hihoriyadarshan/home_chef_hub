import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/booking_model.dart';

class MyBookingsPage extends StatefulWidget {
  final String chefId;

  MyBookingsPage({required this.chefId});

  @override
  _MyBookingsPageState createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  final _database = FirebaseDatabase.instance.ref();
  List<BookingModel> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChefOrders();
  }

  Future<void> _fetchChefOrders() async {
    try {
      final bookingsRef = _database.child('bookings').orderByChild('chefId').equalTo(widget.chefId);
      final snapshot = await bookingsRef.get();

      if (snapshot.exists) {
        setState(() {
          orders = snapshot.children
              .map((e) => BookingModel.fromMap(Map<String, dynamic>.from(e.value as Map)))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          orders = [];
          isLoading = false;
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching bookings: $error')));
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await _database.child('bookings/$bookingId').update({'status': newStatus});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking status updated to $newStatus')));
      _fetchChefOrders(); // Refresh the list after updating
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating status: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Bookings"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? Center(child: Text("No bookings found"))
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final booking = orders[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text('User ID: ${booking.userId}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dish ID: ${booking.dishId}'),
                  Text('Date: ${booking.bookingDate.toLocal().toString().split(' ')[0]}'),
                  Text('Total Amount: \$${booking.totalAmount.toStringAsFixed(2)}'),
                  Text('Status: ${booking.status}'),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (String newStatus) {
                  _updateBookingStatus(booking.bookingId, newStatus);
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: 'pending',
                    child: Text('Pending'),
                  ),
                  PopupMenuItem(
                    value: 'confirmed',
                    child: Text('Confirmed'),
                  ),
                  PopupMenuItem(
                    value: 'completed',
                    child: Text('Completed'),
                  ),
                  PopupMenuItem(
                    value: 'canceled',
                    child: Text('Canceled'),
                  ),
                ],
                child: Icon(Icons.more_vert),
              ),
            ),
          );
        },
      ),
    );
  }
}
