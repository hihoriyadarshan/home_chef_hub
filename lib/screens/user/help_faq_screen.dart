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
  List<UserComplaint> _userComplaints = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserBookings();
    _loadUserComplaints();
  }

  // Fetch user complaints
  Future<void> _loadUserComplaints() async {
    try {
      final complaints = await _databaseService.getUserComplaints(widget.userId);
      setState(() {
        _userComplaints = complaints;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error loading complaints: $e'),
      ));
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserBookings() async {
    try {
      final bookings = await UserComplaint.getUserBookings(_databaseService, widget.userId);
      setState(() {
        _userBookings = bookings;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error loading bookings: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & FAQ'),
        backgroundColor: Color(0xFFD32F2F),
      ),
      body: Column(
        children: [
          SizedBox(height: 80),
          SizedBox(
            width: 500,
            height: 50,
            child: TextField(
              controller: _complaintController,
              decoration: InputDecoration(labelText: 'Describe your issue'),
            ),
          ),
          SizedBox(height: 40),
          ElevatedButton(
            onPressed: _submitComplaint,
            child: Text('Submit Complaint', style: TextStyle(fontSize: 18, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: Size(300, 50),
            ),
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
            child: ListView.builder(
              itemCount: _userComplaints.length,
              itemBuilder: (context, index) {
                final complaint = _userComplaints[index];
                return ListTile(
                  title: Text('Complaint ID: ${complaint.complaintId}'),
                  subtitle: Text(
                    'Status: ${complaint.status ?? "Pending"}\nDescription: ${complaint.description}',
                  ),
                  trailing: Text(
                    'Submitted on: ${complaint.createdAt.toLocal()}',
                    style: TextStyle(fontSize: 12),
                  ),
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
      createdAt: DateTime.now(),
    );

    try {
      await _databaseService.saveUserComplaint(userComplaint);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Complaint submitted successfully'),
      ));
      _complaintController.clear();
      _loadUserComplaints(); // Refresh complaints list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error submitting complaint: $e'),
      ));
    }
  }
}
