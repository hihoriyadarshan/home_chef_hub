import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/user_model.dart';

class AdminManageUserScreen extends StatefulWidget {
  @override
  _AdminManageUserScreenState createState() => _AdminManageUserScreenState();
}

class _AdminManageUserScreenState extends State<AdminManageUserScreen> {
  final DatabaseReference _userRef = FirebaseDatabase.instance.ref('users');
  List<UserModel> _userList = [];
  List<UserModel> _filteredUserList = [];
  bool _isLoading = true;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  /// Fetch only users with role 'User' from Firebase Realtime Database
  Future<void> _fetchUsers() async {
    try {
      final snapshot = await _userRef.once();
      if (snapshot.snapshot.value != null) {
        // Check if the data is a Map and cast it properly
        final usersMap = Map<String, dynamic>.from(snapshot.snapshot.value as Map);

        // Debugging: Print the raw data fetched from Firebase
        print('Fetched users data: $usersMap');

        _userList = usersMap.entries
            .map((entry) {
          final user = UserModel.fromMap(Map<String, dynamic>.from(entry.value)..['uid'] = entry.key);

          // Debugging: Print each user’s details before filtering
          print('User: ${user.username}, Role: ${user.role}, Status: ${user.status}');

          return user;
        })
            .where((user) => user.role != null && user.role!.toLowerCase() == 'user') // Filter users with role 'User'
            .toList();

        // Initialize filtered list with all users
        _filteredUserList = _userList;

        // Debugging: Print the filtered user list
        print('Filtered user list (role = User): $_userList');
      } else {
        print('No users found in database.');
      }
    } catch (e) {
      print('Error fetching users: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Update user's status (active or suspended)
  Future<void> _updateUserStatus(String uid, String newStatus) async {
    try {
      await _userRef.child(uid).update({'status': newStatus});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User account status updated to $newStatus')),
      );
      _fetchUsers(); // Refresh the list after updating status
    } catch (e) {
      print('Error updating user status: $e');
    }
  }

  /// Delete user from the database
  Future<void> _deleteUser(String uid) async {
    try {
      await _userRef.child(uid).remove();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User account deleted successfully')),
      );
      _fetchUsers(); // Refresh the list after deletion
    } catch (e) {
      print('Error deleting user account: $e');
    }
  }

  /// Show user details in a modal dialog or bottom sheet
  void _showUserDetails(UserModel user) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 8,
              color: Colors.red, // Red background for the card
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: user.profilePhotoUrl != null
                            ? NetworkImage(user.profilePhotoUrl!)
                            : AssetImage('assets/default_profile.png') as ImageProvider, // Default image if profile photo is null
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Username: ${user.username}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), // White text
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Email: ${user.email}',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Phone: ${user.phone}',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Address: ${user.address}',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Date of Birth: ${user.dob}',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Status: ${user.status}',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Role: ${user.role}',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Filter the user list based on search text
  void _filterUsers(String searchText) {
    setState(() {
      _searchText = searchText.toLowerCase();
      _filteredUserList = _userList.where((user) {
        return user.username!.toLowerCase().contains(_searchText) ||
            user.email!.toLowerCase().contains(_searchText);
      }).toList();
    });
  }

  /// Build list of users with options to update status, delete the account, or view details
  Widget _buildUserList() {
    return ListView.builder(
      itemCount: _filteredUserList.length,
      itemBuilder: (context, index) {
        final user = _filteredUserList[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(user.username),
            subtitle: Text('Status: ${user.status} | Role: ${user.role}'),
            trailing: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'Enable') {
                  _updateUserStatus(user.uid, 'active');
                } else if (value == 'Disable') {
                  _updateUserStatus(user.uid, 'suspended');
                } else if (value == 'Delete') {
                  _deleteUser(user.uid);
                } else if (value == 'View Details') {
                  _showUserDetails(user);
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    value: 'View Details',
                    child: Text('View Details'),
                  ),
                  PopupMenuItem(
                    value: 'Enable',
                    child: Text('Enable'),
                  ),
                  PopupMenuItem(
                    value: 'Disable',
                    child: Text('Disable'),
                  ),
                  PopupMenuItem(
                    value: 'Delete',
                    child: Text('Delete'),
                  ),
                ];
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigates back to the previous screen
          },
        ),
        title: Text('Manage Users',
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
            )),
        backgroundColor: Color(0xFFD32F2F),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: _filterUsers,
              decoration: InputDecoration(
                labelText: 'Search Users',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredUserList.isEmpty
                ? Center(child: Text('No users found.'))
                : _buildUserList(),
          ),
        ],
      ),
    );
  }
}
