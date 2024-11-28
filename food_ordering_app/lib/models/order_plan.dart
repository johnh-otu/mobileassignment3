import 'dart:convert';

import 'package:food_ordering_app/models/food_item.dart';

class OrderPlan {
  final int? id;
  final DateTime? date;
  final double targetCost;
  final List<FoodItem> foodItems; //stored in db as JSON string
  final double totalCost;


  OrderPlan({this.id, this.date, required this.targetCost, required this.foodItems, this.totalCost = 0.0});

  Map<String, dynamic> toMap() {
    if (id == null) {
      return {
        'date': date.toString(),
        'target_cost': targetCost,
        //'food_items': jsonEncode(foodItems)
        'food_items': jsonEncode(foodItems.map((item) => item.toMap()).toList()),
        'total_cost': totalCost
      };
    }
    return {
      'id': id,
      'date': date.toString(),
      'target_cost': targetCost,
      //'food_items': jsonEncode(foodItems)
      'food_items': jsonEncode(foodItems.map((item) => item.toMap()).toList()),
      'total_cost': totalCost
    };
  }

  factory OrderPlan.fromMap(Map<String, dynamic> map) {
    return OrderPlan(
      id: map['id'],
      date: DateTime.tryParse(map['date']),
      targetCost: map['target_cost'],
      //foodItems: jsonDecode(map['food_items']).cast<List<FoodItem>>()
        foodItems: (jsonDecode(map['food_items']) as List<dynamic>)
            .map((item) => FoodItem.fromMap(item))
            .toList(),
      totalCost: map['total_cost'],
    );
  }
}