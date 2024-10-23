import 'package:flutter/material.dart';
import 'package:home_chef_hub/models/user_complaint_model.dart';
import 'package:home_chef_hub/services/database_service.dart';

class AdminUsersIssue extends StatefulWidget {
  final List<UserComplaint> complaints; // Pass the complaints to this widget

  AdminUsersIssue({Key? key, required this.complaints}) : super(key: key);

  @override
  _AdminUsersIssueState createState() => _AdminUsersIssueState();
}

class _AdminUsersIssueState extends State<AdminUsersIssue> {
  // Define the dropdown options
  final List<String> _statusOptions = ['pending', 'resolved', 'rejected'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Users Issue'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: widget.complaints.length,
          itemBuilder: (context, index) {
            UserComplaint complaint = widget.complaints[index];

            return Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Complaint ID: ${complaint.complaintId}'),
                    SizedBox(height: 8),
                    Text('User ID: ${complaint.userId}'),
                    SizedBox(height: 8),
                    Text('Description: ${complaint.description}'),
                    SizedBox(height: 8),
                    Text('Created At: ${complaint.createdAt}'),
                    SizedBox(height: 8),
                    DropdownButton<String>(
                      value: complaint.status,
                      icon: Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(color: Colors.black),
                      underline: Container(
                        height: 2,
                        color: Colors.red,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          complaint.status = newValue!; // Update the complaint status
                        });
                        // Here you could also update the status in the database
                        // databaseService.updateComplaintStatus(complaint.complaintId, newValue);
                      },
                      items: _statusOptions.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
