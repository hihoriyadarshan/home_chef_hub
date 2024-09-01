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
          : ListView.builder(
        itemCount: _chefs.length,
        itemBuilder: (context, index) {
          UserModel chef = _chefs[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: chef.profilePhotoUrl != null
                  ? NetworkImage(chef.profilePhotoUrl!)
                  : AssetImage('assets/placeholder.png') as ImageProvider,
            ),
            title: Text(chef.username),
            subtitle: Text(chef.email),
            onTap: () {
              // Handle tap, e.g., navigate to chef details
            },
          );
        },
      ),
    );
  }
}
