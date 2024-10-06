import 'package:flutter/material.dart';
import 'package:home_chef_hub/services/database_service.dart';
import 'package:home_chef_hub/models/user_complaint_model.dart';
import 'package:home_chef_hub/models/booking_model.dart';

class HelpFaqScreen extends StatefulWidget {
  final String userId;

  const HelpFaqScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _HelpFaqScreenState createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _complaintController = TextEditingController();
  List<BookingModel> _userBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserBookings();
  }

  Future<void> _loadUserBookings() async {
    try {
      // Fetch bookings for the user
      final bookings = await UserComplaint.getUserBookings(_databaseService, widget.userId);
      setState(() {
        _userBookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error loading bookings: $e'),
      ));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & FAQ'),
      ),
      body: Column(
        children: [
          // Input field for user's complaint
          TextField(
            controller: _complaintController,
            decoration: InputDecoration(
              labelText: 'Describe your issue',
            ),
          ),
          ElevatedButton(
            onPressed: _submitComplaint,
            child: Text('Submit Complaint'),
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
            child: ListView.builder(
              itemCount: _userBookings.length,
              itemBuilder: (context, index) {
                final booking = _userBookings[index];
                return ListTile(
                  title: Text('Booking ID: ${booking.bookingId}'),
                  subtitle: Text('Dish ID: ${booking.dishId}\nStatus: ${booking.status}\nTotal: \$${booking.totalAmount}'),
                  trailing: Text(booking.bookingDate.toIso8601String()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitComplaint() async {
    if (_complaintController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a complaint description'),
      ));
      return;
    }

    final complaintId = _databaseService.generateComplaintId();

    final userComplaint = UserComplaint(
      complaintId: complaintId,
      userId: widget.userId,
      description: _complaintController.text,
      createdAt: DateTime.now(), // Timestamp
    );

    try {
      await _databaseService.saveUserComplaint(userComplaint);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Complaint submitted successfully'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error submitting complaint: $e'),
      ));
    }
  }
}
