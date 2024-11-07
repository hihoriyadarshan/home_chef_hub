import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:home_chef_hub/screens/user/help_faq_screen.dart';
import '../../models/category_model.dart';
import 'category_details_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  List<CategoryModel> _categories = [];
  List<CategoryModel> _filteredCategories = [];
  bool _isLoading = true;
  bool _isError = false;
  int _displayedCategories = 6;
  final TextEditingController _searchController = TextEditingController();

  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _sliderImages = [
    'assets/slicer1.png',
    'assets/slicer2.png',
    'assets/slicer3.png',
  ];

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    Future.delayed(Duration(seconds: 3), _autoSlide);

    _searchController.addListener(_filterCategories);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _autoSlide() {
    if (_currentPage < _sliderImages.length - 1) {
      _currentPage++;
    } else {
      _currentPage = 0;
    }
    _pageController.animateToPage(
      _currentPage,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
    Future.delayed(Duration(seconds: 3), _autoSlide);
  }

  Future<void> _fetchCategories() async {
    try {
      final snapshot = await _database.ref().child('categories').once();
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        setState(() {
          _categories = data.values
              .map((value) => CategoryModel.fromMap(Map<String, dynamic>.from(value)))
              .toList();
          _filteredCategories = _categories;
        });
      } else {
        setState(() {
          _categories = [];
        });
      }
    } catch (error) {
      setState(() {
        _isError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterCategories() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = _categories;
      } else {
        _filteredCategories = _categories
            .where((category) => category.category.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _viewMoreCategories() {
    setState(() {
      _displayedCategories += 6;
    });
  }

  Future<void> _submitContactForm() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final message = _messageController.text.trim();

    if (name.isEmpty || email.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields')),
      );
      return;
    }

    try {
      await _database.ref().child('contacts').push().set({
        'name': name,
        'email': email,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thank you for contacting us!')),
      );

      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting form. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home Chef Hub',
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
        backgroundColor: Color(0xFFD32F2F),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFD32F2F)),
              child: Text(
                'Home Chef Hub',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.red),
              title: Text('Home', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.account_box, color: Colors.red),
              title: Text('Profile', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: Icon(Icons.help, color: Colors.red),
              title: Text('Help & FAQ', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/HelpFaqScreen');
              },
            ),
            ListTile(
              leading: Icon(Icons.wallet_outlined, color: Colors.red),
              title: Text('Add Funds', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/balance');
              },
            ),
            ListTile(
              leading: Icon(Icons.account_balance_rounded, color: Colors.red),
              title: Text('My Booking', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/mybooking');
              },
            ),
            ListTile(
              leading: Icon(Icons.account_box_outlined, color: Colors.red),
              title: Text('Logout', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Slider section
            Container(
              height: 300,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _sliderImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: AssetImage(_sliderImages[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 30),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _isError
                ? Center(child: Text('Error loading categories'))
                : _filteredCategories.isEmpty
                ? Center(child: Text('No categories available'))
                : GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isWideScreen ? 3 : 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3 / 2,
              ),
              itemCount: _displayedCategories > _filteredCategories.length
                  ? _filteredCategories.length
                  : _displayedCategories,
              itemBuilder: (context, index) {
                final category = _filteredCategories[index];
                return HoverCard(category: category);
              },
            ),
            if (_displayedCategories < _filteredCategories.length)
              Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFD32F2F),
                  ),
                  onPressed: _viewMoreCategories,
                  child: Text('View More', style: TextStyle(color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class HoverCard extends StatelessWidget {
  final CategoryModel category;
  const HoverCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryDetailsScreen(
                categoryId: category.cid,
                categoryName: category.category,
              ),
            ),
          );
        },
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: <Widget>[
          Expanded(
          child: Image.network(
          category.categoryPhotoUrl ?? '',
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        ),
        Container(
        padding: EdgeInsets.all(8),
    child: Text(
    category.category,
    style: TextStyle(fontSize: 16, color: Colors.black),
    ),
        ),
    ],
    ),
    ),
    );
  }
}
