import 'package:flutter/material.dart';

class DueDetails extends StatefulWidget {
  final String name;

  const DueDetails({super.key, required this.name});

  @override
  DueDetailsState createState() => DueDetailsState();
}

class DueDetailsState extends State<DueDetails> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Due details of ${widget.name}",
          style: TextStyle(
            fontSize: 30
          ),
        )
      ),
    );
  }
}