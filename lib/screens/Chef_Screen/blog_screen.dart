import 'package:flutter/material.dart';

class BlogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blog'),
      ),
      body: Center(
        child: Text(
          'This is the Blog Section',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
