import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:home_chef_hub/models/booking_model.dart';
import 'package:home_chef_hub/models/user_model.dart'; // Import UserModel
import 'package:home_chef_hub/models/dishes_model.dart'; // Import DishModel

class AdminBookingDetailsScreen extends StatefulWidget {
  @override
  _AdminBookingDetailsScreenState createState() => _AdminBookingDetailsScreenState();
}

class _AdminBookingDetailsScreenState extends State<AdminBookingDetailsScreen> {
  final DatabaseReference _bookingRef = FirebaseDatabase.instance.ref().child('bookings');
  final DatabaseReference _userRef = FirebaseDatabase.instance.ref().child('users'); // User Reference
  final DatabaseReference _dishRef = FirebaseDatabase.instance.ref().child('dishes'); // Dish Reference

  List<BookingModel> _bookings = [];
  List<BookingModel> _filteredBookings = [];
  Map<String, UserModel> _userDetails = {}; // Store User Details
  Map<String, DishModel> _dishDetails = {}; // Store Dish Details
  bool _isLoading = true;
  String _searchText = ''; // Search text variable

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      DatabaseEvent event = await _bookingRef.once();
      final snapshot = event.snapshot;

      if (snapshot.exists) {
        final bookingsMap = snapshot.value as Map<Object?, Object?>;
        List<BookingModel> bookings = [];

        for (var entry in bookingsMap.entries) {
          final value = entry.value;
          if (value is Map<Object?, Object?>) {
            BookingModel booking = BookingModel.fromMap(value.cast<String, dynamic>());
            bookings.add(booking);

            // Fetch User and Chef details in parallel
            _fetchUserDetails(booking.userId);
            _fetchUserDetails(booking.chefId, isChef: true);

            // Fetch Dish details
            _fetchDishDetails(booking.dishId);
          }
        }

        setState(() {
          _bookings = bookings;
          _filteredBookings = bookings; // Initialize filtered bookings
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print("Error fetching bookings: $error");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fetch User or Chef Details
  Future<void> _fetchUserDetails(String userId, {bool isChef = false}) async {
    try {
      DatabaseEvent event = await _userRef.child(userId).once();
      final snapshot = event.snapshot;

      if (snapshot.exists) {
        final userMap = snapshot.value as Map<Object?, Object?>;
        UserModel user = UserModel.fromMap(userMap.cast<String, dynamic>());

        setState(() {
          _userDetails[userId] = user; // Store the user/chef details
        });
      }
    } catch (error) {
      print("Error fetching user/chef details: $error");
    }
  }

  // Fetch Dish Details
  Future<void> _fetchDishDetails(String dishId) async {
    try {
      DatabaseEvent event = await _dishRef.child(dishId).once();
      final snapshot = event.snapshot;

      if (snapshot.exists) {
        final dishMap = snapshot.value as Map<Object?, Object?>;
        DishModel dish = DishModel.fromMap(dishMap.cast<String, dynamic>());

        setState(() {
          _dishDetails[dishId] = dish; // Store the dish details
        });
      }
    } catch (error) {
      print("Error fetching dish details: $error");
    }
  }

  /// Filter the bookings based on search text
  void _filterBookings(String searchText) {
    setState(() {
      _searchText = searchText.toLowerCase();
      _filteredBookings = _bookings.where((booking) {
        final user = _userDetails[booking.userId];
        final chef = _userDetails[booking.chefId];
        final dish = _dishDetails[booking.dishId];

        return booking.bookingId.toLowerCase().contains(_searchText) ||
            (user?.username?.toLowerCase().contains(_searchText) ?? false) ||
            (chef?.username?.toLowerCase().contains(_searchText) ?? false) ||
            (dish?.dishName?.toLowerCase().contains(_searchText) ?? false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigates back to the previous screen
          },
        ),
        title: Text(
          'Admin Booking Details',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFFD32F2F),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: _filterBookings,
              decoration: InputDecoration(
                labelText: 'Search Bookings',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredBookings.isEmpty
                ? Center(child: Text('No bookings available'))
                : ListView.builder(
              itemCount: _filteredBookings.length,
              itemBuilder: (context, index) {
                final booking = _filteredBookings[index];
                final user = _userDetails[booking.userId];
                final chef = _userDetails[booking.chefId];
                final dish = _dishDetails[booking.dishId];

                return Card(
                  margin: EdgeInsets.all(10),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Booking ID: ${booking.bookingId}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'User: ${user?.username ?? 'Loading...'}',
                                style: TextStyle(fontSize: 14),
                              ),
                              Text(
                                'User Phone: ${user?.phone ?? 'Loading...'}',
                                style: TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Chef: ${chef?.username ?? 'Loading...'}',
                                style: TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Chef Phone: ${chef?.phone ?? 'Loading...'}',
                                style: TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Dish: ${dish?.dishName ?? 'Loading...'}',
                                style: TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Date: ${booking.bookingDate}',
                                style: TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Status: ${booking.status}',
                                style: TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Total Amount: \$${booking.totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10), // Space between details and image
                        Expanded(
                          flex: 1,
                          child: dish?.dishImageUrl != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              dish!.dishImageUrl!,
                              height: 200, // Set the height as per your design,
                              fit: BoxFit.cover,
                            ),
                          )
                              : Container(
                            height: 120,
                            color: Colors.grey[300], // Placeholder if image is not available
                            child: Center(child: Text('No Image')),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
