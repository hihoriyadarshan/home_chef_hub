import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../login_screen.dart';
import '../profile_screen.dart';

class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); // Sign out from Firebase
              Navigator.pushReplacementNamed(context, '/login'); // Use named route for login screen
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.redAccent,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.analytics),
              title: Text('DashBoard'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushReplacementNamed(context, '/Admin-dashboard'); // Use named route for Admin Dashboard
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Manage user'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/manage-user'); // Use named route for Manage Users
              },
            ),
            ListTile(
              leading: Icon(Icons.restaurant_menu),
              title: Text('Manage Chef'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/manage-chef'); // Use named route for Manage Chefs
              },
            ),
            ListTile(
              leading: Icon(Icons.fastfood),
              title: Text('Create Category'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/create-category'); // Use named route for Create Category
              },
            ),
            ListTile(
              leading: Icon(Icons.fastfood),
              title: Text('Create Sub-Category'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/create-sub_category'); // Use named route for Create Sub-Category
              },
            ),
            ListTile(
              leading: Icon(Icons.fastfood),
              title: Text('Manage Category'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/manage-category'); // Use named route for Manage Category
              },
            ),
            ListTile(
              leading: Icon(Icons.fastfood),
              title: Text('Manage Sub-Category'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/manage-sub_category'); // Use named route for Manage Sub-Category
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/profile'); // Use named route for Profile
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Navigate to Settings screen (no named route defined yet)
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut(); // Sign out from Firebase
                Navigator.pushReplacementNamed(context, '/login'); // Use named route for login screen
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
              'Welcome, Admin!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  _buildDashboardItem(
                    context,
                    title: 'View Reports',
                    icon: Icons.analytics,
                    onTap: () {
                      // You can add the route for reports later
                    },
                  ),
                  _buildDashboardItem(
                    context,
                    title: 'Manage Users',
                    icon: Icons.people,
                    onTap: () {
                      Navigator.pushNamed(context, '/manage-user'); // Named route for Manage Users
                    },
                  ),
                  _buildDashboardItem(
                    context,
                    title: 'Manage Chefs',
                    icon: Icons.restaurant_menu,
                    onTap: () {
                      Navigator.pushNamed(context, '/manage-chef'); // Named route for Manage Chefs
                    },
                  ),
                  _buildDashboardItem(
                    context,
                    title: 'Create Category',
                    icon: Icons.fastfood,
                    onTap: () {
                      Navigator.pushNamed(context, '/create-category'); // Named route for Create Category
                    },
                  ),
                  _buildDashboardItem(
                    context,
                    title: 'Create Sub-Category',
                    icon: Icons.fastfood,
                    onTap: () {
                      Navigator.pushNamed(context, '/create-sub_category'); // Named route for Create Sub-Category
                    },
                  ),
                  _buildDashboardItem(
                    context,
                    title: 'Manage Category',
                    icon: Icons.analytics,
                    onTap: () {
                      Navigator.pushNamed(context, '/manage-category'); // Named route for Manage Category
                    },
                  ),
                  _buildDashboardItem(
                    context,
                    title: 'Manage Sub-Category',
                    icon: Icons.analytics,
                    onTap: () {
                      Navigator.pushNamed(context, '/manage-sub_category'); // Named route for Manage Sub-Category
                    },
                  ),
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
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 3,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: Colors.redAccent,
            ),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
