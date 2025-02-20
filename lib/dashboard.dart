
import 'package:cashmate/Goalspage.dart';
import 'package:cashmate/home.dart';
import 'package:cashmate/summary.dart';
import 'package:cashmate/transactions.dart';
import 'package:cashmate/nav.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var isLoad = false;
  int currentIndex =0;
  var pagesList=[const Home(),const Transactionss(),ExpenseSummaryPage(), GoalPage()];

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Nav(
        Vselected:currentIndex,
        onDestinationSelected: (int value){
          setState((){
            currentIndex= value;

          }); },
    ),
     
      body: pagesList[currentIndex],
    );
  }
}
