// contact_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ContactModel {
  String id;
  String name;
  String email;
  String phone;
  String message;
  DateTime createdAt;

  ContactModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.message,
    required this.createdAt,
  });

  // Convert Firestore document to ContactModel instance
  factory ContactModel.fromDocument(DocumentSnapshot doc) {
    return ContactModel(
      id: doc.id,
      name: doc['name'] ?? '',
      email: doc['email'] ?? '',
      phone: doc['phone'] ?? '',
      message: doc['message'] ?? '',
      createdAt: (doc['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert ContactModel instance to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

