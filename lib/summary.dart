import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class Transaction {
  final String id;
  final String userId;
  final String category;
  final double amount;

  Transaction({
    required this.id,
    required this.userId,
    required this.category,
    required this.amount,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      category: map['category'] ?? '',
      amount: (map['amoint'] ?? 0).toDouble(), // Ensure 'amount' is converted to double
    );
  }
}

class ExpenseSummaryPage extends StatefulWidget {
  @override
  _ExpenseSummaryPageState createState() => _ExpenseSummaryPageState();
}

class _ExpenseSummaryPageState extends State<ExpenseSummaryPage> {
  late Future<void> _userDataFuture;
  double totalDebit = 0.0; // Initialize as double
  double totalCredit = 0.0; // Initialize as double
  double balance = 0.0; // Initialize as double
  Map<String, double> categoryPercentages = {};
  final Map<String, Color> categoryColors = {
    "Home": Colors.blue,
    "Groceries": Colors.green,
    "Travel": Colors.orange,
    "Food": Colors.red,
    "Health": Colors.purple,
    "Personal Expenses": Colors.pink,
    "Entertainment": Colors.teal,
  };

  @override
  void initState() {
    super.initState();
    _userDataFuture = fetchUserData();
  }

  Future<void> fetchUserData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    final userQuery =
        FirebaseFirestore.instance.collection('users').where('userId', isEqualTo: userId);
    final userSnapshot = await userQuery.get();

    if (userSnapshot.docs.isNotEmpty) {
      final userData = userSnapshot.docs.first.data() as Map<String, dynamic>;
      setState(() {
        totalDebit = (userData['total_Debit'] ?? 0).toDouble(); // Convert to double
        totalCredit = (userData['total_Credit'] ?? 0).toDouble(); // Convert to double
        balance = totalCredit - totalDebit;
      });
    }

    final categories = ["Home", "Groceries", "Travel", "Food", "Health", "Personal Expenses", "Entertainment"];

    double totalExpenses = 0.0; // Initialize as double

    for (final category in categories) {
      final transactionQuery = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('category', isEqualTo: category);

      final transactionSnapshot = await transactionQuery.get();

      if (transactionSnapshot.docs.isNotEmpty) {
        final totalAmount = transactionSnapshot.docs
            .map((doc) => Transaction.fromMap(doc.data()).amount)
            .fold(0.0, (previousValue, element) => previousValue + element);
        totalExpenses += totalAmount;
      }
    }

    for (final category in categories) {
      final transactionQuery = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('category', isEqualTo: category);

      final transactionSnapshot = await transactionQuery.get();

      double totalAmount = 0.0; // Initialize as double

      if (transactionSnapshot.docs.isNotEmpty) {
        totalAmount = transactionSnapshot.docs
            .map((doc) => Transaction.fromMap(doc.data()).amount)
            .fold(0.0, (previousValue, element) => previousValue + element);

        double percentage = ((totalAmount / totalExpenses) * 100).toDouble(); // Convert to double
        categoryPercentages[category] = percentage;
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Expense Summary',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            if (categoryPercentages.isEmpty) {
              return Center(
                child: Text('No transactions found.'),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ...categoryPercentages.entries.map((entry) {
                          final category = entry.key;
                          final percentage = entry.value;
                          final color = Colors.blue;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    category,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Rs ${(totalDebit * (percentage / 100)).toStringAsFixed(2)}',
                                    style: TextStyle(color:color),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  Text(
                    'Expense Categories Breakdown',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Place the pie chart section
                          Container(
                            padding: EdgeInsets.all(16),
                            margin: EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: PieChart(
                                PieChartData(
                                  sections: categoryPercentages.entries.map((entry) {
                                    final category = entry.key;
                                    final percentage = entry.value;
                                    final color = categoryColors[category]!;
                                    return PieChartSectionData(
                                      color: color,
                                      value: percentage,
                                      title: '$category\n${percentage.toStringAsFixed(2)}%',
                                      titleStyle: TextStyle(color: Colors.white, fontSize:10 , fontWeight:FontWeight.bold),
                                      radius: 100,
                                    );
                                  }).toList(),
                                  centerSpaceRadius: 40,
                                  sectionsSpace: 0,
                                  startDegreeOffset: 0,
                                  centerSpaceColor: Colors.white,
                                  borderData: FlBorderData(show: false),
                                ),
                              ),
                            ),
                          ),
                          // Place the total expenditure, income, and balance section
                          Container(
                            padding: EdgeInsets.all(16),
                            margin: EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Total Expenditure: Rs ${totalDebit.toStringAsFixed(2)}',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Total Income: Rs ${totalCredit.toStringAsFixed(2)}',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Balance: Rs ${balance.toStringAsFixed(2)}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          // Place the expenditure and balance pie chart section
                          Container(
                            padding: EdgeInsets.all(16),
                            margin: EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: PieChart(
                                PieChartData(
                                  sections: [
                                    PieChartSectionData(
                                      color: Colors.red,
                                      value: totalDebit,
                                      title: 'Expenditure\n${(totalDebit / (totalDebit + balance) * 100).toStringAsFixed(2)}%',
                                      titleStyle: TextStyle(color: Colors.white, fontSize:11 , fontWeight:FontWeight.bold),
                                      radius: 100,
                                    ),
                                    PieChartSectionData(
                                      color: Colors.blue,
                                      value: balance,
                                      title: 'Balance\n${(balance / (totalDebit + balance) * 100).toStringAsFixed(2)}%',
                                      titleStyle: TextStyle(color: Colors.white, fontSize:11 , fontWeight:FontWeight.bold),
                                      radius: 100,
                                    ),
                                  ],
                                  centerSpaceRadius: 40,
                                  sectionsSpace: 0,
                                  startDegreeOffset: 0,
                                  centerSpaceColor: Colors.white,
                                  borderData: FlBorderData(show: false),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
