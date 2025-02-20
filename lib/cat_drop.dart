  import 'package:cashmate/appicons.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CatDrop extends StatelessWidget {
  final String? cattype;
  final ValueChanged<String?> onChanged;
  final String? initialCategory; // Add initialCategory parameter

  CatDrop({
    Key? key,
    required this.onChanged,
    this.cattype,
    this.initialCategory, // Update constructor
  }) : super(key: key);

  var appIcons = AppIcon();

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: cattype ?? initialCategory, // Use initialCategory if cattype is null
      isExpanded: true,
      hint: const Text("Select Category"),
      items: appIcons.homeExpense
          .map(
            (e) => DropdownMenuItem<String>(
              value: e["name"],
              child: Row(
                children: [
                  Icon(
                    e["icon"],
                    color: Colors.black,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    e["name"],
                    style: const TextStyle(color: Colors.black, fontSize: 15),
                  )
                ],
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
