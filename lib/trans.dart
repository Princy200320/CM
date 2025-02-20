import 'package:flutter/material.dart';

class TransCard extends StatelessWidget {
  final String title;
  final double amount;
  final String category;
  final String date;
  final String type;

  const TransCard({
    Key? key,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Build your TransCard UI using the provided parameters
    return Container(
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
              child: Icon(Icons.account_balance_wallet), // Placeholder icon
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(child: Text(title)),
            Text(
              "Rs $amount ",
              style: TextStyle(color: type == 'credit' ? Colors.green : Colors.red),
            )
          ],
        ),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("$category", style: TextStyle(color: Colors.grey, fontSize: 13)),
                Spacer(),
                Text("$date", style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}