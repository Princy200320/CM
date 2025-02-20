import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cashmate/timeLine.dart';
import 'package:cashmate/typeTab.dart';

class Transactionss extends StatefulWidget {
  const Transactionss({Key? key}) : super(key: key);

  @override
  State<Transactionss> createState() => _TransactionssState();
}

class _TransactionssState extends State<Transactionss> {
  String monthyear = "";
  

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    setState(() {
      monthyear = DateFormat('MMM y').format(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Transaction List',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              timeLine(
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      monthyear = value; // Update selected month
                      print(monthyear);
                    });
                  }
                },
                
              ),
             
              TypeTab( monthyear: monthyear), // Pass selected month to TypeTab
            ],
          ),
        ),
      ),
    );
  }



}

