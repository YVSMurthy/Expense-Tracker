import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:core';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  final storage = Storage();

  String userId = "", name = " ", mobile = " ", password = " ";
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool profileIsEditable = false, showPassword = false;

  double monthlyBudget = 0.0;
  bool goalIsEditable = false;
  List<String> categories = [];
  List<double> allottedBudget = [];
  double updatedBudget = 0;
  String updatedCategories = "";

  bool checkUpdates() {
    String namePattern = r'^[a-zA-Z]+';
    String mobilePattern = r'^[1-9][0-9]{9}';
    String pwdPattern = r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,16}$';

    RegExp nameReg = RegExp(namePattern);
    RegExp mobileReg = RegExp(mobilePattern);
    RegExp pwdReg = RegExp(pwdPattern);

    if (!nameReg.hasMatch(nameController.text)) {
      print("Name should only have alphabets");
      return false;
    }
    if (!mobileReg.hasMatch(mobileController.text)) {
      print("Mobile should only have 10 digits");
      return false;
    }
    if (!pwdReg.hasMatch(passwordController.text)) {
      print("Password should have min 1 uppercase, lowercase, symbol and number, and of length 8 to 16");
      return false;
    }

    return true;
  }

  Future<void> updateProfile() async {
    // checking what all have been updated
    List<String> fields = [], values = [];
    int passwordUpdated = 0;
    // name has beem updated
    if (name != nameController.text) {
      fields.add("name = %s ");
      values.add(nameController.text);
    }
    if (mobile != mobileController.text) {
      fields.add("mobile = %s ");
      values.add(mobileController.text);
    }
    if (password != passwordController.text) {
      fields.add("password = %s ");
      values.add(passwordController.text);
      passwordUpdated = 1;
    }
    // updating in database
    final uri = Uri.parse('http://192.168.101.3:3001/updateProfile');
    final response = await http.post(uri,
      headers: {'Context-Type': 'application/json'},
      body: json.encode({
        'user_id': userId, 
        'passwordUpdated': passwordUpdated, 
        'updates': {'fields': fields, 'values': values}})
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        name = nameController.text;
        mobile = mobileController.text;
        password = passwordController.text;
      });

      // updating in storage
      await storage.set('name', name);
      await storage.set('mobile', mobile);
      await storage.set('password', password);
    } else if (response.statusCode == 500) {
      print(data['message']);
    }

  }

  void addCategory() {
    final num = categories.length+1;
    final String categoryName = "Category $num";
    setState(() {
      categories.add(categoryName);
      allottedBudget.add(0.0);
    });
  }

  void deleteCategory(int index) {
    setState(() {
      monthlyBudget -= allottedBudget[index];
      categories.remove(categories[index]);
    });
  }

  void updateBudget(double updatedBudget, int index) {
    setState(() {
      monthlyBudget = monthlyBudget - allottedBudget[index] + updatedBudget;
      allottedBudget[index] = updatedBudget;
    });

  }

  void updatedGoals() {

  }

  _loadDetails() async {

    final storedName = await storage.get('name');
    final storedMobile = await storage.get('mobile');
    final storedPassword = await storage.get('password');
    final storedUserId = await storage.get('user_id');

    setState(() {
      userId = storedUserId!;
      name = storedName!;
      mobile = storedMobile!;
      password = storedPassword!;
    });

    nameController.text = storedName!;
    mobileController.text = storedMobile!;
    passwordController.text = storedPassword!;
  }

  @override
  void initState() {
    super.initState();
    _loadDetails();

    allottedBudget = [1500.00, 300.00];
    categories = ['Food', 'Stationary'];

    double budget = 0;
    for (int i = 0; i < categories.length; i++) {
      budget += allottedBudget[i];
    }

    setState(() {
      monthlyBudget = budget;
    });

    
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile part
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Profile",
                  style: TextStyle(
                    fontSize: 32,
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.bold,
                  )
                ),

                SizedBox(height: 10),

                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(36),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.purple.shade300
                      ),
                      child: Text(
                        name[0],
                        style: TextStyle(
                          fontFamily: 'Times',
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                          color: Colors.white
                        ),
                      ),
                    ),

                    SizedBox(width: 20,),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontFamily: 'Times',
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                        Text(
                          mobile,
                          style: TextStyle(
                            fontFamily: 'Times',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      ],
                    ),

                    SizedBox(width: 90,),

                    GestureDetector(
                      onTap: () {
                        if (checkUpdates()) {
                          if (profileIsEditable) {
                            updateProfile();
                          }

                          setState(() {
                            profileIsEditable = !profileIsEditable;
                          });
                        }
                      },
                      child: profileIsEditable ? Icon(Icons.save, color: Colors.blue.shade500, size: 30) : Icon(Icons.edit)
                    )
                  ],
                ),

                profileIsEditable ? Column(
                  children: [
                    SizedBox(height: 20,),

                    Row(
                      children: [
                        SizedBox(width: 10),
                        Text(
                          "Name",
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
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: "Name",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.all(15),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0), // Adds rounded corners
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: const Color.fromARGB(0, 0, 0, 0)),
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    SizedBox(height: 25,),

                    Row(
                      children: [
                        SizedBox(width: 10),
                        Text(
                          "Mobile",
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
                      controller: mobileController,
                      decoration: InputDecoration(
                        hintText: "Mobile",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.all(15),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0), // Adds rounded corners
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: const Color.fromARGB(0, 0, 0, 0)),
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    SizedBox(height: 25,),

                    Row(
                      children: [
                        SizedBox(width: 10),
                        Text(
                          "Password",
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: passwordController,
                              decoration: InputDecoration(
                                hintText: "Password",
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.all(15),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0), // Adds rounded corners
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: const Color.fromARGB(0, 0, 0, 0)),
                                ),
                                border: OutlineInputBorder(),
                              ),
                              obscureText: !showPassword,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                            child: showPassword ? Icon(Icons.visibility_off_outlined)  : Icon(Icons.visibility_outlined)
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),

                    SizedBox(height: 25,),
                  ],
                ) : SizedBox(),

              ],
            ),

            Divider(color: Colors.black,),

            SizedBox(height: 30),

            // Goals part
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Goals",
                      style: TextStyle(
                        fontSize: 32,
                        fontFamily: 'Arial',
                        fontWeight: FontWeight.bold,
                      )
                    ),
                    SizedBox(width: 220),
                    GestureDetector(
                      onTap: () {
                        if (goalIsEditable) {
                          updatedGoals();
                        }

                        setState(() {
                          goalIsEditable = !goalIsEditable;
                        });
                      },
                      child: goalIsEditable ? Icon(Icons.save, color: Colors.blue.shade500, size: 30) : Icon(Icons.edit)
                    )
                  ],
                ),
              
                SizedBox(height: 20,),

                Row(
                  children: [
                    SizedBox(width: 10),
                    Text(
                      "Montly Alloted Amount",
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
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Text(
                    monthlyBudget.toString(),
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'Times',
                      fontWeight: FontWeight.normal
                    )
                  ),
                ),

                SizedBox(height: 25,),  

                Row(
                  children: [
                    SizedBox(width: 10),
                    Text(
                      "Categories",
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold
                      )
                    ),
                    goalIsEditable ? Row(
                      children: [
                        SizedBox(width: 180),
                        GestureDetector(
                          onTap: addCategory,
                          child: Icon(Icons.add_box, color: const Color.fromARGB(255, 254, 172, 40), size: 35),
                        )
                      ]
                    ) : SizedBox()
                  ]
                ),

                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: h),
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: GestureDetector(
                          onTap: () {
                            deleteCategory(index);
                          },
                          child: Icon(Icons.delete, color: Colors.red,)
                        ),
                        trailing: Container(
                          child: goalIsEditable ? SizedBox(
                            width: w*0.25,
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: allottedBudget[index].toString(),
                                hintStyle: TextStyle(
                                  color: Colors.black,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0), // Adds rounded corners
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: const Color.fromARGB(0, 0, 0, 0)),
                                ),
                                border: OutlineInputBorder(),
                              ),
                              onSubmitted: (value) {
                                double updatedBudget = (value == "") ? 0 : double.parse(value);
                                updateBudget(updatedBudget, index);
                              },
                            )
                          ) : Text(
                            allottedBudget[index].toString(),
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Times',
                              fontWeight: FontWeight.w500 
                            ),
                          ),
                        ),
                        title: Container(
                          child: goalIsEditable ? SizedBox(
                            width: w*0.55,
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: categories[index],
                                hintStyle: TextStyle(
                                  color: Colors.black,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0), // Adds rounded corners
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: const Color.fromARGB(0, 0, 0, 0)),
                                ),
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  categories[index] = value;
                                });
                              },
                            )
                          ) : Text(
                            categories[index],
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Arial',
                              fontWeight: FontWeight.w500 
                            ),
                          ),
                        ),
                      );
                    }),
                )
         
              ],
            ),

            Divider(color: Colors.black,),

            SizedBox(height: 30),

            GestureDetector(
              onTap: () {
                storage.clear();
              },
              child: Row(
                children: [
                  Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 26, 
                    ),
                  ),
                  Icon(Icons.logout, size: 35,)
                ] 
              ),
            )
          ],
        )
      )
    );
  }
}