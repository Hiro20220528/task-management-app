import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:task_management/app_database.dart';
import 'package:task_management/task.dart';
import 'package:task_management/history.dart';

class AppProvider extends ChangeNotifier {
  int priority = 0;
  List<Task> taskList = [];

  // 達成度の初期化
  var historyList = List.generate(84, (i) => 0.1);

  // アプリ実行時、これまでのタスクと達成度を取得する
  Future<void> initialize() async {
    taskList = await AppDatabase.getTask();
    await getAllHistory();
  }

  void tapRadio(int value) {
    priority = value;
    notifyListeners();
  }

  void resetRadioPriority() {
    priority = 0;
  }

  // タスク追加時、実行することは、タスクをデータベースに追加、タスクの数をデータベースに追加
  Future<void> addTaskProvider(String text, int priority) async {
    Task newTask = Task(
      id: 0, // idは自動的に追加されるため適当にする
      key: taskList.length + 1,
      text: text,
      priority: priority,
    );
    await AppDatabase.addTask(newTask);
    await getTaskProvider();
  }

  Future<void> getTaskProvider() async {
    taskList = await AppDatabase.getTask();
    notifyListeners();
  }

  Future<void> removeTaskProvider(int index) async {
    await AppDatabase.removeTask(index);
    await getTaskProvider();
    await addHistoryDone();
    notifyListeners();
  }

  // 履歴を取得する際は、historyListと結合する
  Future<void> getAllHistory() async {
    List<History> dbHistoryList = await AppDatabase.getAllHistory();
    double result;
    for (int i = 0; i < dbHistoryList.length; i++) {
      if (dbHistoryList[i].done > 0 && dbHistoryList[i].number > 0) {
        result = dbHistoryList[i].done / dbHistoryList[i].number;
      } else {
        result = 0.1;
      }
      historyList[i] = result;
    }
  }

  Future<void> addHistoryNumber() async {
    History dbHistory = await AppDatabase.getHistory();
    dbHistory.number += 1;
    await AppDatabase.addHistory(dbHistory);
    await AppDatabase.getAllHistory();
    notifyListeners();
  }

  Future<void> addHistoryDone() async {
    History dbHistory = await AppDatabase.getHistory();
    dbHistory.done += 1;
    await AppDatabase.addHistory(dbHistory);
    await AppDatabase.getAllHistory();
    notifyListeners();
  }

  // todo numberOfTask and achievement をリセットされる
  static Future<void> checkLogIn() async {
    // 前回ログインと日付が違う場合、日付を更新する
    DateTime now = DateTime.now();
    DateFormat outputFormat = DateFormat('yyyy-MM-dd');
    String date = outputFormat.format(now);
    String logInDay = await getLogInDayProvider();
    //　新しいログイン日
    if (date != logInDay) {
      History history = History(id: 0, done: 0, number: 0);
      // 初めてのログイン日
      if (logInDay != '-') {
        // 日付の差分だけデータベースを更新する
        var last = DateTime.parse(date);
        var today = DateTime.parse(logInDay);
        var dif = today.difference(last).inDays;
        // print('dif: $dif');
        if (dif > 0) {
          for (int i = 0; i < dif; i++) {
            await AppDatabase.initialHistory(history);
          }
        }
      } else {
        // print('!= lao in day');
        await AppDatabase.initialHistory(history);
      }
      await logInProvider(date);
    }
  }

  static Future<String> getLogInDayProvider() async {
    return await AppDatabase.getLogInDay();
  }

  static Future<void> logInProvider(String date) async {
    await AppDatabase.logIn(date);
  }
}
