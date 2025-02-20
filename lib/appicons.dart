import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppIcon {
  final List<Map<String, dynamic>> homeExpense = [
    {"name": "Home", "icon": FontAwesomeIcons.house},
    {"name": "Groceries", "icon": FontAwesomeIcons.cartShopping},
    {"name": "Travel", "icon": FontAwesomeIcons.plane},
    {"name": "Food", "icon": FontAwesomeIcons.utensils},
    {"name": "Health", "icon": FontAwesomeIcons.medkit},
    {"name": "Personal Expenses", "icon": FontAwesomeIcons.personArrowUpFromLine},
    {"name": "Entertainment", "icon": FontAwesomeIcons.film},
    {"name": "Credit", "icon": FontAwesomeIcons.moneyBill},
  ];

  IconData getExpenseCategoryIcon(String categoryName) {
    final category = homeExpense.firstWhere(
      (category) => category['name'] == categoryName,
      orElse: () => {"name": "Default", "icon": FontAwesomeIcons.houseMedical},
    );
    return category['icon'];
  }
}