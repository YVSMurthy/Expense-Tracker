import 'package:flutter/material.dart';
import 'package:frontend/pages/login.dart';
import 'package:frontend/pages/dashboard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  ExpenseTracker createState() => ExpenseTracker();
}

class ExpenseTracker extends State<MyApp> {
  String? token;
  bool loading = true;  // Add loading state

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    await Future.delayed(Duration(seconds: 2));

    final storage = Storage();
    final storedToken = await storage.get('user_id');

    setState(() {
      token = storedToken;
      loading = false;  // Stop loading when the token is checked
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: loading
          ? Scaffold(
              body: Center(
                child: CircularProgressIndicator(),  // Show loader while loading
              ),
            )
          : (token != null) 
              ? Dashboard()  // Navigate to dashboard if token exists
              : Login(),  // Navigate to login if no token
    );
  }
}