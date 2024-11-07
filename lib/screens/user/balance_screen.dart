import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BalanceScreen extends StatefulWidget {
  @override
  _BalanceScreenState createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  double balance = 0.0;
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBalance();
  }

  Future<void> _fetchBalance() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userRef = FirebaseDatabase.instance.ref('users/$userId/balance');
    final snapshot = await userRef.get();

    setState(() {
      balance = snapshot.exists ? double.parse(snapshot.value.toString()) : 0.0;
    });
  }

  Future<void> _addFunds(double amount) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userRef = FirebaseDatabase.instance.ref('users/$userId/balance');
    await userRef.set(balance + amount);
    _fetchBalance();
  }

  void _mockPayment() {
    final amount = double.tryParse(_amountController.text);
    if (amount != null && amount > 0) {
      _addFunds(amount);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Funds added successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Balance")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Current Balance: \$${balance.toStringAsFixed(2)}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text("Mock Payment", style: TextStyle(fontSize: 16)),
            TextField(controller: _amountController, decoration: InputDecoration(labelText: "Amount")),
            ElevatedButton(onPressed: _mockPayment, child: Text("Add Funds"))
          ],
        ),
      ),
    );
  }
}
