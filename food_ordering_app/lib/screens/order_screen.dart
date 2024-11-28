import 'package:flutter/material.dart';
import '../helpers/order_plans_db_helper.dart';
import '../models/food_item.dart';
import '../models/order_plan.dart';
import 'dart:convert';

class OrderScreen extends StatelessWidget {
  final List<FoodItem> selectedItems;
  final double targetCost;
  final double totalCost;
  final DateTime selectedDate;
  final OrderPlan? orderPlan; //used for existing orders
  final dbHelper = OrderPlansDBHelper.instance;

  OrderScreen({required this.selectedItems, required this.targetCost, required this.totalCost, required this.selectedDate, this.orderPlan});

  void _saveOrderPlanToDB(BuildContext context) async {
    final String date = selectedDate.toIso8601String();
    final String foodItemsJson = jsonEncode(
        selectedItems.map((item) => item.toMap()).toList());
    if (orderPlan != null) { // Update existing order
      await dbHelper.update({
        'id': orderPlan!.id,
        'date': date,
        'target_cost': targetCost,
        'food_items': foodItemsJson,
        'total_cost': totalCost
      });
    } else { // Insert new order
      await dbHelper.insert({
        'date': date,
        'target_cost': targetCost,
        'food_items': foodItemsJson,
        'total_cost': totalCost
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order plan saved successfully!')));
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    double totalCost = selectedItems.fold(0, (sum, item) => sum + item.cost);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Plan'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Selected Food Items:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: selectedItems.length,
              itemBuilder: (context, index) {
                final item = selectedItems[index];
                return ListTile(
                  title: Text('${item.name} - \$${item.cost}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Total Cost: \$${totalCost.toStringAsFixed(2)}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Selected Date: ${selectedDate.toLocal()}'.split(' ')[0]),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => _saveOrderPlanToDB(context),
              child: const Text('Confirm and Save Order Plan'),
            ),
          ),
        ],
      ),
    );
  }
}
