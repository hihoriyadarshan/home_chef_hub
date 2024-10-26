import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:home_chef_hub/models/user_complaint_model.dart';
import 'package:home_chef_hub/services/database_service.dart';

class AdminComplaintsScreen extends StatefulWidget {
  @override
  _AdminComplaintsScreenState createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<UserComplaint> _complaints = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchComplaints();
  }

  // Fetch all complaints from the database
  Future<void> _fetchComplaints() async {
    try {
      final snapshot = await FirebaseDatabase.instance.ref('complaints').once();
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          _complaints = data.values
              .map((value) => UserComplaint.fromMap(Map<String, dynamic>.from(value)))
              .toList();
        });
      }
    } catch (error) {
      print("Error fetching complaints: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Update complaint status
  Future<void> _updateComplaintStatus(UserComplaint complaint, String status) async {
    try {
      setState(() {
        complaint.status = status;
      });
      await _databaseService.updateComplaintStatus(complaint.complaintId, status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Complaint status updated to $status')),
      );
    } catch (error) {
      print("Error updating status: $error");
    }
  }

  // Determine color based on status
  Color _getStatusColor(String? status) {
    switch (status) {
      case 'resolved':
        return Colors.green;
      case 'in_progress':
        return Colors.yellow;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Complaints'),
        backgroundColor: Colors.red,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _complaints.isEmpty
          ? Center(child: Text('No complaints available'))
          : ListView.builder(
        itemCount: _complaints.length,
        itemBuilder: (context, index) {
          final complaint = _complaints[index];
          return Card(
            margin: EdgeInsets.all(10),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              title: Text('Complaint ID: ${complaint.complaintId}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User ID: ${complaint.userId}'),
                  Text('Description: ${complaint.description}'),
                  Text('Status: ${complaint.status ?? "pending"}'),
                  Text('Created at: ${complaint.createdAt.toLocal().toString()}'),
                ],
              ),
              trailing: DropdownButton<String>(
                value: complaint.status ?? 'pending',
                icon: Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: _getStatusColor(complaint.status)),
                underline: Container(
                  height: 2,
                  color: _getStatusColor(complaint.status),
                ),
                onChanged: (String? newStatus) {
                  if (newStatus != null) {
                    _updateComplaintStatus(complaint, newStatus);
                  }
                },
                items: <String>['pending', 'in_progress', 'resolved']
                    .map<DropdownMenuItem<String>>((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(
                      status == 'pending'
                          ? 'Pending'
                          : status == 'in_progress'
                          ? 'In Progress'
                          : 'Resolved',
                      style: TextStyle(
                        color: _getStatusColor(status),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
