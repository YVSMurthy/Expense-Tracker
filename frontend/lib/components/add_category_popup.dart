import 'package:flutter/material.dart';

Future<Map<String, dynamic>?> showAddCategoryDialog(BuildContext context) async {
  final TextEditingController catNameController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();

  return await showDialog<Map<String, dynamic>?>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add New Category'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              TextField(
                controller: catNameController,
                decoration: InputDecoration(
                  labelText: 'Category Name',
                ),
              ),
              TextField(
                controller: budgetController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Allotted Budget',
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Handle cancel action
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              String catName = catNameController.text.trim();
              String budget = budgetController.text.trim();

              if (catName.isNotEmpty && budget.isNotEmpty) {
                double allottedAmount = double.tryParse(budget) ?? 0.0;
                Navigator.of(context).pop({
                  'catName': catName,
                  'allottedAmount': allottedAmount
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Please fill in both fields!'),
                  backgroundColor: Colors.red,
                ));
              }
            },
            child: Text('Add'),
          ),
        ],
      );
    },
  );
}
