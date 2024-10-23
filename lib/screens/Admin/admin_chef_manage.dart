import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/user_model.dart';

class AdminChefManageScreen extends StatefulWidget {
  @override
  _AdminChefManageScreenState createState() => _AdminChefManageScreenState();
}

class _AdminChefManageScreenState extends State<AdminChefManageScreen> {
  final DatabaseReference _chefRef = FirebaseDatabase.instance.ref('users');
  List<UserModel> _chefList = [];
  List<UserModel> _filteredChefList = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchChefs();
  }

  Future<void> _fetchChefs() async {
    try {
      final snapshot = await _chefRef.orderByChild('role').equalTo('Chef').once();
      if (snapshot.snapshot.value != null) {
        final Map<dynamic, dynamic> chefsMap = snapshot.snapshot.value as Map<dynamic, dynamic>;

        // Debugging: Print the raw data fetched from Firebase
        print('Fetched chefs data: $chefsMap');

        _chefList = chefsMap.entries.map((entry) {
          final Map<String, dynamic> chefData = Map<String, dynamic>.from(entry.value);
          chefData['uid'] = entry.key; // Assign the UID
          return UserModel.fromMap(chefData);
        }).toList();

        // Debugging: Print the chef list
        print('Filtered chef list: $_chefList');
        _filteredChefList = _chefList; // Initialize the filtered list
      } else {
        print('No chefs found in the database.');
      }
    } catch (e) {
      print('Error fetching chefs: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchChefs(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isNotEmpty) {
        _filteredChefList = _chefList.where((chef) {
          return chef.username.toLowerCase().contains(query.toLowerCase());
        }).toList();
      } else {
        _filteredChefList = _chefList;
      }
    });
  }

  Future<void> _updateChefStatus(String uid, String newStatus) async {
    try {
      await _chefRef.child(uid).update({'status': newStatus});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chef account status updated to $newStatus')),
      );
      _fetchChefs(); // Refresh the list after updating status
    } catch (e) {
      print('Error updating chef status: $e');
    }
  }

  Future<void> _deleteChef(String uid) async {
    try {
      await _chefRef.child(uid).remove();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chef account deleted successfully')),
      );
      _fetchChefs(); // Refresh the list after deletion
    } catch (e) {
      print('Error deleting chef account: $e');
    }
  }

  void _showUserDetails(UserModel chef) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${chef.username}\'s Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Ensure it fits content
              children: <Widget>[
                chef.profilePhotoUrl != null && chef.profilePhotoUrl!.isNotEmpty
                    ? CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(chef.profilePhotoUrl!),
                )
                    : CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                ListBody(
                  children: <Widget>[
                    Text('Username: ${chef.username}'),
                    Text('Email: ${chef.email}'),
                    Text('Date of Birth: ${chef.dob}'),
                    Text('Phone: ${chef.phone}'),
                    Text('Address: ${chef.address}'),
                    Text('Role: ${chef.role}'),
                    Text('Status: ${chef.status}'),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildChefList() {
    return ListView.builder(
      itemCount: _filteredChefList.length,
      itemBuilder: (context, index) {
        final chef = _filteredChefList[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(chef.username),
            subtitle: Text('Status: ${chef.status}'),
            trailing: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'Enable') {
                  _updateChefStatus(chef.uid, 'active');
                } else if (value == 'Disable') {
                  _updateChefStatus(chef.uid, 'suspended');
                } else if (value == 'Delete') {
                  _deleteChef(chef.uid);
                } else if (value == 'View Details') {
                  _showUserDetails(chef);
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
        title: Text('Manage Chefs',
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
            )),
        backgroundColor: Color(0xFFD32F2F),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56.0), // Height of the search bar
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _searchChefs,
              decoration: InputDecoration(
                hintText: 'Search by username...',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _filteredChefList.isEmpty
          ? Center(child: Text('No chefs found.'))
          : _buildChefList(),
    );
  }
}
