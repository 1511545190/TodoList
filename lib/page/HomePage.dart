import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oppowatch/page/AddTask.dart';
import 'package:oppowatch/page/ShowRecords.dart';
import 'package:oppowatch/page/ShowTasks.dart';
import 'package:oppowatch/utils/MyDataBase.dart';
import '';

//step 1 import database
import 'package:sqflite/sqflite.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<Map> TodoTasks = [];

  //在initState之前调用的方法
  @override
  @override
  void initState() {
    super.initState();
    //step 2 create database
    //当数据库创建完成后，查询所有任务
    // query all tasks
    MyDataBase().queryAllTodoTasks().then((value) {
      setState(() {
        TodoTasks = value;
      });
    });

    //query all tasks,当数据库操作完成后，会调用setState方法，刷新页面，value是查询到的数据

    // //删除所有Record
    // MyDataBase().deleteAllRecords();
    // //删除所有Task
    // MyDataBase().deleteAllTasks();
    // //删除所有Table
    // MyDataBase().deleteAllTables();
    // //创建Table
    // MyDataBase().reCreateTable();
  }

  @override
  Widget build(BuildContext context) {
    //这里的build方法是用来构建页面的，会执行多次，所以不要在这里执行耗时操作
    return Scaffold(
      appBar: AppBar(
        title: const Text('To do'),
        //点击appbar刷新页面
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              //刷新页面
              await MyDataBase().queryAllTodoTasks().then((value) {
                setState(() {
                  TodoTasks = value;
                });
              });
            },
          ),
        ],
      ),
      drawer: myDrawer(),
      body: Center(
        child: ListView.builder(
          itemCount: TodoTasks.length,
          itemBuilder: (BuildContext context, int index) {
            //向右滑动可以出现完成按钮、删除按钮、编辑按钮
            /*
                  TodoID INTEGER PRIMARY KEY AUTOINCREMENT,
                  title TEXT NOT NULL,
                  StartTime TEXT NOT NULL
             */
            return Dismissible(
              key: Key(TodoTasks[index]['TodoID'].toString()),
              //每个任务的key,用于唯一标识,必须是唯一的,否则会报错
              onDismissed: (direction) {
                if (direction == DismissDirection.startToEnd) {
                  // 显示SnackBar通知用户
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('任务已删除: ${TodoTasks[index]['title']}'),
                    ),
                  );
                  //删除todo任务
                  MyDataBase().deleteTodoTask(TodoTasks[index]['TodoID']);
                  log('删除任务');
                } else if (direction == DismissDirection.endToStart) {
                  //完成todo任务
                  log('完成任务');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('任务已完成: ${TodoTasks[index]['title']}'),
                    ),
                  );
                  MyDataBase().InsertRecord(TodoTasks[index]['title'],
                      TodoTasks[index]['StartTime'], DateTime.now().toString());
                  MyDataBase().deleteTodoTask(TodoTasks[index]['TodoID']);
                }
              },

              background: Container(
                //左滑动出现的背景，这里是删除按钮
                color: Colors.red,
                child: const ListTile(
                  leading: Icon(Icons.delete, color: Colors.white, size: 36),
                ),
              ),
              secondaryBackground: Container(
                //右滑动出现的背景，这里是完成按钮
                color: Colors.green,
                child: const ListTile(
                  trailing: Icon(Icons.check, color: Colors.white, size: 36),
                ),
              ),
              child: ListTile(
                //显示任务的标题和描述
                title: Text(TodoTasks[index]['title']),
                subtitle: Text(TodoTasks[index]['StartTime']),
              ),
            );
          },
        ),
      ),
    );
  }

  void _doQuit() {
    SystemNavigator.pop();
  }

  myDrawer() {
    return Drawer(
      child: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('任务日志'),
            textColor: Colors.blue,
            selectedColor: Colors.red,
            onTap: () {
              Navigator.pop(context);
              //点击任务日志按钮，跳转到任务日志页面,关闭drawer
              log('任务日志');
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Showrecords()));

            },
          ),
          ListTile(
            title: const Text('添加任务'),
            textColor: Colors.blue,
            selectedColor: Colors.red,
            onTap: () {
              Navigator.pop(context);
              log('添加任务');
              //class _AddtaskState extends State<Addtask> {
              //   get myDB => null;
              Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddTask()))
                  .then((value) {
                if (value == 'refresh') {//刷新页面
                  MyDataBase().queryAllTodoTasks().then((value) {
                    setState(() {
                      TodoTasks = value;
                    });
                  });
                }
              });
            },
          ),
          //全部任务按钮
          ListTile(
            title: const Text('全部任务'),
            textColor: Colors.blue,
            selectedColor: Colors.red,
            onTap: () {
              Navigator.pop(context);
              log('全部任务');
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Showtasks())).then((value) {
                if (value == 'refresh') {
                  MyDataBase().queryAllTodoTasks().then((value) {
                    setState(() {
                      TodoTasks = value;
                    });
                  });
                }
              });
            },
          ),
          //退出这个应用按钮
          ListTile(
            title: const Text('退出'),
            textColor: Colors.blue,
            selectedColor: Colors.red,
            onTap: () {
              log('退出');
              _doQuit();
            },
          ),
        ],
      ),
    );
  }
}
