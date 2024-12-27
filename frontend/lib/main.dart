import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/pages/login.dart';
import 'package:frontend/pages/dashboard.dart';
import 'package:frontend/pages/signup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  ExpenseTracker createState() => ExpenseTracker();
}

class ExpenseTracker extends State<MyApp> {
  final storage = FlutterSecureStorage();
  String? token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final storedToken = await storage.read(key: 'auth_token');

    setState(() {
      token = storedToken;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: (token != null) ? Dashboard() : Signup(),
    );
  }
}