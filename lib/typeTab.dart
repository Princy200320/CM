import 'package:flutter/material.dart';
import 'package:cashmate/transHistory.dart';

class TypeTab extends StatelessWidget {
  const TypeTab({Key? key, required this.monthyear}) : super(key: key);
  
  final monthyear;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: "Credit"),
                Tab(text: "Debit"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  TransHis(
                    monthyear: monthyear,
                    type: 'credit', // Pass 'credit' type for credit transactions
                  ),
                  TransHis(
                    monthyear: monthyear,
                    type: 'debit', // Pass 'debit' type for debit transactions
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
