import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:food_ordering_app/helpers/order_plans_db_helper.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class FoodItemsDBHelper {
  static const _databaseName = "FoodDatabase.db";
  static const _databaseVersion = 1;

  static const table = 'food_items';

  static final columnId = '_id';
  static final columnName = 'name';
  static final columnCost = 'cost';

  FoodItemsDBHelper._privateConstructor();
  static final FoodItemsDBHelper instance = FoodItemsDBHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) { return _database!; }
    debugPrint("Initializing Database...");
    _database = await _initDatabase();
    debugPrint("Database Initialized.");
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    debugPrint("Got database");
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnName TEXT NOT NULL,
            $columnCost REAL NOT NULL
          )
          ''');
    await db.execute('''
          CREATE TABLE ${OrderPlansDBHelper.table} (
            ${OrderPlansDBHelper.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${OrderPlansDBHelper.columnDate} TEXT NOT NULL,
            ${OrderPlansDBHelper.columnTargetCost} REAL NOT NULL,
            ${OrderPlansDBHelper.columnFoodItems} TEXT NOT NULL,
            ${OrderPlansDBHelper.columnTotalCost} REAL NOT NULL
          )
          ''');
    debugPrint("Created Tables");
    await seedDatabase(db);
    debugPrint("Seeded DB");
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    debugPrint("Loading Database...");
    Database db = await instance.database;
    debugPrint("Database Loaded.");
    return await db.query(table);
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future seedDatabase(Database db) async {
    List<Map<String, dynamic>> foodItems = [
      {'name': 'Pizza', 'cost': 10.0},
      {'name': 'Burger', 'cost': 7.0},
      {'name': 'Pasta', 'cost': 8.5},
      {'name': 'Salad', 'cost': 5.5},
      {'name': 'Sushi', 'cost': 12.0},
      {'name': 'Sandwich', 'cost': 6.0},
      {'name': 'Soup', 'cost': 4.0},
      {'name': 'Steak', 'cost': 15.0},
      {'name': 'Tacos', 'cost': 9.0},
      {'name': 'Burrito', 'cost': 9.5},
      {'name': 'Ice Cream', 'cost': 3.5},
      {'name': 'Cake', 'cost': 4.5},
      {'name': 'Fries', 'cost': 2.5},
      {'name': 'Hot Dog', 'cost': 5.0},
      {'name': 'Nachos', 'cost': 6.5},
      {'name': 'Donut', 'cost': 1.5},
      {'name': 'Smoothie', 'cost': 4.0},
      {'name': 'Coffee', 'cost': 2.0},
      {'name': 'Tea', 'cost': 1.5},
      {'name': 'Juice', 'cost': 3.0}
    ];

    for(var item in foodItems) {
      await db.insert(table, item);
      debugPrint('Inserted: ${item['name']}');
    }

    debugPrint("Food items seeded successfully.");
  }
}
