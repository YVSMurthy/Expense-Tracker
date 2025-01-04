import 'package:flutter/material.dart';
import 'package:frontend/pages/dashboard.dart';
import 'package:frontend/pages/signup.dart';
import 'package:frontend/storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:core';
import 'package:frontend/components/warning_dialogue.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  String mobile = "", password = "";
  String backendUri = "";

  @override
  void initState() {
    super.initState();
    backendUri = dotenv.env['BACKEND_URI']!;
  }

  bool checkMobile() {
    String mobilePattern = r'^[1-9][0-9]{9}';
    RegExp mobileReg = RegExp(mobilePattern);
    return mobileReg.hasMatch(mobile);
  }

  // login user
  Future<void> verifyUser() async {
    if (!checkMobile()) {
      showWarningDialog(context, "Invalid Mobile Number", "Please enter a valid 10-digit mobile number.");
      return;
    }
    
    try {
      final loginURI = Uri.parse('$backendUri/auth/login');
      final response = await http.post(loginURI,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mobile': mobile, 'password': password})
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final storage = Storage();
        await storage.set('user_id', data['user_id']);
        await storage.set('name', data['name']);
        await storage.set('mobile', mobile);
        await storage.set('password', password);

        setState(() {
          mobile = "";
          password = "";
        });

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Dashboard())
          );
        }
      } else {
        if (mounted) {
          showWarningDialog(context, data['title'], data['message']);
        }
      }
    } catch(error) {
      if (mounted) {
        showWarningDialog(context, "Internal Server Error", "Please try again.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned(
              top: h*0.57,
              left: -w*2,
              child: Container(
                width: w*5,
                height: h*2,
                decoration: BoxDecoration(
                  color: Color(0xFF8045FF),
                  shape: BoxShape.circle,
                ),
              )
            ),

            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              margin: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              height: h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 20),

                  Text(
                    "Expense Tracker",
                    style: TextStyle(
                      fontFamily: 'Courgette',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 20),

                  Image.asset('assets/login.png',
                    height: w*0.8,
                    width: h*0.5,
                    fit: BoxFit.cover,
                  ),

                  SizedBox(height: 55),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Login",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Playfair',
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(height: 25),

                      TextField(
                        decoration: InputDecoration(
                          hintText: "Mobile no.",
                          filled: true,
                          fillColor: Colors.white,
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
                            mobile = value;
                          })
                        },
                      ),

                      SizedBox(height: 25),

                      TextField(
                        decoration: InputDecoration(
                          hintText: "Password",
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0), // Adds rounded corners
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                          ),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        onChanged: (value) => {
                          setState(() {
                            password = value;
                          })
                        },
                      ),

                      SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: verifyUser, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF000000),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        )
                      ),

                      SizedBox(height: 10),

                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const Signup())
                          );
                        },

                        child: Text(
                          "Don't have an account? Register",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                          )
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        )
      ),
    );
  }
}