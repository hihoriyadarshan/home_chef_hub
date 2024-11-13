import 'package:flutter/material.dart';

class ChefHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chef Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Handle log out
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red,
              ),
              child: Text(
                'Chef Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context); // Close drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.book),
              title: Text('Blog'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/blog');
              },
            ),
            ListTile(
              leading: Icon(Icons.password),
              title: Text('Change Password'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/change-password');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          children: <Widget>[
            _buildMenuItem(
              context,
              icon: Icons.food_bank,
              label: 'My Dishes',
              route: '/chefDishes', // Route to view chef's dishes
              color: Colors.orange,
            ),
            _buildMenuItem(
              context,
              icon: Icons.add,
              label: 'Add New Dish',
              route: '/add-dish', // Route to add new dish
              color: Colors.green,
            ),
            _buildMenuItem(
              context,
              icon: Icons.event,
              label: 'Active Bookings',
              route: '/chef-my-bookings', // Route to view active bookings
              color: Colors.blue,
            ),
            _buildMenuItem(
              context,
              icon: Icons.attach_money,
              label: 'Earnings',
              route: '/earnings', // Route to view chef's earnings
              color: Colors.purple,
            ),
            _buildMenuItem(
              context,
              icon: Icons.schedule,
              label: 'Booking History',
              route: '/bookingHistory', // Route to view completed bookings
              color: Colors.teal,
            ),
            _buildMenuItem(
              context,
              icon: Icons.reviews,
              label: 'Reviews',
              route: '/reviews', // Route to view customer reviews
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build menu item widget
  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String label, required String route, required Color color}) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route); // Navigate to the appropriate route
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
