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
  Map<String, double> dues = {}; // Key: Name, Value: Due amount
  double totalDue = 0;
  bool loading = true;
  String backendUri = "", userId = "";

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void getDueDetails(String name) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DueDetails(name: name)),
    );
  }

  Future<void> _loadDetails() async {
    final storedUserId = await storage.get('user_id');

    setState(() {
      backendUri = dotenv.env['BACKEND_URI']!;
      userId = storedUserId!;
    });

    try {
      final uri = Uri.parse("$backendUri/transactions/getDues");
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId}),
      );

      final data = await json.decode(response.body);

      if (response.statusCode == 200) {
        final dueData = data['dues'];
        setState(() {
          for (var dueEntry in dueData) {
            final name = dueEntry[0];
            final amount = double.parse(dueEntry[1]);
            if (amount != 0) {
              dues[name] = amount;
              totalDue += amount;
            }
          }
        });
      } else {
        if (mounted) {
          showWarningDialog(context, data['title'], data['message']);
        }
      }
    } catch (error) {
      if (mounted) {
        showWarningDialog(context, "Some Error Occurred", error.toString());
      }
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: loading
            ? SizedBox(
                width: w,
                height: h * 0.75,
                child: const Center(child: CircularProgressIndicator()),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (totalDue != 0) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Dues",
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: w,
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      decoration: BoxDecoration(color: const Color.fromARGB(255, 231, 231, 231)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Name", style: TextStyle(fontSize: 20)),
                          Text("Amount", style: TextStyle(fontSize: 20)),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    ...dues.entries.map((entry) {
                      return GestureDetector(
                        onTap: () => getDueDetails(entry.key),
                        child: Container(
                          padding: EdgeInsets.fromLTRB(20, 15, 35, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key, style: TextStyle(fontSize: 20)),
                              Text(
                                entry.value.toString(),
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 230, 53, 40),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ] else
                    SizedBox(
                      width: w,
                      height: h * 0.8,
                      child: Center(
                        child: Text("No Due", style: TextStyle(fontSize: 36)),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}