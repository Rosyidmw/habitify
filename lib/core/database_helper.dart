import 'package:habitify/models/habit_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('habitify_v2.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE habits (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      target_minutes INTEGER NOT NULL,
      created_at TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE habit_history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      habit_id INTEGER NOT NULL,
      date_record TEXT NOT NULL, 
      FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE
    )
    ''');
  }

  Future<int> create(Habit habit) async {
    final db = await instance.database;

    final map = habit.toMap();
    map.remove('is_completed');
    return await db.insert('habits', map);
  }

  Future<List<Habit>> readAllHabits() async {
    final db = await instance.database;
    final result = await db.query('habits', orderBy: 'created_at DESC');

    return result.map((json) {
      final mutableJson = Map<String, dynamic>.from(json);
      mutableJson['is_completed'] = 0;
      return Habit.fromMap(mutableJson);
    }).toList();
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> isHabitCompletedToday(int habitId, String dateStr) async {
    final db = await instance.database;
    final result = await db.query(
      'habit_history',
      where: 'habit_id = ? AND date_record = ?',
      whereArgs: [habitId, dateStr],
    );
    return result.isNotEmpty;
  }

  Future<void> toggleHabitHistory(int habitId, String dateStr) async {
    final db = await instance.database;

    final isExist = await isHabitCompletedToday(habitId, dateStr);

    if (isExist) {
      await db.delete(
        'habit_history',
        where: 'habit_id = ? AND date_record = ?',
        whereArgs: [habitId, dateStr],
      );
    } else {
      await db.insert('habit_history', {
        'habit_id': habitId,
        'date_record': dateStr,
      });
    }
  }

  Future<Map<String, int>> getHistoryInRange(
    String startDate,
    String endDate,
  ) async {
    final db = await instance.database;

    final result = await db.rawQuery(
      '''
      SELECT date_record, COUNT(*) as total
      FROM habit_history
      WHERE date_record BETWEEN ? AND ?
      GROUP BY date_record
    ''',
      [startDate, endDate],
    );

    final Map<String, int> stats = {};
    for (var row in result) {
      stats[row['date_record'] as String] = row['total'] as int;
    }
    return stats;
  }
}
