import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._internal();
  Database? _db;

  DBHelper._internal();

  Future<Database> get db async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'trivia_trail.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE progress(
        levelId INTEGER PRIMARY KEY,
        completed INTEGER NOT NULL,
        bestScore INTEGER NOT NULL
      )
    ''');
  }

  Future<void> upsertProgress(int levelId, bool completed, int score) async {
    final database = await db;
    await database.insert(
      'progress',
      {
        'levelId': levelId,
        'completed': completed ? 1 : 0,
        'bestScore': score,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<int, int>> getBestScores() async {
    final database = await db;
    final rows = await database.query('progress');
    return {
      for (final row in rows) row['levelId'] as int: row['bestScore'] as int,
    };
  }
}
