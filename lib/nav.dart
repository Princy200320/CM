import 'package:flutter/material.dart';

class Nav extends StatelessWidget {
  const Nav({
    Key? key, // Fix: Use Key? key instead of super.key
    required this.Vselected,
    required this.onDestinationSelected,
  }) : super(key: key);

  final int Vselected;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: Vselected,
      onDestinationSelected: onDestinationSelected,
      indicatorColor: Colors.grey,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      height: 60,
      destinations: const <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.home,color: Colors.black),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.description, color: Colors.black),
          label: 'Report',
        ),
        NavigationDestination(
          icon: Icon(Icons.pie_chart,color: Colors.black),
          label: 'Summary',
        ),
        NavigationDestination(
          icon: Icon(Icons.emoji_events,color: Colors.black),
          label: 'Goals',
        ),
      ],
    );
  }
}
