import 'package:cloud_firestore/cloud_firestore.dart';

class ContactModel {
  String id;
  String name;
  String email;
  String message;
  DateTime createdAt;

  ContactModel({
    required this.id,
    required this.name,
    required this.email,
    required this.message,
    required this.createdAt,
  });

  // Convert Firestore document to ContactModel instance
  factory ContactModel.fromDocument(DocumentSnapshot doc) {
    return ContactModel(
      id: doc.id,
      name: doc['name'] ?? '',
      email: doc['email'] ?? '',
      message: doc['message'] ?? '',
      createdAt: (doc['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert ContactModel instance to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

