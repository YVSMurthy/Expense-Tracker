import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/storage.dart';
import 'package:frontend/components/warning_dialogue.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  final storage = Storage();
  String backendUri = "", userId = "";
  double netExpense = 0, expense = 0, income = 0; 
  Map<String, List<dynamic>> categoryWiseData = {};

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
          expense = double.parse(data['monthly_expense_data'][0]);
          income = double.parse(data['monthly_expense_data'][1]);
          netExpense = income - expense;

          categoryWiseData = {
            'Food': [40.0, Colors.amber],
            'Stationary': [5.0, Colors.blue],
            'Amazon': [15.0, Colors.green],
            'Invest': [35.0, Colors.purple],
            'Emergency': [5.0, Colors.red],
          };
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
                      child: Container(
                        height: h*0.25,
                        width: w*0.25,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.amber
                        ),
                      ),
                    ),

                    SizedBox(height: 30,),

                    Column(

                      children: [
                        ...categoryWiseData.entries.map((entry) {
                          String catName = entry.key;
                          List<dynamic> data = entry.value;

                          return Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: data[1]
                                    ),
                                  ),
                                  SizedBox(width: 20,),
                                  Text(
                                    "$catName (${data[0]}%)",
                                    style: TextStyle(
                                      fontSize: 18
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5,)
                            ],
                          );
                        })

                      ],
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      )
    );
  }
}