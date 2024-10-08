// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../models/booking_model.dart'; // Ensure this file has the correct definition for BookingModel
// import '../../models/user_model.dart';   // Ensure this file has the correct definition for UserModel
// import '../../models/dishes_model.dart'; // Ensure this is correctly defined and imported
//
// class AdminBookingDetails extends StatefulWidget {
//   @override
//   _AdminBookingDetailsState createState() => _AdminBookingDetailsState();
// }
//
// class _AdminBookingDetailsState extends State<AdminBookingDetails> {
//   List<BookingModel> bookings = [];
//   List<UserModel> chefs = [];
//   Map<String, List<DishModel>> dishesMap = {}; // Map to hold dishes for each booking
//
//   @override
//   void initState() {
//     super.initState();
//     fetchAllBookingDetails();
//   }
//
//   Future<void> fetchAllBookingDetails() async {
//     try {
//       // Fetch all bookings
//       QuerySnapshot bookingSnapshot = await FirebaseFirestore.instance
//           .collection('bookings')
//           .get();
//
//       List<BookingModel> fetchedBookings = [];
//       for (var doc in bookingSnapshot.docs) {
//         fetchedBookings.add(BookingModel.fromMap(doc.data() as Map<String, dynamic>));
//       }
//
//       setState(() {
//         bookings = fetchedBookings;
//       });
//
//       // Fetch chefs and dishes for each booking
//       for (BookingModel booking in bookings) {
//         // Fetch chef details
//         DocumentSnapshot chefSnapshot = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(booking.chefId) // Get chefId from booking
//             .get();
//
//         if (chefSnapshot.exists) {
//           chefs.add(UserModel.fromMap(chefSnapshot.data() as Map<String, dynamic>));
//         }
//
//         // Fetch dishes details
//         List<DishModel> fetchedDishes = [];
//         for (String dishId in booking.dishIds) {
//           DocumentSnapshot dishSnapshot = await FirebaseFirestore.instance
//               .collection('dishes')
//               .doc(dishId)
//               .get();
//
//           if (dishSnapshot.exists) {
//             fetchedDishes.add(DishModel.fromMap(dishSnapshot.data() as Map<String, dynamic>));
//           }
//         }
//
//         // Store the dishes in the map
//         dishesMap[booking.bookingId] = fetchedDishes;
//       }
//
//       setState(() {
//         // After fetching all chefs and dishes, update the state
//       });
//     } catch (e) {
//       print('Error fetching data: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('All Booking Details'),
//       ),
//       body: bookings.isEmpty
//           ? Center(child: CircularProgressIndicator())
//           : ListView.builder(
//         itemCount: bookings.length,
//         itemBuilder: (context, index) {
//           BookingModel booking = bookings[index];
//           UserModel? chef = chefs.firstWhere((c) => c.uid == booking.chefId, orElse: () => null);
//           List<DishModel> dishes = dishesMap[booking.bookingId] ?? [];
//
//           return Card(
//             margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Booking ID: ${booking.bookingId}', style: TextStyle(fontSize: 16)),
//                   SizedBox(height: 10),
//                   chef == null
//                       ? CircularProgressIndicator()
//                       : Text('Chef: ${chef.username} (${chef.email})', style: TextStyle(fontSize: 16)),
//                   SizedBox(height: 10),
//                   Text('Booking Date: ${booking.bookingDate}', style: TextStyle(fontSize: 16)),
//                   SizedBox(height: 10),
//                   Text('Total Amount: \$${booking.totalAmount}', style: TextStyle(fontSize: 16)),
//                   SizedBox(height: 10),
//                   Text('Dishes:', style: TextStyle(fontSize: 16)),
//                   if (dishes.isEmpty)
//                     Text('No dishes available.', style: TextStyle(fontSize: 14))
//                   else
//                     Column(
//                       children: dishes.map((dish) {
//                         return ListTile(
//                           title: Text(dish.dishName),
//                           subtitle: Text('\$${dish.dishPrice.toString()}'),
//                         );
//                       }).toList(),
//                     ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
