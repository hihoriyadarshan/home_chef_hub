import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  int userCount = 0;
  int chefCount = 0;
  int categoryCount = 0;
  int subcategoryCount = 0;
  int dishCount = 0;
  int bookingCount = 0;
  List<BarChartGroupData> barChartData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCounts();
  }

  /// Fetch real-time counts from Firebase Realtime Database
  Future<void> _fetchCounts() async {
    try {
      final usersSnapshot = await _databaseRef.child('users').once();
      // final chefsSnapshot = await _databaseRef.child('chefs').once();
      final categoriesSnapshot = await _databaseRef.child('categories').once();
      final subcategoriesSnapshot = await _databaseRef.child('subcategories').once();
      final dishesSnapshot = await _databaseRef.child('dishes').once();
      final bookingsSnapshot = await _databaseRef.child('bookings').once();

      setState(() {
        userCount = usersSnapshot.snapshot.children.length;
        // chefCount = chefsSnapshot.snapshot.children.length;
        categoryCount = categoriesSnapshot.snapshot.children.length;
        subcategoryCount = subcategoriesSnapshot.snapshot.children.length;
        dishCount = dishesSnapshot.snapshot.children.length;
        bookingCount = bookingsSnapshot.snapshot.children.length;
        _isLoading = false;
        _generateBarChartData();
      });
    } catch (e) {
      print('Error fetching counts: $e');
    }
  }

  /// Generate bar chart data based on the fetched counts
  void _generateBarChartData() {
    barChartData = [
      _buildBarChartGroupData(0, userCount.toDouble(), Colors.blue),
      // _buildBarChartGroupData(1, chefCount.toDouble(), Colors.green),
      _buildBarChartGroupData(2, categoryCount.toDouble(), Colors.orange),
      _buildBarChartGroupData(3, subcategoryCount.toDouble(), Colors.purple),
      _buildBarChartGroupData(4, dishCount.toDouble(), Colors.red),
      _buildBarChartGroupData(5, bookingCount.toDouble(), Colors.teal),
    ];
  }

  BarChartGroupData _buildBarChartGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 15,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Analytics Dashboard"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HomeChefHub Analytics',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCountCard('Total Users', userCount, Colors.blue),
                // _buildCountCard('Chefs', chefCount, Colors.green),
                _buildCountCard('Categories', categoryCount, Colors.orange),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCountCard('Subcategories', subcategoryCount, Colors.purple),
                _buildCountCard('Dishes', dishCount, Colors.red),
                _buildCountCard('Bookings', bookingCount, Colors.teal),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Data Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: barChartData.map((data) => data.barRods.first.toY).reduce((a, b) => a > b ? a : b) + 5,
                  barGroups: barChartData,
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const titles = [
                            'Users',
                            'Chefs',
                            'Categories',
                            'Subcategories',
                            'Dishes',
                            'Bookings'
                          ];
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(titles[value.toInt()]),
                          );
                        },
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

  /// Widget to build individual count cards
  Widget _buildCountCard(String title, int count, Color color) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count.toString(),
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 16, color: color),
          ),
        ],
      ),
    );
  }
}
