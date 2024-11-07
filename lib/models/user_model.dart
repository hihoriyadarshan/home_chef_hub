class UserModel {
  final String uid;
  final String username;
  final String email;
  final String dob;
  final String phone;
  final String address;
  final String? profilePhotoUrl;
  final String? role;
  final String status;
  final double balance;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.dob,
    required this.phone,
    required this.address,
    this.profilePhotoUrl,
    this.role,
    this.status = 'active',
    this.balance = 0.0,
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
      'status': status,
      'balance': balance,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      dob: map['dob'] as String,
      phone: map['phone'] as String,
      address: map['address'] as String,
      profilePhotoUrl: map['profilePhotoUrl'] as String?,
      role: map['role'] as String?,
      status: map['status'] as String? ?? 'active',
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
