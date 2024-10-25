import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_chef_hub/models/contact_model.dart';

class AdminContactUsScreen extends StatefulWidget {
  @override
  _AdminContactUsScreenState createState() => _AdminContactUsScreenState();
}

class _AdminContactUsScreenState extends State<AdminContactUsScreen> {
  final CollectionReference _contactCollection =
  FirebaseFirestore.instance.collection('contacts');

  Future<List<ContactModel>> _fetchContacts() async {
    try {
      QuerySnapshot snapshot = await _contactCollection.get();
      // Check if the query has documents
      if (snapshot.docs.isEmpty) {
        print('No contacts found');
        return [];
      }

      // Map Firestore docs to ContactModel instances
      return snapshot.docs.map((doc) {
        try {
          return ContactModel.fromDocument(doc);  // Try parsing each document
        } catch (e) {
          print('Error parsing document ${doc.id}: $e');
          return null;  // Return null for any faulty document
        }
      }).where((contact) => contact != null).toList() as List<ContactModel>;
    } catch (e) {
      print('Error fetching contacts: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us Messages'),
        backgroundColor: Colors.red, // Change color if needed
      ),
      body: FutureBuilder<List<ContactModel>>(
        future: _fetchContacts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List<ContactModel>? contacts = snapshot.data;

          // Check if contacts is empty
          if (contacts == null || contacts.isEmpty) {
            return Center(child: Text('No messages found.'));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Ensure horizontal scrolling
            child: DataTable(
              columns: [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Phone')),
                DataColumn(label: Text('Message')),
                DataColumn(label: Text('Date')),
              ],
              rows: contacts.map((contact) {
                return DataRow(cells: [
                  DataCell(Text(contact.name)),
                  DataCell(Text(contact.email)),
                  DataCell(Text(contact.phone)),
                  DataCell(
                    // Limit the message preview to avoid large text overflow
                    Container(
                      width: 150, // Adjust as necessary
                      child: Text(
                        contact.message,
                        overflow: TextOverflow.ellipsis, // Add ellipsis if text is too long
                      ),
                    ),
                  ),
                  DataCell(Text(contact.createdAt.toLocal().toString().split(' ')[0])),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
