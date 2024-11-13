// chef_My_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/booking_model.dart';

class ChefMyBookingScreen extends StatefulWidget {
  final String chefId;

  ChefMyBookingScreen({required this.chefId});

  @override
  _ChefMyBookingScreenState createState() => _ChefMyBookingScreenState();
}

class _ChefMyBookingScreenState extends State<ChefMyBookingScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<BookingModel> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChefOrders();
  }

  Future<void> _fetchChefOrders() async {
    final bookingsRef = _database.child('bookings').orderByChild('chefId').equalTo(widget.chefId);
    final snapshot = await bookingsRef.get();

    if (snapshot.exists) {
      setState(() {
        orders = snapshot.children.map((e) => BookingModel.fromMap(e.value as Map<String, dynamic>)).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        orders = [];
        isLoading = false;
      });
    }
  }

  Future<void> _updateOrderStatus(String bookingId, String status) async {
    try {
      await _database.child('bookings/$bookingId').update({'status': status});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order $status successfully')));
      _fetchChefOrders(); // Refresh orders
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update order status')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookings'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? Center(child: Text('No bookings found'))
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text('Order ID: ${order.bookingId}'),
              subtitle: Text('Total Amount: \$${order.totalAmount}\nStatus: ${order.status}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (order.status == 'pending') ...[
                    IconButton(
                      icon: Icon(Icons.check, color: Colors.green),
                      onPressed: () => _updateOrderStatus(order.bookingId, 'confirmed'),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () => _updateOrderStatus(order.bookingId, 'rejected'),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
