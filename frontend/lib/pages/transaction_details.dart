import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/components/warning_dialogue.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  String backendUri = "";
  String title = "Other", reason = "", type = "", date = "", time = "", friendName = "";
  double amount = 0;
  int split = 0;
  bool loading = true;

  Future<void> _loadDetails() async {
    try {
      setState(() {
        backendUri = dotenv.env['BACKEND_URI']!;
      });

      final uri = Uri.parse("$backendUri/transactions/getTransactionDetails");
      final response = await http.post(uri, 
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'trans_id': widget.transId
        })
      );

      final data = json.decode(response.body); 

      if (response.statusCode == 200) {
        final transactionDetails = data['transaction_details'];
        String dt = transactionDetails[3].toString();
        setState(() {
          title = transactionDetails[0];
          reason = transactionDetails[1];
          type = transactionDetails[2];
          date = dt.substring(0, dt.length-13);
          amount = double.parse(transactionDetails[4]);
          time = transactionDetails[5];
          split = transactionDetails[6];
          if (split == 1) {
            friendName = transactionDetails[7];
          }

          loading = false;
        });

      } else {
        if (mounted) {
          showWarningDialog(context, "Internal Server Error", "Please try again.");
        }
      }

    } catch(error) {
      if (mounted) {
        showWarningDialog(context, "An Error Occured!", error.toString());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDetails();
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Transaction details",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold
                ),
              ),

              SizedBox(height: 20,),

              Container(
                width: w,
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                decoration: BoxDecoration(
                  border: Border.all(width: 1.5, color: Colors.black),
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Column(
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.amber
                      ),
                      child: Center(
                        child: Text(
                          title[0],
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Times',
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 3,),

                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Times',
                        fontSize: 30,
                        fontWeight: FontWeight.bold
                      ),
                    ),

                    SizedBox(height: 10,),

                    Divider(thickness: 1.5, color: Colors.black,),

                    SizedBox(height: 10,),

                    Text(
                      "$date $time",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.w500
                      ),
                    ),

                    SizedBox(height: 20,),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Transaction Id:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 10,),
                            Expanded(
                              child: Text(
                                widget.transId,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ),
                          ],
                        ),

                        SizedBox(height: 10,),

                        Row(
                          children: [
                            Text(
                              "Category:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 10,),
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ),
                          ],
                        ),

                        SizedBox(height: 10,),

                        RichText(
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black, 
                            ),
                            children: [
                              TextSpan(
                                text: "Description: ",
                                style: TextStyle(fontWeight: FontWeight.bold), // Make this word bold
                              ),
                              TextSpan(
                                text: reason,
                                style: TextStyle(fontWeight: FontWeight.w500)
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 10,),

                        Row(
                          children: [
                            Text(
                              "Amount:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 10,),
                            Expanded(
                              child: Text(
                                amount.toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: (type == 'exp') ? Colors.red : (type == 'due') ? Colors.purple : Colors.green 
                                ),
                              )
                            ),
                          ],
                        ),

                        (split == 1) ? Column(
                          children: [
                            SizedBox(height: 10,),

                            Row(
                              children: [
                                Text(
                                  "Due from:",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Expanded(
                                  child: Text(
                                    friendName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                ),
                              ],
                            ),
                          ],
                        ) : SizedBox(),

                      ],
                    )
                    
                  ],
                ),
              )
            ],
          ) : SizedBox(
            width: w,
            height: h,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      )
    );
  }
}