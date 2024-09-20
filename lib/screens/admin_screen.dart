import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import './admin_manage_users.dart';
import './admin_chef_manage.dart';
import './login_screen.dart';
import './profile_screen.dart';
import './category_screen.dart';
import './sub-category_screen.dart';
import './manage-category_screen.dart';
import './manage-subcategory_screen.dart';

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
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()), // Navigate to login screen
              );
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
              onTap: ()
              {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminScreen()),
                );
              },
              // Navigate to Profile screen

            ),

            ListTile(
              leading: Icon(Icons.people),
              title: Text('Manage user'),
              onTap: ()
              {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminManageUsers()),
                );
              },
              // Navigate to Profile screen

            ),



            ListTile(
              leading: Icon(Icons.restaurant_menu),
              title: Text('Manage Chef'),
              onTap: ()
              {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminChefManage()),
                );
              },
              // Navigate to Profile screen

            ),

            ListTile(
              leading: Icon(Icons.fastfood),
              title: Text('Create Category'),
              onTap: ()
              {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategoryScreen()),
                );
              },
              // Navigate to Profile screen

            ),

            ListTile(
              leading: Icon(Icons.fastfood),
              title: Text('Create Sub-Category'),
              onTap: ()
              {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SubCategoryScreen()),
                );
              },
              // Navigate to Profile screen

            ),

            ListTile(
              leading: Icon(Icons.fastfood),
              title: Text('Manage Category'),
              onTap: ()
              {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageCategoryScreen()),
                );
              },
              // Navigate to Profile screen

            ),

            ListTile(
              leading: Icon(Icons.fastfood),
              title: Text('Manage Sub-Category'),
              onTap: ()
              {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageSubCategoryScreen()),
                );
              },
              // Navigate to Profile screen

            ),

            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: ()
              {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
              // Navigate to Profile screen

            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Navigate to Settings screen
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut(); // Sign out from Firebase
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginScreen()), // Navigate to login screen
                );
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
                      // Navigate to Reports page
                    },
                  ),




                  _buildDashboardItem(
                    context,
                    title: 'Manage Users',
                    icon: Icons.people,
                    onTap: () {
                      // Navigate to Manage Users page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminManageUsers(),
                        ),
                      );
                    },
                  ),
                  _buildDashboardItem(
                    context,
                    title: 'Manage Chefs',
                    icon: Icons.restaurant_menu,
                    onTap: () {
                      // Navigate to Manage Chefs page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminChefManage(),
                        ),
                      );
                    },
                  ),


                  _buildDashboardItem(
                    context,
                    title: 'Create Category',
                    icon: Icons.fastfood,
                    onTap: () {
                      // Navigate to Settings page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryScreen(),
                        ),
                      );
                    },
                  ),

                  _buildDashboardItem(
                    context,
                    title: 'Create Sub-Category',
                    icon: Icons.fastfood,
                    onTap: () {
                      // Navigate to Reports page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubCategoryScreen(),
                        ),
                      );
                    },
                  ),

                  _buildDashboardItem(
                    context,
                    title: 'Manage Category',
                    icon: Icons.analytics,
                    onTap: () {
                      // Navigate to Reports page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageCategoryScreen(),
                        ),
                      );
                    },
                  ),

                  _buildDashboardItem(
                    context,
                    title: 'Manage Sub-Category',
                    icon: Icons.analytics,
                    onTap: () {
                      // Navigate to Reports page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageSubCategoryScreen(),
                        ),
                      );
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
