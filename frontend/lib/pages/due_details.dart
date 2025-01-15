import 'package:flutter/material.dart';
import 'package:frontend/storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/components/warning_dialogue.dart';

class DueDetails extends StatefulWidget {
  final String name;

  const DueDetails({
    super.key, 
    required this.name, 
  });

  @override
  DueDetailsState createState() => DueDetailsState();
}

class DueDetailsState extends State<DueDetails> {
  final storage = Storage();
  bool loading = true;
  double due = 0;
  String backendUri = "", userId = "";
  List<dynamic> dueList= [];
  List<bool> expand = [];

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final storedUserId = await storage.get('user_id');

    setState(() {
      backendUri = dotenv.env['BACKEND_URI']!;
      userId = storedUserId!;
    });

    final uri = Uri.parse("$backendUri/transactions/getDueDetails");
    final response = await http.post(uri, 
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'name': widget.name
      })
    );

    final data = await json.decode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        dueList = data['due_details'];
      });

      setState(() {
        for (int i = 0; i < dueList.length; i++) {
          String date = dueList[i][3].toString();
          dueList[i][3] = (date).substring(0, date.length-13);
          if (dueList[i][1] == "Due paid") {
            due -= double.parse(dueList[i][5]);
          } else {
            due += double.parse(dueList[i][5]);
          }

          expand.add(false);
        }
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

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 60, 20, 20),
          child: (!loading) ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold
                ),
              ),

              SizedBox(height: 30,),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Total Due :",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w400
                    ),
                  ),
                  SizedBox(width: 10,),
                  Text(
                    due.toString(),
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.red,
                      fontWeight: FontWeight.w400
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20,),

              Text(
                "Dues:",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500
                ),
              ),

              SizedBox(height: 10,),

              Column(
                children: [
                  ...dueList.asMap().entries.map((entry) {
                    int index = entry.key;
                    List<dynamic> dues = entry.value;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          expand[index] = !expand[index];
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: expand[index] ? Colors.black : Color.fromARGB(0, 0, 0, 0))
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  dues[1],
                                  style: TextStyle(
                                    fontSize: 20
                                  ),
                                ),
                                Text(
                                  dues[5].toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: (dues[1] != "Due paid") ? Colors.red : Colors.green
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
                                      "${dues[3]}",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey.shade800,
                                      ),
                                    ), 
                                    SizedBox(width: 10,),
                                    Text(
                                      dues[4],
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade800,
                                      ),
                                    ), 
                                  ],
                                ),

                                expand[index] ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 2,),
                                    Text(
                                      dues[0],
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),

                                    SizedBox(height: 10,),
                                    
                                    Text(
                                      dues[2],
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ],
                                ) : SizedBox()
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                    
                  }),
                ],
              )
            ]
          ) : SizedBox(
            width: w,
            height: h*0.75,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      )
    );
  }
}