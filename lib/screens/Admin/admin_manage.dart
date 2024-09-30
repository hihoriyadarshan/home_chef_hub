import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AdminManage extends StatefulWidget {
  @override
  _AdminManageState createState() => _AdminManageState();
}

class _AdminManageState extends State<AdminManage> {
  final DatabaseReference _userRef = FirebaseDatabase.instance.ref().child('users');

  // Function to fetch all users from Firebase Database
  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    DataSnapshot snapshot = await _userRef.get();
    List<Map<String, dynamic>> users = [];

    if (snapshot.exists) {
      Map<dynamic, dynamic> userMap = snapshot.value as Map<dynamic, dynamic>;
      userMap.forEach((key, value) {
        users.add(Map<String, dynamic>.from(value));
      });
    }

    return users;
  }

  // Function to update the user status
  void _updateUserStatus(String uid, String newStatus) async {
    await _userRef.child(uid).update({'status': newStatus});
    Fluttertoast.showToast(msg: "User status updated to $newStatus");
    setState(() {}); // Refresh the list after updating
  }

  // Function to build the user list
  Widget _buildUserList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No users found'));
        }

        List<Map<String, dynamic>> users = snapshot.data!;

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> user = users[index];

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: user['profilePhotoUrl'] != null
                      ? NetworkImage(user['profilePhotoUrl'])
                      : AssetImage('assets/default_avatar.png') as ImageProvider,
                ),
                title: Text(user['username'] ?? 'Unknown'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user['email'] ?? 'No email'),
                    SizedBox(height: 4),
                    Text('Role: ${user['role'] ?? 'No role'}'),
                    SizedBox(height: 4),
                    Text('Status: ${user['status'] ?? 'No status'}'),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (String value) {
                    _updateUserStatus(user['uid'], value);
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        value: 'active',
                        child: Text('Activate'),
                      ),
                      PopupMenuItem(
                        value: 'suspended',
                        child: Text('Suspend'),
                      ),
                      PopupMenuItem(
                        value: 'disabled',
                        child: Text('Disable'),
                      ),
                    ];
                  },
                  child: Icon(Icons.more_vert),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Manage Users'),
      ),
      body: _buildUserList(),
    );
  }
}
