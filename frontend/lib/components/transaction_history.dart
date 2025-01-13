import 'package:flutter/material.dart';
import 'package:frontend/storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/components/warning_dialogue.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  @override
  TransactionHistoryState createState() => TransactionHistoryState();
}

class TransactionHistoryState extends State<TransactionHistory> {
  final storage = Storage();
  String backendUri = "", userId = "";
  Map<String, dynamic> transactions = {};
  bool loading = true;



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

    final uri = Uri.parse("$backendUri/transactions/getTransactions");
    final response = await http.post(uri, 
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'months_back': 0
      })
    );

    final data = await json.decode(response.body);

    if (response.statusCode == 200) {

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
      body: Container(
        padding: EdgeInsets.fromLTRB(20, 60, 20, 20),
        child:  (!loading) ? Column(

        ) : SizedBox(
          width: w,
          height: h*0.75,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      )
    );
  }
}