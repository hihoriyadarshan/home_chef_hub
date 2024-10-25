import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';
import '../screens/ProfileUpdateScreen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  UserModel? _userModel;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  void loadUserProfile() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        DatabaseReference userRef = _database.ref().child('users').child(user.uid);
        DataSnapshot snapshot = await userRef.get();

        if (snapshot.exists) {
          Map<String, dynamic> userData = Map<String, dynamic>.from(snapshot.value as Map);
          if (!userData.containsKey('address')) {
            userData['address'] = 'No address provided';
          }
          if (!userData.containsKey('profilePhotoUrl')) {
            userData['profilePhotoUrl'] = null;
          }

          setState(() {
            _userModel = UserModel.fromMap(userData);
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Profile data not found';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User not logged in';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load profile data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.black),
            onPressed: () async {
              bool? isUpdated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileUpdateScreen(userModel: _userModel!),
                ),
              );
              if (isUpdated == true) {
                loadUserProfile();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!, style: TextStyle(color: Colors.red)))
          : SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    height: 200,
                    color: Colors.red, // The wave background color
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      SizedBox(height: 50), // Adjusted for wave effect
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade300,
                        child: ClipOval(
                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/default_profile.png', // Fallback asset image
                            image: _userModel?.profilePhotoUrl ?? '',
                            imageErrorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/default_profile.png', // Fallback in case of image load error
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              );
                            },
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        _userModel!.username ?? 'N/A',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileInfoRow(
                    icon: Icons.account_circle,
                    label: 'Name',
                    value: _userModel!.username ?? 'N/A',
                  ),
                  ProfileInfoRow(
                    icon: Icons.email,
                    label: 'E-Mail',
                    value: _userModel!.email ?? 'N/A',
                  ),
                  ProfileInfoRow(
                    icon: Icons.phone,
                    label: 'Phone no.',
                    value: _userModel!.phone ?? 'N/A',
                  ),
                  ProfileInfoRow(
                    icon: Icons.calendar_today,
                    label: 'Date of Birth',
                    value: _userModel!.dob ?? 'N/A',
                  ),
                  ProfileInfoRow(
                    icon: Icons.home,
                    label: 'Address',
                    value: _userModel!.address ?? 'N/A',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 50);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 50);
    path.quadraticBezierTo(
        firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 100);
    var secondEndPoint = Offset(size.width, size.height - 50);
    path.quadraticBezierTo(
        secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height - 50);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
