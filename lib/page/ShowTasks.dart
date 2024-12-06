import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oppowatch/utils/MyDataBase.dart';

class Showtasks extends StatefulWidget {
  const Showtasks({super.key});

  @override
  State<Showtasks> createState() => _ShowtasksState();
}

class _ShowtasksState extends State<Showtasks> {
  List<Map> AllTasks = [];

  @override
  void initState() {
    super.initState();
    //query all tasks
    //query all tasks,当数据库操作完成后，会调用setState方法，刷新页面，value是查询到的数据
    MyDataBase().queryAllTasks().then((value) {
      setState(() {
        AllTasks = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('任务列表'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            //返回到Drawer
            Navigator.pop(context, 'refresh');
          },
        ),
      ),
      body: ListView.builder(

        // 使用ListView.builder来构建一个可滚动的任务列表
        itemCount: AllTasks.length, // 列表项的数量等于AllTasks列表的长度
        itemBuilder: (context, index) {
          // 构建每个列表项
          final task = AllTasks[index]; // 获取当前索引对应的任务
          return Dismissible(
            // 使用Dismissible widget实现滑动操作
            key: Key(task['TaskID'].toString()),
            // 每个Dismissible需要一个唯一的Key
            confirmDismiss: (direction) async {
              // 确认是否允许滑动移除
              if (direction == DismissDirection.startToEnd) {
                // 如果是右滑（从右到左）
                // 对于左滑，我们确认移除并删除项目
                // 显示SnackBar通知用户任务已删除
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('任务已删除: ${task['title']}')),
                );
                return true;
              } else {
                // 对于右滑，我们将任务添加到Todo表，但不从列表中移除
                var timeString = DateTime.now().toIso8601String(); // 获取当前时间
                await MyDataBase()
                    .insertTodoTask(task['title'], timeString); // 将任务添加到Todo表

                // 显示SnackBar通知用户任务已添加到Todo
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('任务已添加到待办事项: ${task['title']}')),
                );

                // 返回false以阻止项目被移除
                return false;
              }
            },
            onDismissed: (direction) async {
              // 当项目被滑动移除时触发
              try {
                if (direction == DismissDirection.startToEnd) {
                  // 如果是左滑
                  // 从数据库中删除任务，并从UI中移除
                  await MyDataBase().deleteTask(task['TaskID']); // 删除数据库中的任务
                  log('任务已删除: ${task['TaskID']}'); // 记录日志

                  // 创建一个新的AllTasks副本，然后从中移除被滑动移除的任务
                  setState(() {
                    AllTasks = List.from(AllTasks)
                      ..removeAt(index); // 更新AllTasks列表
                  });
                }
              } catch (e) {
                // 处理可能在数据库操作中发生的错误
                log('处理滑动操作时出错: $e'); // 记录错误日志

                // 可选地，向用户显示一条消息，告知删除任务失败
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('删除任务失败。')),
                );
              }
            },
            secondaryBackground: Container(
              // 左滑时的背景
              color: Colors.green, // 背景颜色设置为绿色
              child: const ListTile(
                // 在背景中添加一个图标和文本
                trailing:
                    Icon(Icons.add, color: Colors.white, size: 36), // 添加图标的样式
              ),
            ),
            background: Container(
              // 右滑时的背景
              color: Colors.red, // 背景颜色设置为红色
              child: const ListTile(
                // 在背景中添加一个图标和文本
                leading: Icon(Icons.delete,
                    color: Colors.white, size: 36), // 删除图标的样式
              ),
            ),
            child: ListTile(
              // 列表项的内容
              title: Text(' ${task['title']}'), // 显示任务标题
              subtitle: Text(' ${task['description']}'), // 显示任务描述
            ),
          );
        },
      ),
    );
  }
}
