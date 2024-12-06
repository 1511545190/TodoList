import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
//notice: ChangeNotifier is a class in flutter, it is used to notify the UI to update when the data changes
class MyDataBase {
  // 单例模式：确保只有一个实例
  static final MyDataBase _instance = MyDataBase._internal();
  static Database? _database;

  // 私有构造函数，防止外部实例化
  MyDataBase._internal();

  // 工厂构造函数，返回单例实例
  factory MyDataBase() {
    return _instance;
  }

  // 获取数据库实例的方法
  Future<Database> get database async {
    if (_database != null) return _database!;

    // 如果数据库实例为空，则进行初始化
    _database = await _initDatabase();
    return _database!;
  }

  //使用sql语句删除所有表
  Future<void> deleteAllTables() async {
    final db = await this.database;
    await db.transaction((txn) async {
      await txn.rawDelete('DROP TABLE Task');
      await txn.rawDelete('DROP TABLE Record');
      await txn.rawDelete('DROP TABLE User');
      await txn.rawDelete('DROP TABLE Todo');
    });
    log('All tables deleted');
  }
  // 初始化数据库的方法
  Future<Database> _initDatabase() async {
    try {
      // 获取数据库路径
      var databasesPath = await getDatabasesPath();
      log('databasesPath: $databasesPath');

      // 打开或创建数据库
      Database db = await openDatabase('Todo.db', version: 1,
          onCreate: (Database db, int version) async {
            // 创建表
            await db.transaction((txn) async {
              // 任务表
              await txn.execute('''
                CREATE TABLE IF NOT EXISTS Task (
                  TaskID INTEGER PRIMARY KEY AUTOINCREMENT,
                  title TEXT NOT NULL,
                  description TEXT NOT NULL
                )
              ''');

              // 完成记录表
              await txn.execute('''
                CREATE TABLE IF NOT EXISTS Record (
                  RecordID INTEGER PRIMARY KEY AUTOINCREMENT,
                  title TEXT NOT NULL,
                  StartTime TEXT NOT NULL,
                  EndTime TEXT NOT NULL
                )
              ''');

              // 用户表
              await txn.execute('''
                CREATE TABLE IF NOT EXISTS User (
                  UserID INTEGER PRIMARY KEY AUTOINCREMENT,
                  UserName TEXT NOT NULL,
                  Password TEXT NOT NULL
                )
              ''');

              //Todo表
              await txn.execute('''
                CREATE TABLE IF NOT EXISTS Todo (
                  TodoID INTEGER PRIMARY KEY AUTOINCREMENT,
                  title TEXT NOT NULL,
                  StartTime TEXT NOT NULL
                )
              ''');
              log('4 tables created successfully');
            });
          });

      log('db path: ${db.path}');
      return db;
    } catch (e) {
      log('Error initializing database: $e');
      rethrow;
    }
  }
  //重新建表
  Future<void> reCreateTable() async {
    final db = await this.database;
    await db.transaction((txn) async {
      await txn.rawDelete('DROP TABLE Task');
      await txn.rawDelete('DROP TABLE Record');
      await txn.rawDelete('DROP TABLE User');
      // await txn.rawDelete('DROP TABLE Todo');
    });
    await db.transaction((txn) async {
      // Task表(TaskID,title,description)
      await txn.execute('''
                CREATE TABLE IF NOT EXISTS Task (
                  TaskID INTEGER PRIMARY KEY AUTOINCREMENT,
                  title TEXT NOT NULL,
                  description TEXT NOT NULL
                )
              ''');

      // Record表(RecordID,title,StartTime,EndTime)
      await txn.execute('''
                CREATE TABLE IF NOT EXISTS Record (
                  RecordID INTEGER PRIMARY KEY AUTOINCREMENT,
                  title TEXT NOT NULL,
                  StartTime TEXT NOT NULL,
                  EndTime TEXT NOT NULL
                )
              ''');

      // 用户表
      await txn.execute('''
                CREATE TABLE IF NOT EXISTS User (
                  UserID INTEGER PRIMARY KEY AUTOINCREMENT,
                  UserName TEXT NOT NULL,
                  Password TEXT NOT NULL
                )
              ''');

      //Todo表(TodoID,title,starttime)
      await txn.execute('''
                CREATE TABLE IF NOT EXISTS Todo (
                  TodoID INTEGER PRIMARY KEY AUTOINCREMENT,
                  title TEXT NOT NULL,
                  StartTime TEXT NOT NULL
                )
              ''');

      log('4 tables created successfully');
    });
  }

  // 查询所有任务
  Future<List<Map<String, dynamic>>> queryAllTasks() async {
    final db = await this.database;
    List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * FROM Task');
    log('queryAllTasks complete');
    return maps;
  }

  // 插入任务
  Future<void> insertTask(String title, String description) async {
    final db = await this.database;
    await db.transaction((txn) async {
      await txn.rawInsert(
        'INSERT INTO Task(title, description) VALUES(?, ?)',
        [title, description],
      );
    });
    log('Task inserted: $title, $description');
  }

  // 删除任务
  Future<void> deleteTask(int taskId) async {
    final db = await this.database;
    await db.transaction((txn) async {
      await txn.rawDelete('DELETE FROM Task WHERE TaskID = ?', [taskId]);
    });
    log('Task deleted: $taskId');
  }

  // 删除所有任务
  Future<void> deleteAllTasks() async {
    final db = await this.database;
    await db.transaction((txn) async {
      await txn.rawDelete('DELETE FROM Task');
    });
    log('All tasks deleted');
  }

  // 删除recordbyRecordID
  Future<void> deleteRecord(int recordId) async {
    final db = await this.database;
    await db.transaction((txn) async {
      await txn.rawDelete('DELETE FROM Record WHERE RecordID = ?', [recordId]);
    });
    log('Record deleted: $recordId');
  }

  // 插入完成记录
  Future<void> InsertRecord(String title, String StartTime, String EndTime) async {
    final db = await this.database;
    await db.transaction((txn) async {
      await txn.rawInsert(
        'INSERT INTO Record(title, StartTime, EndTime) VALUES(?, ?, ? )',
        [title,StartTime , EndTime],
      );
    });

    // 打印所有完成的任务
    List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * FROM Record');
    for (var item in maps) {
      log('Record: ${item.toString()}');
    }
  }

  // 查询所有完成记录
  Future<List<Map<String, dynamic>>> queryAllRecords() async {
    final db = await this.database;
    List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * FROM Record');
    log('queryAllRecords complete');
    return maps;
  }


  //insert Task to TodoTable
  Future<void> insertTodoTask(String title, String StartTime) async {
    final db = await this.database;
    await db.transaction((txn) async {
      await txn.rawInsert(
        'INSERT INTO Todo(title, StartTime) VALUES(?, ?)',
        [title, StartTime],
      );
    });
    log('Task inserted: $title, $StartTime');
  }

  //query all todoTasks
  Future<List<Map<String, dynamic>>> queryAllTodoTasks() async {
    final db = await this.database;
    List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * FROM Todo');
    log('queryAllTodoTasks complete');
    return maps;
  }

  //delete todoTask by id
  Future<void> deleteTodoTask(int todoId) async {
    final db = await this.database;
    await db.transaction((txn) async {
      await txn.rawDelete('DELETE FROM Todo WHERE TodoID = ?', [todoId]);
    });
    log('TodoTask deleted: $todoId');
  }







  //delete all records
  Future<void> deleteAllRecords() async {
    final db = await this.database;
    await db.transaction((txn) async {
      await txn.rawDelete('DELETE FROM Record');
    });
    log('All records deleted');
  }

  //query single task
  Future<Map<String, dynamic>> queryTask(int taskId) async {
    final db = await this.database;
    List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * FROM Task WHERE TaskID = ?', [taskId]);
    log('queryTask complete');
    return maps[0];
  }
  //query single record
  Future<Map<String, dynamic>> queryRecord(int recordId) async {
    final db = await this.database;
    List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * FROM Record WHERE RecordID = ?', [recordId]);
    log('queryRecord complete');
    return maps[0];
  }



}