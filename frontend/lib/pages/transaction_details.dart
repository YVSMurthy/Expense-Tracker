import 'package:flutter/material.dart';

class TransactionDetails extends StatefulWidget {
  final String transId;

  const TransactionDetails({
    super.key,
    required this.transId
  });

  @override
  TransactionDetailsState createState() => TransactionDetailsState();
}

class TransactionDetailsState extends State<TransactionDetails> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "TransactionDetails Page for id ${widget.transId}",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          )
        )
      ),
    );
  }
}