import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_model.dart';

class AdminManageUsers extends StatefulWidget {
  @override
  _AdminManageUsersState createState() => _AdminManageUsersState();
}

class _AdminManageUsersState extends State<AdminManageUsers> {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref().child('users');
  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      _usersRef.once().then((snapshot) {
        List<UserModel> fetchedUsers = [];
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          final user = UserModel.fromMap(Map<String, dynamic>.from(value));
          if (user.role == "User") {  // Filter by role
            fetchedUsers.add(user);
          }
        });

        setState(() {
          _users = fetchedUsers;
          _isLoading = false;
        });
      });
    } catch (e) {
      print('Error fetching users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to open email app
  Future<void> _launchEmail(String email) async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: email,
    );
    String url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Users'),
        backgroundColor: Colors.redAccent,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _users.isEmpty
          ? Center(child: Text('No users found with role "User".'))
          : Padding(
        padding: const EdgeInsets.all(16.0),  // Add padding around the table
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 20),  // Add space above the table
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Profile')),
                    DataColumn(label: Text('Username')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Phone')),
                    DataColumn(label: Text('Address')),
                    DataColumn(label: Text('Enable/Disable')), // Add buttons header
                  ],
                  rows: _users.map((user) {
                    return DataRow(
                      cells: [
                        DataCell(
                          CircleAvatar(
                            backgroundImage: user.profilePhotoUrl != null
                                ? NetworkImage(user.profilePhotoUrl!)
                                : AssetImage('default_profile.png') as ImageProvider,
                          ),
                        ),
                        DataCell(Text(user.username)),
                        DataCell(
                          GestureDetector(
                            onTap: () {
                              _launchEmail(user.email);
                            },
                            child: Text(
                              user.email,
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text(user.phone)),
                        DataCell(Text(user.address)),
                        DataCell(
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // Add functionality to enable the user
                                  print('Enabled ${user.username}');
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white, backgroundColor: Colors.green, // Text color
                                ),
                                child: Text('Enable'),
                              ),
                              SizedBox(width: 8),  // Add space between buttons
                              ElevatedButton(
                                onPressed: () {
                                  // Add functionality to disable the user
                                  print('Disabled ${user.username}');
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white, backgroundColor: Colors.red, // Text color
                                ),
                                child: Text('Disable'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
