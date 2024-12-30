import 'package:flutter/material.dart';
import 'package:frontend/pages/dashboard.dart';
import 'package:frontend/pages/login.dart';
import 'package:frontend/storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  SignupState createState() => SignupState();
}

class SignupState extends State<Signup> {
  String name = '', mobile = '', password = '', gender = 'Male', age = '';

  List<DropdownMenuItem<String>> genders = <DropdownMenuItem<String>>[
    DropdownMenuItem<String>(
      value: 'M',
      child: Text('Male'),
    ),
    DropdownMenuItem<String>(
      value: 'F',
      child: Text('Female'),
    ),
    DropdownMenuItem<String>(
      value: 'O',
      child: Text('Other'),
    ),
  ];

  @override
  void initState() {
    super.initState();
    setState(() {
      name = '';
      mobile = '';
      password = '';
      age = '';
      gender = 'M';
    });
  }

  Future<void> registerUser() async {
    final signupURI = Uri.parse('http://192.168.101.3:3001/register');
    
    try {
      final storage = Storage();

      final response = await http.post(signupURI,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'mobile': mobile, 'password': password, 'age': age, 'gender': gender})
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {;
        await storage.set('user_id', data['user_id']);
        await storage.set('name', data['name']);
        await storage.set('mobile', mobile);
        await storage.set('password', password);

        setState(() {
          name = "";
          mobile = "";
          password = "";
          age = "";
          gender = "M";
        });
      } else {
        print(data['message']);
      }
    } catch(error) {
      print('Error: $error');
    }

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
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned(
              top: -h*0.84,
              left: -w*0.75,
              child: Container(
                height: h*2,
                width: w*3,
                decoration: const BoxDecoration(
                  color: Color(0xFF8045FF),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Container(
              height: h,
              width: w,
              padding: EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Signup",
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Playfair'
                    ),
                  ),

                  SizedBox(height: 30),

                  TextField(
                    decoration: InputDecoration(
                      hintText: "Name",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(20),
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
                        name = value;
                      })
                    },
                  ),

                  SizedBox(height: 37),

                  TextField(
                    decoration: InputDecoration(
                      hintText: "Mobile No.",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(20),
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

                  SizedBox(height: 37),

                  TextField(
                    decoration: InputDecoration(
                      hintText: "Password",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(20),
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

                  SizedBox(height: 37),

                  Row(
                    children: [
                      SizedBox(
                        width: w*0.4, 
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Age",
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.all(20),
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
                              age = value;
                            })
                          },
                          
                        ),
                      ),
                      

                      SizedBox(width: 40),

                      Container(
                        width: w * 0.4,
                        height: h*0.07,
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: gender,
                          icon: Icon(Icons.keyboard_arrow_down, color: Colors.black),
                          style: TextStyle(color: Colors.black),
                          underline: SizedBox(),
                          dropdownColor: Colors.white,
                          onChanged: (String? newValue) {
                            setState(() {
                              gender = newValue!;
                            });
                          },
                          items: genders,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 35),

                  ElevatedButton(
                    onPressed: registerUser, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF000000),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                      child: Text(
                        "Signup",
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
                        MaterialPageRoute(builder: (context) => const Login())
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
                  ),

                  SizedBox(height: 10),

                  SizedBox(
                    width: w,
                    child: Row(
                    children: [
                      SizedBox(width: 60),
                      Image.asset(
                        'assets/signup2.png',
                        width: w*0.3,
                        height: h*0.2,
                        fit: BoxFit.cover,
                      ),

                      Image.asset(
                        'assets/signup1.png',
                        width: w*0.35,
                        height: h*0.25,
                        fit: BoxFit.cover,
                      ),
                    ],
                  )
                  ),
                ],
              ),

            )
          ]
        )
      )
    );
  }
}