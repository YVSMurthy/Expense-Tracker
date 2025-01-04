import 'package:flutter/material.dart';

class Dues extends StatefulWidget {
  const Dues({super.key});

  @override
  DuesState createState() => DuesState();
}

class DuesState extends State<Dues> {
  List<String> person = [];
  List<double> due = [];
  double totalDue = 0;

  @override
  void initState() {
    super.initState();

    person = ["Aryajeet", "Aabhas"];
    due = [60, 20];

    double sum = 0;
    for (int i = 0; i < due.length; i++) {
      sum += due[i];
    }

    setState(() {
      totalDue = sum;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;


    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
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
          
            SizedBox(height: 30,),

            
          ]
        ),
      )
    );
  }
}