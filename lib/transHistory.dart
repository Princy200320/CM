import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cashmate/trans.dart';

class TransHis extends StatelessWidget {
  final String? monthyear;
  final String? type;

  const TransHis({
    Key? key,
    this.monthyear,
    this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Center(child: Text("User not logged in"));
    }

    final currentUserUID = currentUser.uid;
    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUID)
        .collection('transactions')
        .where('monthyear', isEqualTo: monthyear)
        .where('type', isEqualTo: type)
        .orderBy("timestamp", descending: true)
        .limit(150); 

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No Transactions Found"));
        }

        // Calculate total amount
        double totalAmount = snapshot.data!.docs.fold(0.0, (previousValue, doc) {
          var data = doc.data() as Map<String, dynamic>;
          return previousValue + (data['amoint'] ?? 0.0);
        });

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Show total amount
              Container(
                padding: EdgeInsets.all(16.0),
                color: Colors.black,
                child: Text(
                  'Total $type: Rs${totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
              ),
              // List of transactions with spacing between them
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                separatorBuilder: (BuildContext context, int index) => SizedBox(height: 8.0), // Adjust the height as needed
                itemBuilder: (context, index) {
                  var cardData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  return TransCard(
                    title: cardData['title'],
                    amount: cardData['amoint'],
                    category: cardData['category'],
                    date: cardData['date'],
                    type: cardData['type'],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
