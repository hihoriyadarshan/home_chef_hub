import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _errorMessage;

  bool _isDarkMode = false; // Toggle for dark mode

  // Method to change the password
  Future<void> _changePassword() async {
    if (_validateInputs()) {
      try {
        // Get the current user
        User? user = _auth.currentUser;
        String email = user!.email!;

        // Reauthenticate user
        AuthCredential credential = EmailAuthProvider.credential(
          email: email,
          password: _currentPasswordController.text,
        );

        await user.reauthenticateWithCredential(credential);
        // Change password
        await user.updatePassword(_newPasswordController.text);
        _showMessage('Password changed successfully.'); // Show success message
        Navigator.pop(context); // Go back to the previous screen
      } catch (e) {
        _showMessage('Error: ${e.toString()}'); // Show error message
      }
    }
  }

  // Validate the input fields
  bool _validateInputs() {
    setState(() {
      _errorMessage = null; // Reset error message
    });

    if (_currentPasswordController.text.isEmpty) {
      _errorMessage = 'Current password is required.';
      _showMessage(_errorMessage!);
      return false;
    }
    if (_newPasswordController.text.isEmpty) {
      _errorMessage = 'New password is required.';
      _showMessage(_errorMessage!);
      return false;
    }
    if (_newPasswordController.text.length < 6) {
      _errorMessage = 'New password must be at least 6 characters.';
      _showMessage(_errorMessage!);
      return false;
    }
    if (_confirmPasswordController.text.isEmpty) {
      _errorMessage = 'Confirm password is required.';
      _showMessage(_errorMessage!);
      return false;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _errorMessage = 'New password and confirmation do not match.';
      _showMessage(_errorMessage!);
      return false;
    }
    return true; // All validations passed
  }

  // Method to show notifications
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Toggle dark mode
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Change Password'),
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
              onPressed: _toggleTheme,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView( // Allows for scrolling on smaller screens
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _currentPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    errorText: _errorMessage,
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200], // Background color
                    hintStyle: TextStyle(color: Colors.grey[500]), // Hint text color
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    errorText: _errorMessage,
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200], // Background color
                    hintStyle: TextStyle(color: Colors.grey[500]), // Hint text color
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    errorText: _errorMessage,
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200], // Background color
                    hintStyle: TextStyle(color: Colors.grey[500]), // Hint text color
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _changePassword,
                  child: Text('Change Password'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.0), // Button padding
                    textStyle: TextStyle(fontSize: 16), // Button text style
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
