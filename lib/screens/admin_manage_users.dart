import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
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
          : ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: user.profilePhotoUrl != null
                  ? NetworkImage(user.profilePhotoUrl!)
                  : AssetImage('assets/default_profile.png') as ImageProvider,
            ),
            title: Text(user.username),
            subtitle: Text(user.email),
            onTap: () {
              // You can add more details or actions for each user here
            },
          );
        },
      ),
    );
  }
}
