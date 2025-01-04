import 'package:flutter/material.dart';
import 'package:frontend/components/home.dart';
import 'package:frontend/components/transaction_history.dart';
import 'package:frontend/components/add_record.dart';
import 'package:frontend/components/settings.dart';
import 'package:frontend/components/dues.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  int currIndex = 0;

  List<Widget> pages = [
    Dues(),
    TransactionHistory(),
    Home(),
    AddRecord(),
    Settings(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.fromLTRB(20, 60, 20, 0),
        child: pages[currIndex]
      ),
      
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currIndex = index;
          });
        },
        indicatorColor: const Color.fromARGB(255, 255, 213, 89),
        selectedIndex: currIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.monetization_on_rounded),
            icon: Icon(Icons.monetization_on_outlined),
            label: 'Due',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.history),
            icon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.add_box),
            icon: Icon(Icons.add_box_outlined),
            label: 'Add Record',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      )
    );
  }
}