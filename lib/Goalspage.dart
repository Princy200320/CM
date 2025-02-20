import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Goal {
  String id;
  String name;
  double amount;
  double currentAmount;

  Goal({
    required this.id,
    required this.name,
    required this.amount,
    this.currentAmount = 0.0,
  });
}

class GoalPage extends StatefulWidget {
  @override
  _GoalPageState createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  List<Goal> goals = [];

  TextEditingController _goalController = TextEditingController();
  TextEditingController _goalNameController = TextEditingController();
  TextEditingController _currentAmountController = TextEditingController();

  String? goalNameError;
  String? goalAmountError;

  @override
  void initState() {
    super.initState();
    _fetchGoals();
  }

  Future<void> _fetchGoals() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('goals')
            .get();
        setState(() {
          goals = querySnapshot.docs.map((doc) => Goal(
            id: doc.id,
            name: doc['name'],
            amount: doc['amount'],
            currentAmount: doc['currentAmount'],
          )).toList();
        });
      }
    } catch (e) {
      print('Error fetching goals: $e');
    }
  }

  Future<void> _showAddGoalDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Set Goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _goalNameController,
                decoration: InputDecoration(
                  labelText: 'Enter Goal Name',
                  errorText: goalNameError,
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _goalController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Enter Goal Amount',
                  errorText: goalAmountError,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  goalNameError = _goalNameController.text.isEmpty ? 'Please enter goal name' : null;
                  goalAmountError = _goalController.text.isEmpty ? 'Please enter goal amount' : null;
                });
                if (goalNameError == null && goalAmountError == null) {
                  _addGoal();
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                _goalController.clear();
                _goalNameController.clear();
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addGoal() async {
    String name = _goalNameController.text;
    double amount = double.tryParse(_goalController.text) ?? 0.0;

    if (name.isEmpty) {
      setState(() {
        goalNameError = 'Please enter goal name';
      });
      return;
    } else {
      setState(() {
        goalNameError = null;
      });
    }

    if (_goalController.text.isEmpty) {
      setState(() {
        goalAmountError = 'Please enter goal amount';
      });
      return;
    } else {
      setState(() {
        goalAmountError = null;
      });
    }

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('goals')
            .add({
          'name': name,
          'amount': amount,
          'currentAmount': 0.0,
        });

        setState(() {
          goals.add(Goal(
            id: docRef.id,
            name: name,
            amount: amount,
          ));
        });

        _goalController.clear();
        _goalNameController.clear();
      } catch (e) {
        print('Error adding goal: $e');
      }
    }
  }

  Future<void> _updateCurrentAmount(Goal goal, double newAmount) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('goals')
            .doc(goal.id)
            .update({'currentAmount': newAmount});
        setState(() {
          goal.currentAmount = newAmount;
        });
      } catch (e) {
        print('Error updating current amount: $e');
      }
    }
  }

  Future<void> _deleteGoal(Goal goal) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('goals')
            .doc(goal.id)
            .delete();

        setState(() {
          goals.remove(goal);
        });
      } catch (e) {
        print('Error deleting goal: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Set Your Goals',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  return _buildGoalCard(goals[index]);
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _showAddGoalDialog(context);
              },
              child: Text('Add Goal', style: TextStyle(color: Colors.white)),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(Goal goal) {
    double progressPercent = (goal.currentAmount / goal.amount).clamp(0.0, 1.0);

    if (progressPercent >= 1.0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGoalCompletedDialog(context, goal);
      });
    }

    return Card(
      color: Colors.yellow,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Goal: ${goal.name}',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 16.0),
            LinearPercentIndicator(
              animation: true,
              lineHeight: 20.0,
              animationDuration: 1000,
              percent: progressPercent,
              center: Text('${(progressPercent * 100).toStringAsFixed(1)}%', style: TextStyle(color: Colors.black)),
              linearStrokeCap: LinearStrokeCap.roundAll,
              progressColor: Colors.green,
            ),
            SizedBox(height: 16.0),
            Text(
              'Goal Amount: ${goal.amount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18.0, color: Colors.black),
            ),
            SizedBox(height: 16.0),
            Text(
              'Current Amount: ${goal.currentAmount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18.0, color: Colors.black),
            ),
            SizedBox(height: 16.0),
            Text(
              'Remaining Amount: ${(goal.amount - goal.currentAmount).toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18.0, color: Colors.black),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showUpdateAmountDialog(context, goal);
                  },
                  child: Text('Update Amount', style: TextStyle(color: Colors.white)),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _confirmDeleteGoal(context, goal);
                  },
                  child: Text('Delete Goal', style: TextStyle(color: Colors.red)),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showUpdateAmountDialog(BuildContext context, Goal goal) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _currentAmountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Enter Amount to Add'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                double amountToAdd = double.tryParse(_currentAmountController.text) ?? 0.0;
                double newAmount = goal.currentAmount + amountToAdd;
                _updateCurrentAmount(goal, newAmount);
                Navigator.pop(context);
              },
              child: Text('Update', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                _currentAmountController.clear();
                Navigator.pop(context);
              },
              child: Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeleteGoal(BuildContext context, Goal goal) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete the goal: ${goal.name}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                _deleteGoal(goal);
                Navigator.pop(context);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showGoalCompletedDialog(BuildContext context, Goal goal) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Goal Completed'),
          content: Text('Congratulations! You have completed your goal: ${goal.name}'),
          actions: [
            TextButton(
              onPressed: () {
                _deleteGoal(goal);
                Navigator.pop(context);
              },
              child: Text('OK', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }
}
