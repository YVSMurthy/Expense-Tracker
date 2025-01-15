import 'package:flutter/material.dart';
import 'package:frontend/storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/components/warning_dialogue.dart';
import 'package:frontend/pages/transaction_details.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  @override
  TransactionHistoryState createState() => TransactionHistoryState();
}

class TransactionHistoryState extends State<TransactionHistory> {
  final storage = Storage();
  String backendUri = "", userId = "", category = "";
  Map<String, dynamic> transactionList = {}, filteredTransactions = {};
  int monthsBack = 0;
  bool loading = true;
  List<DropdownMenuItem<String>> dateFilter = <DropdownMenuItem<String>>[
    DropdownMenuItem<String>(
      value: '0',
      child: Text('30 days'),
    ),
    DropdownMenuItem<String>(
      value: '2',
      child: Text('3 Months'),
    ),
    DropdownMenuItem<String>(
      value: '5',
      child: Text('6 Months'),
    ),
    DropdownMenuItem<String>(
      value: '11',
      child: Text('1 Year'),
    ),
  ];



  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() async {
    final storedUserId = await storage.get('user_id');

    setState(() {
      backendUri = dotenv.env['BACKEND_URI']!;
      userId = storedUserId!;
    });

    fetchTransactions();
  }

  bool matches(String title, String value) {
    String pattern = '^$value';
    return RegExp(pattern, caseSensitive: false).hasMatch(title);
  }

  void filterCategory() {
    setState(() {
      filteredTransactions = {};
    });

    if (category == "all") {
      setState(() {
        transactionList.forEach((key, value) {
          filteredTransactions.addEntries({key: value}.entries);
        });
      });
    } else {
      transactionList.forEach((month, transactionDetails) {
        double monthlyTotal = 0;
        List<List<dynamic>> monthlyTransactions = [];
        transactionDetails['transactions'].forEach((transaction) {
          if (matches(transaction[1], category)) {
            if (transaction[2] != 'paid' && transaction[2] != "inc") {
              monthlyTotal -= double.parse(transaction[4]);
            } else {
              monthlyTotal += double.parse(transaction[4]);
            }
            monthlyTransactions.add(transaction);
          }
        });

        setState(() {
          filteredTransactions.addEntries({month: {'total': monthlyTotal.toString(), 'transactions': monthlyTransactions}}.entries);
        });
      });
    }
  }

  void fetchTransactions() async {
    setState(() {
      loading = true;
    });

    final uri = Uri.parse("$backendUri/transactions/getTransactions");
    final response = await http.post(uri, 
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'months_back': monthsBack
      })
    );

    final data = await json.decode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        for (var entry in data['transactions'].entries.toList().reversed) {
          transactionList[entry.key] = entry.value;
        }
      });

      transactionList.entries.map((entry) {
        Map<String, dynamic> monthlyTransaction = entry.value; 
        List<dynamic> transactions = monthlyTransaction['transactions'];
        for (int i = 0; i < transactions.length; i++) {
          String date = transactions[i][3].toString();
          transactions[i][3] = (date).substring(0, date.length-13);
        }
      });

      setState(() {
        transactionList.forEach((key, value) {
          filteredTransactions.addEntries({key: value}.entries);
        });
      });

    } else {
      if (mounted) {
        showWarningDialog(context, data['title'], data['message']);
      }
    }

    setState(() {
      loading = false;
    });
  }

  void fetchTransactionDetails(String transId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) => TransactionDetails(transId: transId))
    );
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Transaction History",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500
                    ),
                  ),

                  SizedBox(height: 20,),
                  
                  Row(
                    children: [
                      SizedBox(
                        width: w*0.5,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Category",
                            filled: true,
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0), // Adds rounded corners
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                            ),
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (value) {
                            setState(() {
                              category = (value == "") ? "all" : value;
                            });
                            filterCategory();
                          },
                        ),
                      ),
                      SizedBox(width: 10,),
                      Container(
                        width: w * 0.35,
                        height: h*0.07,
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: monthsBack.toString(),
                          icon: Icon(Icons.keyboard_arrow_down, color: Colors.black),
                          style: TextStyle(color: Colors.black),
                          underline: SizedBox(),
                          dropdownColor: Colors.white,
                          onChanged: (String? newValue) {
                            setState(() {
                              monthsBack = int.parse(newValue!);
                            });
                            fetchTransactions();
                          },
                          items: dateFilter,
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
            
            SizedBox(height: 20,),

            SizedBox(
              child: (!loading) ? Column(
                children: [
                  ...filteredTransactions.entries.map((entry) {
                    String month = entry.key;
                    Map<String, dynamic> monthlyTransaction = entry.value; 
                    double monthTotal = double.parse(monthlyTransaction['total']);
                    List<dynamic> transactions = monthlyTransaction['transactions'];

                    return Column(
                      children: [
                        Container(
                          width: w,
                          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                          decoration: BoxDecoration(color: const Color.fromARGB(255, 231, 231, 231)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                month, 
                                style: TextStyle(fontSize: 20)
                              ),

                              Text(
                                "${monthTotal > 0 ? "+" : ""}$monthTotal", 
                                style: TextStyle(
                                  fontSize: 20,
                                  color: (monthTotal > 0) ? Colors.green : Colors.red 
                                )
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 10,),

                        ...transactions.map((transaction) {
                          return GestureDetector(
                            onTap: () {
                              fetchTransactionDetails(transaction[0]);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        transaction[1],
                                        style: TextStyle(
                                          fontSize: 20
                                        ),
                                      ),
                                      Text(
                                        transaction[4],
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: (transaction[2] == "inc" || transaction[2] == "paid") ? Colors.green : (transaction[2] == "due") ? Colors.purple : Colors.red
                                        ),
                                      ), 
                                    ]
                                  ),
                                  SizedBox(height: 2,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            transaction[3],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade800,
                                            ),
                                          ), 
                                          SizedBox(width: 10,),
                                          Text(
                                            transaction[5],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade800,
                                            ),
                                          ), 
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        }),

                        SizedBox(height: 50,),
                      ],
                    );
                  })
                ],
              )  : SizedBox(
                width: w,
                height: h*0.6,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          ],
        )
      )
    );
  }
}