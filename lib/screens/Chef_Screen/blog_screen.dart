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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').orderBy(
            'timestamp', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                  'No blogs available', style: TextStyle(color: Colors.grey)),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final blog = BlogModel.fromMap(
                  doc.data() as Map<String, dynamic>);

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        blog.blogTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        blog.blogContent,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                      SizedBox(height: 10),
                      blog.blogImageUrl != null
                          ? Image.network(
                        blog.blogImageUrl!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                          : SizedBox.shrink(),
                      SizedBox(height: 5),
                      Text(
                        'Posted on ${blog.timestamp.toLocal()}',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

}