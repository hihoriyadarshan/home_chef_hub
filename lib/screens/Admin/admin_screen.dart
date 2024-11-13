import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        backgroundColor: Color(0xFFD32F2F),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFD32F2F)),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            _buildDrawerItem(context, Icons.analytics, 'DashBoard', '/Admin-dashboard'),
            _buildDrawerItem(context, Icons.people, 'Manage user', '/manage-user'),
            _buildDrawerItem(context, Icons.restaurant_menu, 'Manage Chef', '/manage-chef'),
            _buildDrawerItem(context, Icons.dining, 'Create Category', '/create-category'),
            _buildDrawerItem(context, Icons.fastfood, 'Create Sub-Category', '/create-sub_category'),
            _buildDrawerItem(context, Icons.dining, 'Manage Category', '/manage-category'),
            _buildDrawerItem(context, Icons.fastfood, 'Manage Sub-Category', '/manage-sub_category'),
            _buildDrawerItem(context, Icons.lunch_dining, 'View All Dishes', '/manage-dishes'),
            _buildDrawerItem(context, Icons.receipt_long, 'All User Booking Details', '/admin-booking-details'),
            _buildDrawerItem(context, Icons.warning, 'Complaint', '/admin-users-issue'),
            _buildDrawerItem(context, Icons.contact_support, 'Contact Us', '/Admin-contact'),
            _buildDrawerItem(context, Icons.feedback_outlined, 'Feedback', '/admin-booking-details'),
            _buildDrawerItem(context, Icons.person, 'Profile', '/profile'),
            _buildDrawerItem(context, Icons.password, 'Change Password', '/change-password'),
            _buildDrawerItem(context, Icons.settings, 'Settings', ''),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, Admin',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [

                  _buildDashboardItem(context, title: 'Analytics', icon: Icons.show_chart, onTap: () {
                    Navigator.pushNamed(context, '/analytics');
                  }),
                  _buildDashboardItem(context, title: 'Manage Users', icon: Icons.people, onTap: () {
                    Navigator.pushNamed(context, '/manage-user');
                  }),
                  _buildDashboardItem(context, title: 'Manage Chefs', icon: Icons.restaurant_menu, onTap: () {
                    Navigator.pushNamed(context, '/manage-chef');
                  }),
                  _buildDashboardItem(context, title: 'Create Category', icon: Icons.dining, onTap: () {
                    Navigator.pushNamed(context, '/create-category');
                  }),
                  _buildDashboardItem(context, title: 'Create Sub-Category', icon: Icons.fastfood, onTap: () {
                    Navigator.pushNamed(context, '/create-sub_category');
                  }),
                  _buildDashboardItem(context, title: 'Manage Category', icon: Icons.dining, onTap: () {
                    Navigator.pushNamed(context, '/manage-category');
                  }),
                  _buildDashboardItem(context, title: 'Manage Sub-Category', icon: Icons.fastfood, onTap: () {
                    Navigator.pushNamed(context, '/manage-sub_category');
                  }),
                  _buildDashboardItem(context, title: 'View All Dishes', icon: Icons.lunch_dining, onTap: () {
                    Navigator.pushNamed(context, '/manage-dishes');
                  }),
                  _buildDashboardItem(context, title: 'All user Booking Details', icon: Icons.receipt_long, onTap: () {
                    Navigator.pushNamed(context, '/admin-booking-details');
                  }),
                  _buildDashboardItem(context, title: 'Complaint', icon: Icons.warning, onTap: () {
                    Navigator.pushNamed(context, '/admin-users-issue');
                  }),
                  _buildDashboardItem(context, title: 'Contact Us', icon: Icons.contact_support, onTap: () {
                    Navigator.pushNamed(context, '/Admin-contact');
                  }),
                  _buildDashboardItem(context, title: 'Feedback', icon: Icons.feedback_outlined, onTap: () {
                    Navigator.pushNamed(context, '/admin-booking-details');
                  }),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardItem(BuildContext context, {required String title, required IconData icon, required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 3, blurRadius: 7, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.redAccent),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        if (route.isNotEmpty) Navigator.pushNamed(context, route);
      },
    );
  }
}
