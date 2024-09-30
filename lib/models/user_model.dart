class UserModel {
  final String uid;
  final String username;
  final String email;
  final String dob;
  final String phone;
  final String address;
  final String? profilePhotoUrl;
  final String? role;
  final String status; // Add this field for status ('active', 'suspended', 'disabled')

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.dob,
    required this.phone,
    required this.address,
    this.profilePhotoUrl,
    this.role,
    this.status = 'active', // Default status is 'active'
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'dob': dob,
      'phone': phone,
      'address': address,
      'profilePhotoUrl': profilePhotoUrl,
      'role': role,
      'status': status, // Include status in the map
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      username: map['username'],
      email: map['email'],
      dob: map['dob'],
      phone: map['phone'],
      address: map['address'],
      profilePhotoUrl: map['profilePhotoUrl'],
      role: map['role'],
      status: map['status'] ?? 'active', // Default to 'active' if not present
    );
  }
}
