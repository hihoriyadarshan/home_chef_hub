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

  // Page controller for the promotional image slider
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Images for the slider from assets
  final List<String> _sliderImages = [
    'assets/slicer1.png',
    'assets/slicer2.png',
    'assets/slicer3.png',
  ];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    Future.delayed(Duration(seconds: 3), _autoSlide);

    // Add listener to update the search result when user types
    _searchController.addListener(_filterCategories);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Auto-slide the promotional slider every 3 seconds
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
              .map((value) =>
              CategoryModel.fromMap(Map<String, dynamic>.from(value)))
              .toList();
          _filteredCategories = _categories; // Initialize the filtered list
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

  // Filter categories based on search input
  void _filterCategories() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = _categories;
      } else {
        _filteredCategories = _categories
            .where((category) =>
            category.category.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _viewMoreCategories() {
    setState(() {
      _displayedCategories += 6;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Chef HUB',
          style: TextStyle(
          fontSize: 30,
          color: Colors.white,
        ),
        ),
        backgroundColor: Color(0xFFD32F2F),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(8),
          child: Padding(
            padding: const EdgeInsets.all(0),

          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red,
              ),
              child: Text(
                'HCF',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.category),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help & FAQ'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(
                  context,
                  '/HelpFaqScreen',
                  arguments: 'YourUserIdHere', // Pass the actual userId here
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.password),
              title: Text('Change Password'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/change-password');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
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
            // Food Category Slider using asset images
            Container(
              height: 300, // Height increased for larger visibility
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
            // Category Grid Section
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _isError
                ? Center(
              child: Text(
                'Error loading categories',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            )
                : _filteredCategories.isEmpty
                ? Center(
              child: Text(
                'No categories available',
                style: TextStyle(fontSize: 18),
              ),
            )
                : GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(10),
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isWideScreen ? 3 : 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3 / 2,
              ),
              itemCount: _displayedCategories >
                  _filteredCategories.length
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
                  onPressed: _viewMoreCategories,
                  child: Text('View More'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  ),
                ),
              ),
            SizedBox(height: 30),

            // Chef Cooking at Home Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chef Cooking at Home',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      // Chef Cooking Image from assets
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              // image: AssetImage('assets/chef_cooking.png'),
                              image: AssetImage('assets/chef_cooking.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      // Chef Cooking Description
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Experience the Art of Cooking',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Bring the magic of a professional chef to your kitchen. '
                                  'Our chefs prepare delicious meals that you can enjoy in the comfort of your home. '
                                  'From traditional dishes to modern cuisine, experience the joy of home-cooked meals without the hassle.',
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // New Section for Featured Chefs
                  Text(
                    'Featured Chefs',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 150, // For horizontal scrolling
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5, // Example count
                      itemBuilder: (context, index) {
                        return Container(
                          width: 120,
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey[200],
                            image: DecorationImage(
                              image: AssetImage('assets/chef${index + 1}.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Chef ${index + 1}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  backgroundColor: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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

class HoverCard extends StatefulWidget {
  final CategoryModel category;
  const HoverCard({required this.category});

  @override
  _HoverCardState createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovered = false;

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailsScreen(
              categoryId: widget.category.cid,
              categoryName: widget.category.category,
            ),
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: Stack(
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Image.network(
                      widget.category.categoryPhotoUrl ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      widget.category.category,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            if (_isHovered)
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: _isHovered ? 0.5 : 1.0,
                  duration: Duration(milliseconds: 300),
                  child: Container(
                    color: Colors.black,
                    child: Center(
                      child: Text(
                        widget.category.category,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
