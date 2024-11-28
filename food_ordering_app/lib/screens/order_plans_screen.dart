import 'package:flutter/material.dart';
import '../helpers/order_plans_db_helper.dart';
import '../models/order_plan.dart';
import 'home_screen.dart';

class OrderPlansScreen extends StatefulWidget {
  @override
  _OrderPlansScreenState createState() => _OrderPlansScreenState();
}

class _OrderPlansScreenState extends State<OrderPlansScreen> {
  final dbHelper = OrderPlansDBHelper.instance;
  List<OrderPlan> orderPlans = [];

  @override
  void initState() {
    super.initState();
    _loadOrderPlans();
  }

  Future<void> _loadOrderPlans() async {
    await OrderPlansDBHelper.instance;
    final allRows = await dbHelper.queryAllRows();
    setState(() {
      orderPlans = allRows.map((row) => OrderPlan.fromMap(row)).toList();
      print('Loaded order plans: ${orderPlans.map((plan) => plan.date).toList()}');
    });
  }

  void _deleteOrderPlan(int id) async {
    debugPrint("deleting order plan ID=$id");
    await dbHelper.delete(id);
    _loadOrderPlans();
  }

  void _updateOrderPlan(OrderPlan orderPlan) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(orderPlan: orderPlan)),
    ).then((_) {
      _loadOrderPlans();
    });
  }

  void _createOrder() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    ).then((_) {
      _loadOrderPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Plans'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: orderPlans.length,
              itemBuilder: (context, index) {
                final orderPlan = orderPlans[index];
                return ListTile(
                  title: Text('Date: ${orderPlan.date}, Total Cost: \$${orderPlan.totalCost.toStringAsFixed(2)}'),
                  //subtitle: Text('Items: ${orderPlan.foodItems}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _updateOrderPlan(orderPlan),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteOrderPlan(orderPlan.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _createOrder,
              child: Text('Create Order'),
            ),
          ),
        ],
      ),
    );
  }
}
