import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'profile_screen.dart';

class ChefScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chef Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login'); // Log out and navigate to login screen
            },
          ),
        ],
      ),
      drawer: Drawer( // Left-side sutter (drawer)
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
                // Add any functionality for Home, if needed
              },
            ),
            ListTile(
              leading: Icon(Icons.book),
              title: Text('Blog'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                // Navigate to Blog page if required
                Navigator.pushNamed(context, '/blog'); // Assume there's a route for the Blog
              },
            ),
            ListTile(
              leading: Icon(Icons.contact_page),
              title: Text('Contact'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                // Navigate to Contact page
                Navigator.pushNamed(context, '/contact'); // Assume there's a route for Contact
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome Chef!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            // View Upcoming Bookings button
            ElevatedButton(
              onPressed: () {
                // Navigate to upcoming bookings
                Navigator.pushNamed(context, '/upcomingBookings'); // Assume there's a route for upcoming bookings
              },
              child: Text('View Upcoming Bookings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Button color
                padding: EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Mark Booking as Completed button
            ElevatedButton(
              onPressed: () {
                // Logic to mark bookings as completed
                // Navigate to booking details for marking completion
                Navigator.pushNamed(context, '/markBooking'); // Assume there's a route for marking bookings as completed
              },
              child: Text('Mark Booking as Completed'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // Button color
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar for extra sections
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Blog',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_page),
            label: 'Contact',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
            // Home Section
              Navigator.pushNamed(context, '/home'); // Assume there's a route for Home
              break;
            case 1:
            // Blog Section
              Navigator.pushNamed(context, '/blog'); // Navigate to Blog page
              break;
            case 2:
            // Contact Section
              Navigator.pushNamed(context, '/contact'); // Navigate to Contact page
              break;
          }
        },
      ),
    );
  }
}
