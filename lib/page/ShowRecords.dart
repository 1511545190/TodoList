import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oppowatch/utils/MyDataBase.dart';

class Showrecords extends StatefulWidget {
  const Showrecords({super.key});

  @override
  State<Showrecords> createState() => _ShowrecordsState();
}

class _ShowrecordsState extends State<Showrecords> {
  List<Map<String, dynamic>> Records = [];

  @override
  void initState() {
    super.initState();
    MyDataBase().queryAllRecords().then((value) {
      setState(() {
        Records = value;
      });
    });
    log("myRecords length: ${Records.length}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记录列表'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            //返回到Drawer
            Navigator.pop(context, 'refresh');
          },
        ),
        //刷新页面
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await MyDataBase().queryAllRecords().then((value) {
                setState(() {
                  Records = value;
                });
              });
            },
          ),
        ],
      ),
      //Record Table
      body: ListView.builder(
        itemCount: Records.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(Records[index]['RecordID'].toString()),
            child: ListTile(
              title: Text('${Records[index]['title']}'),
              subtitle: Text(
                '${Records[index]['StartTime'].toString().substring(2, 16)} - ${Records[index]['EndTime'].toString().substring(2, 16)}',
              ),
            ),
            //只能左滑删除，不能增加
            direction: DismissDirection.startToEnd,
            confirmDismiss: (direction) async {//confirmDismiss是在用户滑动时调用的回调
              // 返回true允许滑动删除，返回false不允许滑动删除
              // Dialog弹窗确认是否删除,返回true删除，返回false不删除
              if (direction == DismissDirection.startToEnd) {
                // 弹出弹窗，确认是否删除
                return await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('删除记录'),
                      content: Text('确定删除记录吗？'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, false); // 取消删除
                          },
                          child: Text('取消'),
                        ),
                        TextButton(
                          onPressed: () async {
                            // 确认删除
                            await MyDataBase().deleteRecord(Records[index]['RecordID']);
                            Navigator.pop(context, true); // 确认删除
                          },
                          child: Text('确定'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            onDismissed: (direction) {//onDismissed是在用户完成滑动操作后调用的回调
              // 更新状态并刷新列表
              setState(() {
                Records.removeAt(index);
              });
            },
            background: Container(
              color: Colors.red,
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.white, size: 36),
              ),
            ),
            secondaryBackground: Container(
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}