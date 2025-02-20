import 'package:cashmate/appicons.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ReTransCard extends StatelessWidget {
  const ReTransCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appIcons = AppIcon();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // User is not authenticated, handle accordingly
      return Center(
        child: Text('User is not authenticated'),
      );
    }

    final currentUserUID = currentUser.uid; // Use currentUserUID to access the current user's UID

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUID)
          .collection('transactions')
          .orderBy('timestamp', descending: true) // Order by timestamp in descending order
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final List<DocumentSnapshot> documents = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: documents.length > 5 ? 5 : documents.length, // Adjust the itemCount based on the length of documents
          itemBuilder: (context, index) {
            final transactionSnapshot = documents[index];
            // Extract data from transactionSnapshot
            String title = transactionSnapshot['title'];
            double amount = transactionSnapshot['amoint'];
             double rem = transactionSnapshot['remaining balance'];
            String category = transactionSnapshot['category'];
            String date = transactionSnapshot['date'];
            String type = transactionSnapshot['type'];

            // Determine the text color based on the type
            Color textColor = type == 'credit' ? Colors.green : Colors.red;

            // Determine the icon based on the category
            IconData iconData;
            if (category == 'Home') {
              iconData = appIcons.getExpenseCategoryIcon('Home');
            } else if (category == 'Groceries') {
              iconData = appIcons.getExpenseCategoryIcon('Groceries');
            } else if (category == 'Travel') {
              iconData = appIcons.getExpenseCategoryIcon('Travel');
            } else if (category == 'Food') {
              iconData = appIcons.getExpenseCategoryIcon('Food');
            } else if (category == 'Health') {
              iconData = appIcons.getExpenseCategoryIcon('Health');
            } else if (category == 'Personal Expenses') {
              iconData = appIcons.getExpenseCategoryIcon('Personal Expenses');
            } else if (category == 'Entertainment') {
              iconData = appIcons.getExpenseCategoryIcon('Entertainment');
            } else if (category == 'Credit') {
              iconData = appIcons.getExpenseCategoryIcon('Credit');
            } else {
              iconData = appIcons.getExpenseCategoryIcon('Default'); // Default icon
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 10),
                      color: Colors.grey.withOpacity(0.9),
                      blurRadius: 10.0,
                    )
                  ],
                ),
                child: ListTile(
                  minVerticalPadding: 4,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0.0),
                  leading: SizedBox(
                    width: 70,
                    height: 100,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.blue.withOpacity(0.3),
                      ),
                      child: Center(
                        child: Icon(iconData), // Use the determined icon
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(child: Text(title)),
                      Text(
                        "Rs $amount ",
                        style: TextStyle(color: textColor),
                      )
                    ],
                  ),
                  subtitle: Column(
  mainAxisAlignment: MainAxisAlignment.start,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      children: [
        Text("$category", style: TextStyle(color: Colors.grey, fontSize: 11)),
        Spacer(),
        Text("$date", style: TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    ),
    SizedBox(height: 4), // Add some space between category/date and total balance
    Text(
      "Balance: Rs $rem",
      style: TextStyle(color: Colors.grey, fontSize: 11),
      
    ),
    
  ],
),

                ),
              ),
            );
          },
        );
      },
    );
  }
}
