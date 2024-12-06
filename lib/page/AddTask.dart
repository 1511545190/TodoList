import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:oppowatch/utils/MyDataBase.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // 提交表单的方法
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        String title = _titleController.text;
        String description = _descriptionController.text;
        var timeString = DateTime.now().toIso8601String();

        // 插入任务到数据库
        await MyDataBase().insertTask(title, description);
        // 将任务添加到Todo表
        await MyDataBase().insertTodoTask(title, timeString);

        log('InsertTask complete');

        // 返回到前一个页面，并传递刷新信号
        Navigator.pop(context, 'refresh');
      } catch (e) {
        log('Error inserting task: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加任务失败: $e')),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加任务'), // 设置应用栏标题
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // 返回按钮图标
          onPressed: () {
            // 返回到前一个页面，并传递刷新信号
            Navigator.pop(context, 'refresh');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 为整个页面添加内边距
        child: SingleChildScrollView( // 使用SingleChildScrollView使内容可滚动
          child: Form(
            key: _formKey, // 表单的唯一标识符
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 列中的子组件左对齐
              children: <Widget>[
                TextFormField(
                  controller: _titleController, // 绑定标题输入框的控制器
                  decoration: const InputDecoration(
                    labelText: '标题', // 输入框的提示文本
                    border: OutlineInputBorder(), // 输入框的边框样式
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入任务标题'; // 验证失败时的提示信息
                    }
                    return null; // 验证通过
                  },
                ),
                const SizedBox(height: 16.0), // 添加间距
                TextFormField(
                  controller: _descriptionController, // 绑定描述输入框的控制器
                  decoration: const InputDecoration(
                    labelText: '描述', // 输入框的提示文本
                    border: OutlineInputBorder(), // 输入框的边框样式
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入任务描述'; // 验证失败时的提示信息
                    }
                    // 显示SnackBar通知用户
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('任务添加成功')),
                    );
                    return null; // 验证通过
                  },
                ),
                const SizedBox(height: 24.0), // 添加间距
                Center(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm, // 如果正在提交则禁用按钮
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16), // 按钮内边距
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // 按钮圆角
                      ),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white) // 提交时显示加载指示器
                        : const Text('添加任务', style: TextStyle(fontSize: 18)), // 按钮文本
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}