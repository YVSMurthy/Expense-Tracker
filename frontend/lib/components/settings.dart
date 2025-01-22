import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/pages/login.dart';
import 'package:frontend/storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:core';
import 'package:frontend/components/warning_dialogue.dart';
import 'package:frontend/components/add_category_popup.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  final storage = Storage();
  bool loading = true;
  String backendUri = "";

  String userId = "", name = " ", mobile = " ", password = " ";
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool profileIsEditable = false, showPassword = false;

  double monthlyBudget = 0.0;
  bool goalIsEditable = false;
  List<String> categories = [], categoriesCopy = [];
  List<double> allottedBudget = [], budgetCopy = [];
  double newBudget = 0;

  bool checkUpdates() {
    String namePattern = r'^[a-zA-Z ]+$';
    String mobilePattern = r'^[1-9][0-9]{9}$';
    String pwdPattern = r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,16}$';

    RegExp nameReg = RegExp(namePattern);
    RegExp mobileReg = RegExp(mobilePattern);
    RegExp pwdReg = RegExp(pwdPattern);

    if (!nameReg.hasMatch(nameController.text)) {
      if (mounted) {
        showWarningDialog(context, "Invalid Name", "Name should have only consist of alphabets");
      }
      return false;
    }
    if (!mobileReg.hasMatch(mobileController.text)) {
      if (mounted) {
        showWarningDialog(context, "Inavlid Mobile Number", "Please enter a valid 10-digit mobile number");
      }
      return false;
    }
    if (!pwdReg.hasMatch(passwordController.text)) {
      if (mounted) {
        showWarningDialog(context, "Password not in proper format", "Password should be of length 8 to 16, with atleast 1 of each uppercase character, lowercase character, special symbol, and digits");
      }
      return false;
    }

    return true;
  }

  String toTitleCase(String text) {
  if (text.isEmpty) return text;

  return text
      .split(' ')
      .map((word) => word.isNotEmpty
          ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
          : word)
      .join(' ');
}

  Future<void> updateProfile() async {
    // checking what all have been updated
    List<String> fields = [], values = [];
    int passwordUpdated = 0;
    // name has beem updated
    if (name != nameController.text) {
      fields.add("name = %s ");
      values.add(toTitleCase(nameController.text));
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

    if (fields.isNotEmpty) {
      try {
        // updating in database
        final uri = Uri.parse("$backendUri/update/updateProfile");
        final response = await http.post(uri,
          headers: {'Content-Type': 'application/json'},
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
  }

  void addCategory() async {
    var result = await showAddCategoryDialog(context);
    if (result != null) {
      if (mounted) {
        try {
          final uri = Uri.parse('$backendUri/update/addCategory');
          final response = await http.post(uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'user_id': userId,
              'cat_name': result['catName'],
              'allotted_budget': result['allottedAmount'],
              'monthly_budget': monthlyBudget
            })
          );

          final data = json.decode(response.body);

          if (response.statusCode == 200) {
            setState(() {
              categories.add(result['catName']);
              allottedBudget.add(result['allottedAmount']);
              monthlyBudget += result['allottedAmount'];
            });
          }
          else {
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
    }
  }

  void deleteCategory(int index) async {
    try {
      final uri = Uri.parse('$backendUri/update/deleteCategory');
      final response = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'cat_name': categories[index],
          'monthly_budget': monthlyBudget-allottedBudget[index]
        })
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        if (index >= 0 && index < categories.length) {
          setState(() {
            monthlyBudget -= allottedBudget[index];
            categories.removeAt(index);
            categoriesCopy.removeAt(index);
            allottedBudget.removeAt(index);
            budgetCopy.removeAt(index);
          });
        }
      }
      else {
        if (mounted) {
          showWarningDialog(context, data['title'], data['message']);
        }
      }
    } catch(error) {
      if (mounted) {
        showWarningDialog(context, "Error", "$error");
      }
    }
  }

  Future<void> updatedGoals() async {
    // checking if the goals have been edited
    bool categoryIsUpdated = false;
    bool budgetIsUpdated = false;

    for (int i = 0; i < categories.length; i++) {
      if (categories[i] != categoriesCopy[i]) {
        categoryIsUpdated = true;
        break;
      }
      if (allottedBudget[i] != budgetCopy[i]) {
        budgetIsUpdated = true;
        break;
      }
    }

    // update to database only if some changes have been made
    if (categoryIsUpdated || budgetIsUpdated) {
      Map<String, double> updatedBudgets = {};
      Map<String, String> updatedCategories = {};

      if (categoryIsUpdated) {
        for (int i = 0; i < categories.length; i++) {
          if (categories[i] != categoriesCopy[i]) {
            updatedCategories.addAll({categoriesCopy[i]: categories[i]});
          }
        }
      }
      if (budgetIsUpdated) {
        for (int i = 0; i < allottedBudget.length; i++) {
          if (allottedBudget[i] != budgetCopy[i]) {
            updatedBudgets.addAll({categoriesCopy[i]: allottedBudget[i]});
          }
        }
      }

      try {
        final updateGoalUri = Uri.parse("$backendUri/update/updateGoals");
        final response = await http.post(updateGoalUri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'user_id': userId,
            'updated_budget': updatedBudgets,
            'updated_categories': updatedCategories,
            'monthly_budget': monthlyBudget
          })
        );

        final data = json.decode(response.body);

        if (response.statusCode == 200) {
          setState(() {
            categoriesCopy = categories;
            budgetCopy = allottedBudget;
          });

          await storage.set('categories', json.encode(categories));
          await storage.set('allotted_budget', json.encode(allottedBudget));
        } else if (response.statusCode == 500) {
          if (mounted) {
            showWarningDialog(context, data['title'], data['message']);
          }
        }
      } catch(error) {
        if (mounted) {
          showWarningDialog(context, "Internal Server Error", error.toString());
        }
      }
    }
  }

  _loadDetails() async {
    backendUri = dotenv.env['BACKEND_URI']!;

    // loading profile details
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

    // goal related loading

    // check if the data is present in the storage, if not then fetch
    final storedMonthlyBudget = await storage.get('monthly_budget');
    if (storedMonthlyBudget == null) {
      final budgetUri = Uri.parse('$backendUri/update/getBudget');
      final budgetResponse = await http.post(budgetUri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId
        })
      );

      final budgetData = json.decode(budgetResponse.body);

      await storage.set('monthly_budget', budgetData['monthly_budget']);

      setState(() {
        monthlyBudget = double.parse(budgetData['monthly_budget']);
      });
    }
    else {
      setState(() {
        monthlyBudget = double.parse(storedMonthlyBudget);
      });
    }

    final storedCategories = await storage.get('categories');
    final storedBudget = await storage.get('allotted_budget');
    if (storedCategories == null || storedBudget == null) {
      final categoriesUri = Uri.parse('$backendUri/update/getCategories');
      final categoriesResponse = await http.post(categoriesUri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId
        })
      );

      final categoriesData = json.decode(categoriesResponse.body)['categories'];

      setState(() {
        for (int i = 0; i < categoriesData.length; i++) {
          categories.add(categoriesData[i][0]);
          categoriesCopy.add(categoriesData[i][0]);
          allottedBudget.add(double.parse(categoriesData[i][1]));
          budgetCopy.add(double.parse(categoriesData[i][1]));
        }
      });

      await storage.set('categories', json.encode(categories));
      await storage.set('allotted_budget', json.encode(allottedBudget));
    } else {
      setState(() {
        final decodedCategories = json.decode(storedCategories);
        final decodedBudget = json.decode(storedBudget);
        categories = List<String>.from(decodedCategories);
        categoriesCopy = List<String>.from(categories);
        allottedBudget = List<double>.from(decodedBudget);
        budgetCopy = List<double>.from(allottedBudget);
      });
    }

    setState(() {
      loading = false;
    });
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
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        child: (!loading) ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile part
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Profile",
                      style: TextStyle(
                        fontSize: 32,
                        fontFamily: 'Arial',
                        fontWeight: FontWeight.bold,
                      )
                    ),
                    SizedBox(width: 205),
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

                SizedBox(height: 10),

                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(36),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // color: Colors.purple.shade300
                        color: Colors.purple.shade400
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
                        SizedBox(
                          width: w*0.45, // Limit width
                          child: Text(
                            name,
                            style: TextStyle(
                              fontFamily: 'Times',
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                            overflow: TextOverflow.ellipsis,
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
                  ]
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

                SizedBox(
                  child: Column(
                    children: categories.asMap().entries.map((entry) {
                      final int index = entry.key;
                      final String category = entry.value;

                      return ListTile(
                        leading: !goalIsEditable
                            ? GestureDetector(
                                onTap: () {
                                  if (!goalIsEditable) {
                                    deleteCategory(index);
                                  }
                                },
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              )
                            : null,
                        trailing: Container(
                          child: goalIsEditable
                              ? SizedBox(
                                  width: w * 0.25,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: allottedBudget[index].toString(),
                                      hintStyle: const TextStyle(color: Colors.black),
                                      filled: true,
                                      fillColor: Colors.white,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0), // Rounded corners
                                        borderSide: const BorderSide(color: Colors.white),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Color.fromARGB(0, 0, 0, 0)),
                                      ),
                                      border: const OutlineInputBorder(),
                                    ),
                                    onSubmitted: (value) {
                                      setState(() {
                                        allottedBudget[index] = value.isEmpty
                                            ? allottedBudget[index]
                                            : double.parse(value);
                                        if (allottedBudget[index] != budgetCopy[index]) {
                                          monthlyBudget = monthlyBudget -
                                              allottedBudget[index] +
                                              budgetCopy[index];
                                        }
                                      });
                                    },
                                  ),
                                )
                              : Text(
                                  allottedBudget[index].toString(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'Times',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                        title: Container(
                          child: goalIsEditable
                              ? SizedBox(
                                  width: w * 0.55,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: category,
                                      hintStyle: const TextStyle(color: Colors.black),
                                      filled: true,
                                      fillColor: Colors.white,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0), // Rounded corners
                                        borderSide: const BorderSide(color: Colors.white),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Color.fromARGB(0, 0, 0, 0)),
                                      ),
                                      border: const OutlineInputBorder(),
                                    ),
                                    onSubmitted: (value) {
                                      setState(() {
                                        categories[index] = value.isEmpty
                                            ? categories[index]
                                            : value;
                                      });
                                    },
                                  ),
                                )
                              : Text(
                                  category,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'Arial',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              ],
            ),

            Divider(color: Colors.black,),

            SizedBox(height: 30),

            GestureDetector(
              onTap: () {
                storage.clear();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Login())
                );
              },
              child: Row(
                children: [
                  SizedBox(width: 10),
                  Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 26, 
                    ),
                  ),
                  SizedBox(width: 10,),
                  Icon(Icons.logout, size: 32,)
                ] 
              ),
            ),

            SizedBox(height: 60,),
          ],
        ) : SizedBox(
          width: w,
          height: h*0.75,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        )
      )
    );
  }
}