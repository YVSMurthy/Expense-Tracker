import 'package:flutter/material.dart';
import 'package:frontend/pages/due_details.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/storage.dart';
import 'package:frontend/components/warning_dialogue.dart';

class Dues extends StatefulWidget {
  const Dues({super.key});

  @override
  DuesState createState() => DuesState();
}

class DuesState extends State<Dues> {
  final storage = Storage();
  List<String> people = [];
  List<double> due = [];
  double totalDue = 0;
  String backendUri = "", userId = "";

  void getDueDetails(int index) {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => DueDetails(name: people[index])) 
    );
  }

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

    final uri = Uri.parse("$backendUri/transactions/getDues");
    final response = await http.post(uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId
      })
    );

    final data = await json.decode(response.body);

    if (response.statusCode == 200) {
      final dueData = data['dues'];
      
      setState(() {
        for (int i = 0; i < dueData.length; i++) {
          if (double.parse(dueData[i][1]) != 0) {
            people.add(dueData[i][0]);
            due.add(double.parse(dueData[i][1]));
          }
        }
      });

    } else {
      if (mounted) {
        showWarningDialog(context, data['title'], data['message']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(width: 10,),
                Text(
                  "Dues",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),

            SizedBox(height: 20,),

            Container(
              width: w,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Name",
                    style: TextStyle(
                      fontSize: 20
                    ),
                  ),
                  Text(
                    "Amount",
                    style: TextStyle(
                      fontSize: 20
                    ),
                  )
                ],
              )
            ),

            Container(
              height: people.length*h*0.09 + 10,
              constraints: BoxConstraints(maxHeight: h*0.65),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 241, 241, 241)
              ),
              child: ListView.builder(
                itemCount: people.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(20, 0, 35, 10),
                    child: Column (
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 241, 241, 241)
                          ),
                          child: GestureDetector(
                            onTap: () {
                              getDueDetails(index);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    people[index],
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                Text(
                                  due[index].toString(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Color.fromARGB(255, 230, 53, 40),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 25,)
                      ],
                    )
                  );
                },
              ),
            ),
            
          ]
        ),
      )
    );
  }
}