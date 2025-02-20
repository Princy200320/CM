import 'package:cashmate/MainCard.dart';
import 'package:cashmate/dashboard.dart';
import 'package:cashmate/home.dart';
import 'package:flutter/material.dart';
import 'package:cashmate/cat_drop.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart'; // Import this library for TextInputFormatter

class Transaction {
  String title;
  double amount;
  String category;
  String type;

  Transaction({
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
  });
}

class AddTrans extends StatefulWidget {
  const AddTrans({Key? key}) : super(key: key);

  @override
  State<AddTrans> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTrans> {
  String? _emptyCheck(value) {
    if (value!.isEmpty) {
      return "Please fill details";
    }
    return null;
  }

  String? _amountCheck(value) {
    if (value!.isEmpty) {
      return "Please enter amount";
    }
    if (double.tryParse(value) == null) {
      return "Please enter valid number";
    }
    return null;
  }

  var type = "credit";
  String? category;
  var isLoader = false;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  var uid = Uuid();

  List<Transaction> transactions = [];

  Future<void> _submitForm() async {
    if (_formkey.currentState!.validate()) {
      if (category == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a category')),
        );
        return;
      }

      setState(() {
        isLoader = true;
      });

      final user = FirebaseAuth.instance.currentUser;

      final userDocs = await FirebaseFirestore.instance
          .collection("users")
          .where('userId', isEqualTo: user!.uid)
          .get();

      if (userDocs.docs.isNotEmpty) {
        final userDoc = userDocs.docs.first;
        double totalBalance =
            (userDoc['remaining balance'] as num?)?.toDouble() ?? 0.0;
        double totalCredit =
            (userDoc['total_Credit'] as num?)?.toDouble() ?? 0.0;
        double totalDebit =
            (userDoc['total_Debit'] as num?)?.toDouble() ?? 0.0;

        var amount = double.parse(_amountController.text);

        if (type == "credit") {
          totalBalance += amount;
          totalCredit += amount;
        } else if (type == "debit") {
          // Check if total balance will be negative after deducting the amount
          if (totalBalance - amount < 0) {
            // Display a SnackBar indicating insufficient balance
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Insufficient balance')),
            );
            setState(() {
              isLoader = false;
            });
            return; // Exit the function without updating Firebase or adding the transaction
          }
          totalBalance -= amount;
          totalDebit += amount;
        }

        await userDoc.reference.update({
          "remaining balance": totalBalance,
          "total_Credit": totalCredit,
          "total_Debit": totalDebit,
          "updatedAt": FieldValue.serverTimestamp(),
        });

        var id = uid.v4();
        var timestamp = DateTime.now().microsecondsSinceEpoch;
        DateTime data = DateTime.now();
        String monthyear = DateFormat("MMM y").format(data);
        String date = DateFormat('dd MMMM yyyy').format(data);

        var data1 = {
          "userId": FirebaseAuth.instance.currentUser?.uid ?? "",
          "id": id,
          "title": _titleController.text,
          "amoint": amount,
          "type": type,
          "timestamp": timestamp,
          "total_Credit": totalCredit,
          "total_Debit": totalDebit,
          "remaining balance": totalBalance,
          "monthyear": monthyear,
          "category": category,
          "date": date,
        };
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .collection("transactions")
            .doc(id)
            .set(data1);

        // Refresh the page after adding the transaction
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Dashboard()),
        );
      }

      setState(() {
        isLoader = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formkey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              validator: _emptyCheck,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextFormField(
              controller: _amountController,
              validator: _amountCheck, // Add validator
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Only allow digits
              decoration: const InputDecoration(labelText: "Amount"),
            ),
            // Assuming you have a widget called CatDrop for category selection
            CatDrop(
              initialCategory: category,
              onChanged: (value) {
                setState(() {
                  category = value;
                });
              },
            ),
            DropdownButtonFormField<String>(
              value: 'credit',
              items: const [
                DropdownMenuItem(value: 'debit', child: Text('Debit -')),
                DropdownMenuItem(value: 'credit', child: Text('Credit +'))
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    type = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _submitForm();
              },
              child: isLoader
                  ? const Center(child: CircularProgressIndicator())
                  : const Text("Add Transaction"),
            )
          ],
        ),
      ),
    );
  }
}
