import 'package:flutter/material.dart';

class AddRecord extends StatefulWidget {
  const AddRecord({super.key});

  @override
  AddRecordState createState() => AddRecordState();
}

class AddRecordState extends State<AddRecord> {
  String amount = "", type = 'exp', friendName = "", reason = "";
  bool split = false;

  List<DropdownMenuItem<String>> types = [
    DropdownMenuItem(value: "exp",  child: Text("Expense")),
    DropdownMenuItem(value: "inc",  child: Text("Income")),
    DropdownMenuItem(value: "due",  child: Text("Due Paid")),
  ];

  void addRecord() {

  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
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
                onChanged: (value) => {
                  setState(() {
                    amount = value;
                  })
                },
              ),

              SizedBox(height: 25,),

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
                onChanged: (value) => {
                  setState(() {
                    reason = value;
                  })
                },
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
                        onChanged: (value) => {
                          setState(() {
                            friendName = value;
                          })
                        },
                      ) 
                    ],
                  ) : SizedBox(),
                ]
              ) : (type == "due") ? Column(
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
                    onChanged: (value) => {
                      setState(() {
                        friendName = value;
                      })
                    },
                  ) 
                ],
              ) : SizedBox(),

              SizedBox(height: 25,),
              
              Row(
                children: [
                  SizedBox(width: 10),
                  Text(
                    "Expense Type",
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
                width: w,
                height: h*0.07,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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

              SizedBox(height: 40,),

              Center(
                child: ElevatedButton(
                  onPressed: addRecord, 
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