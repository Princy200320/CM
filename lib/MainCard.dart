import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainCard extends StatelessWidget {
  const MainCard({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Center(
        child: Text('User not authenticated'),);}
    final currentUserUID = currentUser.uid;
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: currentUserUID)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No data available for current user'),
          );
        }

        final userData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        final username = userData['username'] as String? ?? '';
        final totalBalance = (userData['remaining balance'] as num?)?.toDouble() ?? 0.0;
        final totalCredit = (userData['total_Credit'] as num?)?.toDouble() ?? 0.0;
        final totalDebit = (userData['total_Debit'] as num?)?.toDouble() ?? 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                " Welcome $username,",
                  style: const TextStyle(
                  fontSize: 20,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      "Total Balance",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text(
                      "Rs $totalBalance",
                      style: const TextStyle(
                        fontSize: 30,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomCard(color: Colors.red, heading: "Debit", amount: "Rs $totalDebit"),
                        CustomCard(color: Colors.green, heading: "Credit", amount: "Rs $totalCredit"),
                     
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class CustomCard extends StatelessWidget {
  const CustomCard({
    Key? key,
    required this.color,
    required this.heading,
    required this.amount,
  }) : super(key: key);

  final Color color;
  final String heading;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            amount,
            style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          
        ],
      ),
    );
  }
}
