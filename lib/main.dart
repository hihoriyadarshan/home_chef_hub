import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:home_chef_hub/screens/Admin/admin_booking_details.dart';
import 'package:home_chef_hub/screens/Admin/admin_chef_manage.dart';
import 'package:home_chef_hub/screens/Admin/admin_manage_users.dart';
import 'package:home_chef_hub/screens/Admin/admin_show_all_dish.dart';
import 'package:home_chef_hub/screens/Admin/category_screen.dart';
import 'package:home_chef_hub/screens/Admin/sub-category_screen.dart';
import 'package:home_chef_hub/screens/user/help_faq_screen.dart';
import './screens/WelcomeScreen.dart';
import './screens/login_screen.dart';
import './screens/registration_screen.dart';
import 'screens/user/home_screen.dart';
import 'screens/Chef_Screen/chef_screen.dart';
import 'screens/Admin/admin_screen.dart';
import './screens/verify_email_screen.dart';
import 'screens/user/forgot_password_screen.dart';
import './screens/Chef_Screen/Add-dish_screen.dart';
import './screens/profile_screen.dart';
import './screens/Admin/manage-category_screen.dart';
import './screens/Admin/manage-subcategory_screen.dart';
import './screens/user/show_dish_details.dart';
import './screens/change_password_screen.dart';
import './screens/user/help_faq_screen.dart';
import './screens/Admin/admin_booking_details.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: kIsWeb
        ? FirebaseOptions(
      apiKey: "AIzaSyBKB03rBU6KmX5Ex0RWuDvhsCPnpVb8gsI",
      authDomain: "homechefhub-f9445.firebaseapp.com",
      projectId: "homechefhub-f9445",
      storageBucket: "homechefhub-f9445.appspot.com",
      messagingSenderId: "1051995644878",
      appId: "1:1051995644878:web:bef4e022f8a904de59019f",
      measurementId: "G-PVJFZGQZ48",
      databaseURL: "https://homechefhub-f9445-default-rtdb.asia-southeast1.firebasedatabase.app",
    )
        : null,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => RegistrationScreen(),
        '/signin': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/chef-home': (context) => ChefHomeScreen(),
        '/Admin-dashboard': (context) => AdminScreen(),
        '/verify-email': (context) => VerifyEmailScreen(),
        '/forget-password': (context) =>  ForgotPasswordScreen(),
        '/add-dish': (context) =>  AddDishScreen(),
        '/profile': (context) =>  ProfileScreen(),
        // '/update-profile': (context) =>  ProfileUpdateScreen(),
        '/create-category': (context) =>  CategoryScreen(),
        '/create-sub_category': (context) =>  SubCategoryScreen(),
        '/manage-category': (context) =>  ManageCategoryScreen(),
        '/manage-sub_category': (context) =>  ManageSubCategoryScreen(),
        '/manage-user': (context) =>  AdminManageUserScreen(),
        '/manage-chef': (context) =>  AdminChefManageScreen(),
        '/show-dish-details': (context) => ShowDishDetailsScreen(subCategoryId: ''),
        '/change-password': (context) => ChangePasswordScreen(),
        '/manage-dishes': (context) => AdminShowAllDishes(),
        '/admin-booking-details': (context) => AdminBookingDetailsScreen(),


        '/HelpFaqScreen': (context) {
          // Ensure to get the user ID from FirebaseAuth
          final User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            return HelpFaqScreen(userId: user.uid); // Pass user ID here
          } else {
            return LoginScreen(); // Redirect to login if user is not authenticated
          }
        },

      },
    );
  }
}
class AuthStateHandler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData && snapshot.data!.emailVerified) {
          return HomeScreen(); // Redirect to home if logged in and email is verified
        }
        if (snapshot.hasData && !snapshot.data!.emailVerified) {
          return VerifyEmailScreen(); // Redirect to verification if email isn't verified
        }
        return LoginScreen(); // Redirect to login if not logged in
      },
    );
  }
}