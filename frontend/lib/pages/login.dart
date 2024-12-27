import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/pages/dashboard.dart';
import 'package:frontend/pages/signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  String username = "", password = "";

  @override
  void initState() {
    super.initState();
  }

  // login user
  void verifyUser() {
    print("Username:" + username);
    print("Password:" + password);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Dashboard())
    );
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          // height: h,
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
                padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                "Expense Tracker",
                      style: TextStyle(
                        fontFamily: 'Courgette',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 40),

                    Image.asset('assets/login.png',
                      height: w*0.8,
                      width: h*0.5,
                      fit: BoxFit.cover,
                    ),

                    SizedBox(height: 50),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Login",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Playfair',
                            color: Colors.white,
                          ),
                        ),

                        SizedBox(height: 30),

                        TextField(
                          decoration: InputDecoration(
                            labelText: "Username",
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
                              username = value;
                            })
                          },
                        ),

                        SizedBox(height: 25),

                        TextField(
                          decoration: InputDecoration(
                            labelText: "Password",
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
                              fontSize: 20,
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
      ) 
    );
  }
}