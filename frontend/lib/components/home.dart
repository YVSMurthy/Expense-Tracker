import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/storage.dart';
import 'package:frontend/components/warning_dialogue.dart';
import 'package:fl_chart/fl_chart.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  final storage = Storage();
  String backendUri = "", userId = "";
  double netExpense = 0, expense = 0, income = 0; 
  List<dynamic> categoryWiseData = [];

  final List<Color> predefinedColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.cyan,
    Colors.pink,
  ];

  Future<void> _loadDetails() async {
    try {
      final storedUserId = await storage.get('user_id');

      setState(() {
        backendUri = dotenv.env['BACKEND_URI']!;
        userId = storedUserId!;
      });

      final uri = Uri.parse("$backendUri/analytics/get");
      final response = await http.post(uri, 
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId
        })
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          categoryWiseData.clear();
          expense = double.parse(data['monthly_expense_data'][0]);
          income = double.parse(data['monthly_expense_data'][1]);
          netExpense = income - expense;

          categoryWiseData = List.from(data['category_wise_data']);
        });

      } else {
        if (mounted) {
          showWarningDialog(context, "Internal Server Error", "Please try again.");
        }
      }

    } catch(error) {
      if (mounted) {
        showWarningDialog(context, "An Error Occured", error.toString());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: w,
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 136, 136, 136).withAlpha(50), // Shadow color with opacity
                      spreadRadius: 5, // How much the shadow spreads
                      blurRadius: 7, // How soft the shadow looks
                      offset: Offset(0, 3), // Shadow position (x, y)
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Net Expense",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'times',
                        color: Colors.grey.shade800
                      ),
                    ),

                    SizedBox(height: 5,),

                    Text(
                      netExpense.toString(),
                      style: TextStyle(
                        fontSize: 30,
                        fontFamily: 'times',
                        color: (netExpense >= 0) ? Colors.green : Colors.red
                      ),
                    ),

                    SizedBox(height: 20,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              "Expenses",
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'times',
                                color: Colors.grey.shade800
                              ),
                            ),

                            SizedBox(height: 5,),

                            Text(
                              expense.toString(),
                              style: TextStyle(
                                fontSize: 26,
                                fontFamily: 'times',
                                color: Colors.red
                              ),
                            ),
                          ],
                        ),

                        Column(
                          children: [
                            Text(
                              "Income",
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'times',
                                color: Colors.grey.shade800
                              ),
                            ),

                            SizedBox(height: 5,),

                            Text(
                              income.toString(),
                              style: TextStyle(
                                fontSize: 26,
                                fontFamily: 'times',
                                color: Colors.green 
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),

              SizedBox(height: 30,),

              Container(
                width: w,
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 136, 136, 136).withAlpha(50), // Shadow color with opacity
                      spreadRadius: 5, // How much the shadow spreads
                      blurRadius: 7, // How soft the shadow looks
                      offset: Offset(0, 3), // Shadow position (x, y)
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Expense Visualisation",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'times'
                      ),
                    ),

                    SizedBox(height: 20,),

                    SizedBox(
                      width: w,
                      child: SizedBox(
                        height: h * 0.4,
                        width: w * 0.25,
                        child: PieChart(
                          PieChartData(
                            sections: categoryWiseData.asMap().entries.map((entry) {
                              int index = entry.key;
                              List<dynamic> category = entry.value;

                              double expenditure = double.parse(category[1]);

                              double offset = 0.8 - (expenditure/expense);

                              return PieChartSectionData(
                                value: expenditure,
                                title: expenditure.toString(),
                                color: predefinedColors[index % predefinedColors.length],
                                titleStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                radius: 130,
                                titlePositionPercentageOffset: offset < 0.5 ? 0.5 : offset
                              );
                            }).toList(),
                            centerSpaceRadius: 10,
                            sectionsSpace: 2,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20,),

                    Column(
                      children: categoryWiseData.asMap().entries.map((entry) {
                        int index = entry.key;
                        List<dynamic> category = entry.value;

                        String catName = category[0];
                        double expenditure = double.parse(category[1]);

                        return Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: predefinedColors[index],
                                  ),
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "$catName ($expenditure)",
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                          ],
                        );
                      }).toList(),
                    ),
                  
                    SizedBox(height: 40,),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: w,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 231, 231, 231),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      "Category",
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "Spent",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "Budget",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "Left",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(color: Colors.grey.shade100),
                              child: Column(
                                children: categoryWiseData.asMap().entries.map((entry) {
                                  List<dynamic> category = entry.value;

                                  String catName = category[0];
                                  double expenditure = double.parse(category[1]);
                                  double allotted = double.parse(category[2]);

                                  return Container(
                                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text(catName, style: TextStyle(fontSize: 16)),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            expenditure.toStringAsFixed(2),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            allotted.toStringAsFixed(2),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            (allotted - expenditure).toStringAsFixed(2),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 10,)
                  ],
                ),
              ),

              SizedBox(height: 30,)
            ],
          ),
        ),
      )
    );
  }
}