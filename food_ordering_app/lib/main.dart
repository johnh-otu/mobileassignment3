import 'package:flutter/material.dart';
import 'package:food_ordering_app/screens/order_plans_screen.dart';

void main() {
  debugPrint("Starting app...");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ordering App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: OrderPlansScreen(),
    );
  }
}
