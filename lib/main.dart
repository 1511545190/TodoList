import 'package:flutter/material.dart';
import 'package:oppowatch/utils/MyDataBase.dart';
import 'page/HomePage.dart';
//main
Future<void> main()  async {

  //初始化数据库单例
  // 初始化数据库
  // 确保 WidgetsFlutterBinding 已经初始化
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 初始化数据库
    await MyDataBase().database;
    print('Database initialized successfully');
  } catch (e) {
    print('Error initializing database: $e');
  }

  runApp(MaterialApp(
    home: Scaffold(
      body: Homepage(),
    ),
  ));
}