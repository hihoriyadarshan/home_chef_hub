import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminContactUsScreen extends StatefulWidget {
  @override
  _AdminContactUsScreenState createState() => _AdminContactUsScreenState();
}

class _AdminContactUsScreenState extends State<AdminContactUsScreen> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  List<Map<String, dynamic>> _contactSubmissions = [];
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _fetchContactSubmissions();
  }

  Future<void> _fetchContactSubmissions() async {
    try {
      final snapshot = await _database.ref().child('contacts').get();
      final data = snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        setState(() {
          _contactSubmissions = data.entries.map((entry) {
            final value = entry.value as Map<dynamic, dynamic>;
            return {
              'id': entry.key,
              'name': value['name'],
              'email': value['email'],
              'message': value['message'],
              'timestamp': value['timestamp'],
            };
          }).toList();
        });
      } else {
        setState(() {
          _contactSubmissions = [];
        });
      }
    } catch (error) {
      setState(() {
        _isError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us'),
        backgroundColor: Colors.red,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _isError
          ? Center(child: Text('Error fetching contact submissions.'))
          : _contactSubmissions.isEmpty
          ? Center(child: Text('No submissions found.'))
          : ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: _contactSubmissions.length,
        itemBuilder: (context, index) {
          final submission = _contactSubmissions[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name: ${submission['name']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Email: ${submission['email']}'),
                  SizedBox(height: 8),
                  Text('Message: ${submission['message']}'),
                  SizedBox(height: 8),
                  Text(
                    'Date: ${submission['timestamp']}',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
