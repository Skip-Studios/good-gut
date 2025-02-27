import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/produce_item.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'good_gut.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE produce_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        category TEXT,
        dateAdded TEXT
      )
    ''');
  }

  Future<int> insertProduce(ProduceItem item) async {
    final db = await database;
    return await db.insert(
      'produce_items',
      {
        'name': item.name,
        'category': item.category,
        'dateAdded': item.dateAdded.toIso8601String(),
      },
    );
  }

  Future<List<ProduceItem>> getProduceForDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final List<Map<String, dynamic>> maps = await db.query(
      'produce_items',
      where: 'dateAdded >= ? AND dateAdded < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );

    return List.generate(maps.length, (i) {
      return ProduceItem(
        name: maps[i]['name'],
        category: maps[i]['category'],
        dateAdded: DateTime.parse(maps[i]['dateAdded']),
      );
    });
  }

  Future<List<ProduceItem>> getProduceForDateRange(
      DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'produce_items',
      where: 'dateAdded >= ? AND dateAdded < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );

    return List.generate(maps.length, (i) {
      return ProduceItem(
        name: maps[i]['name'],
        category: maps[i]['category'],
        dateAdded: DateTime.parse(maps[i]['dateAdded']),
      );
    });
  }

  Future<void> deleteProduce(ProduceItem item) async {
    final db = await database;
    await db.delete(
      'produce_items',
      where: 'name = ? AND dateAdded = ?',
      whereArgs: [item.name, item.dateAdded.toIso8601String()],
    );
  }
}
