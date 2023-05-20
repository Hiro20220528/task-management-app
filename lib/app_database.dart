import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:task_management/history.dart';
import 'package:task_management/task.dart';

class AppDatabase {
  static Future<Database> get database async {
    Future<Database> database = openDatabase(
      join(await getDatabasesPath(), 'app_database.db'),
      onCreate: (db, version) async {
        await db.execute(
          // keyは削除に使う
          'CREATE TABLE task(id INTEGER PRIMARY KEY, key INTEGER, text TEXT, priority INTEGER)',
        );
        // done は終わった数, allは全タスク数
        await db.execute(
          'CREATE TABLE history(id INTEGER PRIMARY KEY, done INTEGER, number INTEGER)',
        );
      },
      version: 1,
    );
    return database;
  }

  static Future<void> addTask(Task task) async {
    final Database db = await database;
    await db.insert(
      'task',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Task>> getTask() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.rawQuery('SELECT * FROM task');

    // map -> Task classに変換
    return List.generate(
      maps.length,
      (i) {
        return Task(
          id: maps[i]['id'],
          key: maps[i]['key'],
          text: maps[i]['text'],
          priority: maps[i]['priority'],
        );
      },
    );
  }

  static Future<void> removeTask(int id) async {
    final Database db = await database;
    await db.delete(
      'task',
      where: "key = ?",
      whereArgs: [id],
    );
  }

  static Future<void> addHistory(History history) async {
    final Database db = await database;
    // 日付の差分だけ追加する
    await db.insert(
      'history',
      history.toAllMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> initialHistory(History history) async {
    final Database db = await database;
    // 日付の差分だけ追加する
    await db.insert(
      'history',
      history.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<History>> getAllHistory() async {
    final Database db = await database;
    // 一番新しい84件の履歴を取得する
    final List<Map<String, dynamic>> maps =
        await db.rawQuery('SELECT * FROM history ORDER BY id DESC LIMIT 84');

    // map -> Task classに変換
    return List.generate(
      maps.length,
      (i) {
        return History(
          id: maps[i]['id'],
          done: maps[i]['done'],
          number: maps[i]['number'],
        );
      },
    );
  }

  static Future<History> getHistory() async {
    final Database db = await database;
    // 一番新しい履歴を取得する
    final List<Map<String, dynamic>> maps =
        await db.rawQuery('SELECT * FROM history ORDER BY id DESC LIMIT 1');

    return History(
      id: maps[0]['id'],
      done: maps[0]['done'],
      number: maps[0]['number'],
    );
  }
  //
  // static Future<void> renewAchievement(int id, double i) async {
  //   final Database db = await database;
  //   var achievement = {'id': id, 'achievement': i};
  //   await db.insert(
  //     'history',
  //     achievement,
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }
  //

  static Future<String> getLogInDay() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('log-in-day') ?? '-';
  }

  static Future<void> logIn(String login) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('log-in-day', login);
  }
}
