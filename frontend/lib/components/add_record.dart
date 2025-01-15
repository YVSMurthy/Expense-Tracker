import 'package:flutter/material.dart';
import 'package:frontend/components/warning_dialogue.dart';
import 'package:frontend/storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AddRecord extends StatefulWidget {
  const AddRecord({super.key});

  @override
  AddRecordState createState() => AddRecordState();
}

class AddRecordState extends State<AddRecord> {
  final storage = Storage();
  TextEditingController amount = TextEditingController(), title = TextEditingController(), friendName = TextEditingController(), transDesc = TextEditingController();
  String type = 'exp', userId = "";
  String selectDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool split = false;
  String backendUri = "";

  List<DropdownMenuItem<String>> types = [
    DropdownMenuItem(value: "exp",  child: Text("Expense")),
    DropdownMenuItem(value: "inc",  child: Text("Income")),
    DropdownMenuItem(value: "due_paid",  child: Text("Due Paid")),
  ];

  Future<void> addRecord() async {
    try {
      final uri = Uri.parse('$backendUri/transaction/add');
      final response = await http.post(uri, 
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'title': title.text,
          'trans_desc': (transDesc.text == "") ? title.text : transDesc.text,
          'type': split ? 'due' : type,
          'trans_date': selectDate,
          'amount': double.parse(amount.text),
          'split': split,
          'friend': friendName.text
        })
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          title.text = "";
          transDesc.text = "";
          type = "exp";
          selectDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
          amount.text = "";
          friendName.text = "";
          split = false;
        });
      } else {
        if (mounted) {
          showWarningDialog(context, data['title'], data['message']);
        }
      }

    } catch (error) {
      if (mounted) {
        showWarningDialog(context, "Internal Server Error", "$error");
      }
    }
  }

  Future<void> updateDueRecord() async {
    try {
      final uri = Uri.parse('$backendUri/transaction/updateDue');
      final response = await http.post(uri, 
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'trans_date': selectDate,
          'amount': double.parse(amount.text),
          'friend': friendName.text
        })
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          title.text = "";
          transDesc.text = "";
          type = "exp";
          selectDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
          amount.text = "";
          friendName.text = "";
          split = false;
        });
      } else {
        if (mounted) {
          showWarningDialog(context, data['title'], data['message']);
        }
      }

    } catch (error) {
      if (mounted) {
        showWarningDialog(context, "Internal Server Error", "$error");
      }
    }
  }
  
  Future<void> _loadDetails() async {
    backendUri = dotenv.env['BACKEND_URI']!;
    final storedUserId = await storage.get('user_id');
    setState(() {
      userId = storedUserId!;
    });
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1950),
        lastDate: DateTime.now()
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
      setState(() {
        selectDate = formattedDate;
      });
    } else {}
  }

  @override
  void initState()  {
    super.initState();
    _loadDetails();
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        child: Container (
          width: w,
          margin: EdgeInsets.symmetric(vertical: 20, horizontal: 0),
          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          decoration: BoxDecoration(
            color: (type == "exp") ? const Color.fromARGB(255, 255, 161, 161) :
            (type == "inc") ? const Color.fromARGB(255, 164, 242, 168) : Colors.purple.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              width: 1,
              color: Colors.black,
            )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // amount
              Row(
                children: [
                  SizedBox(width: 10),
                  Text(
                    "Amount",
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold
                    )
                  )
                ]
              ),

              SizedBox(height: 10,),

              TextField(
                controller: amount,
                decoration: InputDecoration(
                  hintText: "Amount",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.all(15),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0), // Adds rounded corners
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                  ),
                  border: OutlineInputBorder(),
                ),
              ),

              (type != 'due_paid') ? Column(
                children: [
                  SizedBox(height: 25,),

                  Row(
                    children: [
                      SizedBox(width: 10),
                      Text(
                        (type == 'exp') ? "Category" : "Title",
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold
                        )
                      )
                    ]
                  ),

                  SizedBox(height: 10,),

                  TextField(
                    controller: title,
                    decoration: InputDecoration(
                      hintText: (type == 'exp') ? "Category" : "Title",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(15),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0), // Adds rounded corners
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ) : SizedBox(),

              (type != 'due_paid') ? Column(
                children: [
                  SizedBox(height: 25),

                  Row(
                    children: [
                      SizedBox(width: 10),
                      Text(
                        "Reason",
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold
                        )
                      )
                    ]
                  ),

                  SizedBox(height: 10,),

                  TextField(
                    controller: transDesc,
                    decoration: InputDecoration(
                      hintText: "State the reason for expense or income",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(15),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0), // Adds rounded corners
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ) : SizedBox(),
              

              SizedBox(height: 25),

              Row(
                children: [
                  // date selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 10),
                          Text(
                            "Date",
                            style: TextStyle(
                              fontSize: 22,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold
                            )
                          )
                        ]
                      ),

                      SizedBox(height: 10,),

                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Row(
                          children: [
                            Text(
                              selectDate.toString()
                            ),

                            SizedBox(width: 10),

                            GestureDetector(
                              onTap: _pickDate,
                              child: Icon(Icons.calendar_month)
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(width: 25,),

                  // expense typr
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 10),
                          Text(
                            "Type",
                            style: TextStyle(
                              fontSize: 22,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold
                            )
                          )
                        ]
                      ),

                      SizedBox(height: 10,),

                      Container(
                        width: w*0.35,
                        padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: type,
                          icon: Icon(Icons.keyboard_arrow_down, color: Colors.black),
                          style: TextStyle(color: Colors.black),
                          underline: SizedBox(),
                          dropdownColor: Colors.white,
                          onChanged: (String? newValue) {
                            setState(() {
                              type = newValue!;
                            });
                          },
                          items: types,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              
              
              (type == "exp") ? Column(
                children: [
                  SizedBox(height: 25,),
                  Row(
                    children: [
                      SizedBox(width: 10,),
                      Text(
                        "Split with friends",
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold
                        )
                      ),
                      SizedBox(width: 70,),

                      Checkbox(
                        value: split,
                        onChanged: (bool? value) {
                          setState(() {
                            split = value!;
                          });
                        },
                      ),
                    ],
                  ),

                  split ? Column(
                    children: [
                      SizedBox(height: 10,),

                      TextField(
                        controller: friendName,
                        decoration: InputDecoration(
                          hintText: "Friend's name",
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.all(15),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0), // Adds rounded corners
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ) 
                    ],
                  ) : SizedBox(),
                ]
              ) : (type == "due_paid") ? Column(
                children: [
                  SizedBox(height: 25,),

                  Row(
                    children: [
                      SizedBox(width: 10),
                      Text(
                        "Friend's Name",
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold
                        )
                      )
                    ]
                  ),

                  SizedBox(height: 10,),

                  TextField(
                    controller: friendName,
                    decoration: InputDecoration(
                      hintText: "Friend's name",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(15),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0), // Adds rounded corners
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ) 
                ],
              ) : SizedBox(),

              SizedBox(height: 25,),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (type == 'due_paid') {
                      updateDueRecord();
                    }
                    else {
                      addRecord();
                    }
                  }, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF000000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                    child: Text(
                      "Add Record",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  )
                ),
              )
            ],
          )
        ),
      )
    );
  }
}