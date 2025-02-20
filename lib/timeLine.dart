import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class timeLine extends StatefulWidget {
  final Function(String) onChanged; // Callback function to pass selected month

  const timeLine({Key? key, required this.onChanged}) : super(key: key);

  @override
  State<timeLine> createState() => _timeLineState();
}

class _timeLineState extends State<timeLine> {
  String currentMonth = "";
  List<String> months = [];
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    DateTime now = DateTime.now();
for (int i = 0; i >= -18; i--) {
  months.add(DateFormat("MMM y").format(DateTime(now.year, now.month + i, 1)));
}
currentMonth = DateFormat('MMM y').format(now);

    currentMonth = DateFormat('MMM y').format(now);
  }

  void scrollToSelectedMonth() {
    var selectedMonthIndex = months.indexOf(currentMonth);
    if (selectedMonthIndex != -1) {
      var scrollOffset = (selectedMonthIndex * 100.0) - 170;
      scrollController.animateTo(scrollOffset, duration: Duration(milliseconds: 500), curve: Curves.ease);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      child: ListView.builder(
        controller: scrollController, // Attach the ScrollController here
        itemCount: months.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                currentMonth = months[index];
              });
              // Call the callback function with selected month
              widget.onChanged(currentMonth);
              scrollToSelectedMonth();
            },
            child: Container(
              width: 80,
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: currentMonth == months[index] ? Colors.blue.shade900 : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  months[index],
                  style: TextStyle(color: currentMonth == months[index] ? Colors.white : Colors.purple),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
