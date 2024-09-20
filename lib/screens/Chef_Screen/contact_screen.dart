import 'package:flutter/material.dart';

class ContactScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us'),
      ),
      body: Center(
        child: Text(
          'This is the Contact Section',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
