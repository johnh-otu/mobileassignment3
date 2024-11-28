import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:food_ordering_app/helpers/food_items_db_helper.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class OrderPlansDBHelper {
  static const _databaseName = "FoodDatabase.db";
  static const _databaseVersion = 1;

  static const table = 'order_plans';

  static final columnId = '_id';
  static final columnDate = 'date';
  static final columnTargetCost = 'target_cost';
  static final columnTotalCost = 'total_cost';
  static final columnFoodItems = 'food_items'; //stored as JSON string

  OrderPlansDBHelper._privateConstructor();
  static final OrderPlansDBHelper instance = OrderPlansDBHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnDate TEXT NOT NULL,
            $columnTargetCost REAL NOT NULL,
            $columnFoodItems TEXT NOT NULL,
            $columnTotalCost REAL NOT NULL
          )
          ''');
    await db.execute('''
          CREATE TABLE ${FoodItemsDBHelper.table} (
            ${FoodItemsDBHelper.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${FoodItemsDBHelper.columnName} TEXT NOT NULL,
            ${FoodItemsDBHelper.columnCost} REAL NOT NULL
          )
          ''');
    debugPrint("Created Tables");
    FoodItemsDBHelper helper = FoodItemsDBHelper.instance;
    await helper.seedDatabase(db);
    debugPrint("Seeded DB");
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
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

  Future<List<Map<String, dynamic>>> queryRowsByDate(DateTime date) async {
    Database db = await instance.database;
    String formattedDate = date.toIso8601String().split('T')[0];
    return await db.query(
      table, where: '$columnDate LIKE ?', whereArgs: ['$formattedDate%'],
    );
  }
}
