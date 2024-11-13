import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class BalanceScreen extends StatefulWidget {
  @override
  _BalanceScreenState createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  double balance = 0.0;

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

  void _showPaymentDialog() {
    final cardNumberController = TextEditingController();
    final cardHolderController = TextEditingController();
    final expiryDateController = TextEditingController();
    final cvvController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter Card Details"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Card Number"),
                      TextField(
                        controller: cardNumberController,
                        decoration: InputDecoration(hintText: "1234 5678 9012"),
                        keyboardType: TextInputType.number,
                        maxLength: 12,
                      ),
                      Text("Card Holder"),
                      TextField(
                        controller: cardHolderController,
                        decoration: InputDecoration(hintText: "Your Name"),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Expires On"),
                                TextField(
                                  controller: expiryDateController,
                                  decoration:
                                  InputDecoration(hintText: "MM/YY"),
                                  keyboardType: TextInputType.datetime,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("CVV"),
                                TextField(
                                  controller: cvvController,
                                  decoration: InputDecoration(hintText: "123"),
                                  keyboardType: TextInputType.number,
                                  maxLength: 3,
                                  obscureText: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Text("Amount"),
                      TextField(
                        controller: amountController,
                        decoration: InputDecoration(hintText: "Enter Amount"),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                final cardNumber = cardNumberController.text;
                final expiryDate = expiryDateController.text;
                final cvv = cvvController.text;

                if (cardNumber.length != 12) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Card number must be 12 digits")),
                  );
                  return;
                }

                if (cvv.length != 3) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("CVV must be 3 digits")),
                  );
                  return;
                }

                // Validate expiry date
                final currentDate = DateTime.now();
                final expiryParts = expiryDate.split('/');
                if (expiryParts.length == 2) {
                  final expiryMonth = int.tryParse(expiryParts[0]);
                  final expiryYear = int.tryParse('20' + expiryParts[1]);
                  if (expiryMonth == null ||
                      expiryYear == null ||
                      expiryMonth < 1 ||
                      expiryMonth > 12 ||
                      DateTime(expiryYear, expiryMonth).isBefore(currentDate)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Expiry date must be in the future")),
                    );
                    return;
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Invalid expiry date format")),
                  );
                  return;
                }

                if (amount != null && amount > 0) {
                  _addFunds(amount);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Funds added successfully!")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter a valid amount")),
                  );
                }
              },
              child: Text("Submit Payment"),
            ),
          ],
        );
      },
    );
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
            Text("Current Balance: \$${balance.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showPaymentDialog,
              child: Text("Add Funds with Card"),
            ),
          ],
        ),
      ),
    );
  }
}
