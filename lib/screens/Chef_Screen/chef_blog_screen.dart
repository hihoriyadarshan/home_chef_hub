import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../models/blog_model.dart';

class ChefBlogScreen extends StatefulWidget {
  final String userId;
  ChefBlogScreen({required this.userId});

  @override
  _ChefBlogScreenState createState() => _ChefBlogScreenState();
}

class _ChefBlogScreenState extends State<ChefBlogScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  Uint8List? _selectedImageBytes;
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
      });
    }
  }

  Future<String?> _uploadImage(Uint8List imageBytes) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('blog_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putData(imageBytes);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _addBlog() async {
    if (!_formKey.currentState!.validate()) return;

    String? imageUrl;
    if (_selectedImageBytes != null) {
      imageUrl = await _uploadImage(_selectedImageBytes!);
    }

    final blog = BlogModel(
      userId: widget.userId,
      blogTitle: _titleController.text,
      blogContent: _contentController.text,
      blogImageUrl: imageUrl,
      timestamp: DateTime.now(),
    );

    try {
      await FirebaseFirestore.instance.collection('blogs').add(blog.toMap());
      _clearForm(); // Clear form after successful blog creation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have successfully published'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create blog: $e')),
      );
    }
  }

  void _clearForm() {
    _titleController.clear();
    _contentController.clear();
    setState(() {
      _selectedImageBytes = null;
    });
  }

  Future<void> _updateBlog(String blogId) async {
    if (!_formKey.currentState!.validate()) return;

    String? imageUrl;
    if (_selectedImageBytes != null) {
      imageUrl = await _uploadImage(_selectedImageBytes!);
    }

    try {
      await FirebaseFirestore.instance.collection('blogs').doc(blogId).update({
        'blogTitle': _titleController.text,
        'blogContent': _contentController.text,
        'blogImageUrl': imageUrl ?? '',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Blog updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update blog: $e')),
      );
    }
  }

  Future<void> _deleteBlog(String blogId) async {
    try {
      await FirebaseFirestore.instance.collection('blogs').doc(blogId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Blog deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete blog: $e')),
      );
    }
  }

  void _confirmDelete(String blogId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Blog'),
        content: Text('Are you sure you want to delete this blog?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteBlog(blogId);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chef Blog'),
        backgroundColor: Colors.red,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Blog Title',
                  labelStyle: TextStyle(color: Colors.red),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a blog title' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Content',
                  alignLabelWithHint: true,
                  labelStyle: TextStyle(color: Colors.red),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter blog content' : null,
              ),
              SizedBox(height: 10),
              _selectedImageBytes != null
                  ? Image.memory(_selectedImageBytes!, height: 150)
                  : ElevatedButton(
                onPressed: _pickImage,
                child: Text('Upload Image', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _addBlog,
                child: Text('Add Blog', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
              SizedBox(height: 10),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('blogs')
                      .where('userId', isEqualTo: widget.userId)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                    return ListView(
                      children: snapshot.data!.docs.map((doc) {
                        final blog = BlogModel.fromMap(doc.data() as Map<String, dynamic>);
                        return Card(
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
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            blog.blogTitle,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                              fontSize: 16,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _confirmDelete(doc.id),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        blog.blogContent,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
