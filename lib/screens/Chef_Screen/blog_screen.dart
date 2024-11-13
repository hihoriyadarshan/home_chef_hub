import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/blog_model.dart';

class BlogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Blogs'),
        backgroundColor: Colors.red,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            return ListView(
              children: snapshot.data!.docs.map((doc) {
                final blog = BlogModel.fromMap(doc.data() as Map<String, dynamic>);
                return BlogCard(blog: blog);
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

class BlogCard extends StatelessWidget {
  final BlogModel blog;
  BlogCard({required this.blog});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            blog.blogImageUrl != null
                ? Image.network(
              blog.blogImageUrl!,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            )
                : Container(
              height: 100,
              width: 100,
              color: Colors.grey[300],
              child: Icon(Icons.image, color: Colors.grey),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      blog.blogTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      blog.blogContent,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
