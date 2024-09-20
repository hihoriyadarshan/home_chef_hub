import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart'; // Import your UserModel class

class AdminChefManage extends StatefulWidget {
  @override
  _AdminChefManageState createState() => _AdminChefManageState();
}

class _AdminChefManageState extends State<AdminChefManage> {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref().child('users');
  List<UserModel> _chefs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _getChefs();
  }

  Future<void> _getChefs() async {
    try {
      _usersRef.orderByChild('role').equalTo('Chef').once().then((snapshot) {
        final Map<dynamic, dynamic>? usersMap = snapshot.snapshot.value as Map<dynamic, dynamic>?;
        if (usersMap != null) {
          List<UserModel> chefs = [];
          usersMap.forEach((key, value) {
            final userMap = Map<String, dynamic>.from(value);
            UserModel user = UserModel.fromMap(userMap);
            chefs.add(user);
          });
          setState(() {
            _chefs = chefs;
            _loading = false;
          });
        } else {
          setState(() {
            _loading = false;
          });
        }
      });
    } catch (e) {
      print('Error fetching chefs: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Chefs'),
        backgroundColor: Colors.redAccent,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _chefs.isEmpty
          ? Center(child: Text('No chefs found'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Scroll horizontally if table overflows
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildChefTable(), // Table with chef data
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChefTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('Profile Photo', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Username', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: _chefs
          .asMap()
          .entries
          .map(
            (entry) => DataRow(
          color: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                return entry.key % 2 == 0
                    ? Colors.grey[200] // Alternating row colors
                    : Colors.white;
              }),
          cells: [
            DataCell(CircleAvatar(
              backgroundImage: entry.value.profilePhotoUrl != null
                  ? NetworkImage(entry.value.profilePhotoUrl!)
                  : AssetImage('assets/placeholder.png') as ImageProvider,
            )),
            DataCell(Text(entry.value.username)),
            DataCell(Text(entry.value.email)),
            DataCell(Text(entry.value.phone)),
            DataCell(
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Add enable logic here
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text('Enable'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Add disable logic here
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text('Disable'),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
          .toList(),
    );
  }
}
