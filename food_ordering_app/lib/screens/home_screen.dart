import 'package:flutter/material.dart';
import '../helpers/food_items_db_helper.dart';
import '../models/food_item.dart';
import '../models/order_plan.dart';
import 'order_screen.dart';

class HomeScreen extends StatefulWidget {
  final OrderPlan? orderPlan;
  HomeScreen({this.orderPlan});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dbHelper = FoodItemsDBHelper.instance;
  List<FoodItem> foodItems = [];
  List<FoodItem> selectedItems = [];
  double targetCost = 20.0;
  double totalCost = 0.0;
  DateTime selectedDate = DateTime.now();
  TextEditingController? _targetCostController; //controller for target cost input

  @override
  void initState() {
    super.initState();
    if (widget.orderPlan != null) {
      targetCost = (widget.orderPlan?.targetCost != null)
          ? widget.orderPlan!.targetCost
          : targetCost;
      selectedDate = (widget.orderPlan?.date != null)
          ? widget.orderPlan!.date!
          : DateTime.now();
      selectedItems = (widget.orderPlan?.foodItems != null)
          ? (widget.orderPlan?.foodItems as List<dynamic>).map((item) => FoodItem.fromMap(item)).toList()
          : [];
    }
    _targetCostController = TextEditingController(text: targetCost.toStringAsFixed(2));
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    await dbHelper.database;
    _loadFoodItems();
  }

  Future<void> _loadFoodItems() async {
    debugPrint('Querying food items...');
    final allRows = await dbHelper.queryAllRows();
    debugPrint('Loading food items...');
    setState(() {
      foodItems = allRows.map((row) => FoodItem.fromMap(row)).toList();
    });
    debugPrint('Loaded food items: $foodItems');
  }

  void _toggleSelection(FoodItem item) {
    setState(() {
      if (selectedItems.contains(item)) {
        selectedItems.remove(item);
        totalCost -= item.cost;
      } else {
        if (totalCost + item.cost <= targetCost) {
          selectedItems.add(item);
          totalCost += item.cost;
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Adding this item will exceed the target cost!')
          ));
        }
      }
    });
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2010),
        lastDate: DateTime(2100)
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _saveOrderPlan() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrderScreen(
          selectedItems: selectedItems,
          targetCost: targetCost,
          totalCost: totalCost,
          selectedDate: selectedDate,
          orderPlan: widget.orderPlan,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Ordering App'),
      ),
      body: Column(
        children: [
          Padding( //TARGET COST INPUT
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _targetCostController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target Cost',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                targetCost = double.tryParse(value) ?? 0.0;
              },
            ),
          ),
          Padding( //DATE INPUT
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Selected Date',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(
                      text: "${selectedDate.toLocal()}".split(' ')[0]
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: foodItems.length,
              itemBuilder: (context, index) {
                final item = foodItems[index];
                return ListTile(
                  title: Text('${item.name} - \$${item.cost.toStringAsFixed(2)}'),
                  trailing: Checkbox(
                    value: selectedItems.contains(item),
                    onChanged: (value) {
                      _toggleSelection(item);
                    },
                  ),
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
            child: ElevatedButton(
              onPressed: _saveOrderPlan,
              child: const Text('Save Order Plan'),
            ),
          ),
        ],
      ),
    );
  }
}
