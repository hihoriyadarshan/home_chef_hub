import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import './screens/WelcomeScreen.dart';
import './screens/login_screen.dart';
import './screens/registration_screen.dart';
import './screens/home_screen.dart';
import './screens/chef_screen.dart';
import './screens/admin_screen.dart';
import './screens/verify_email_screen.dart';


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
        '/chef': (context) => ChefScreen(),
        '/Admin': (context) => AdminScreen(),
        '/verify-email': (context) => VerifyEmailScreen(),


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