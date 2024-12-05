import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list/page/task_Model.dart';

class To_do_App extends StatefulWidget {
  const To_do_App({super.key});

  @override
  State<To_do_App> createState() => _To_do_AppState();
}

class _To_do_AppState extends State<To_do_App> {
  final _formKey = GlobalKey<FormState>();
  final _taskController = TextEditingController();
  List<TaskModel> _tasks = [];
  int _taskId = 0;

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final tasks = jsonDecode(tasksJson).map((task) => TaskModel.fromJson(task)).toList();
      setState(() {
        _tasks = tasks;
        _taskId = _tasks.isEmpty ? 0 : _tasks.last.id + 1;
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = jsonEncode(_tasks.map((task) => task.toJson()).toList());
    await prefs.setString('tasks', tasksJson);
  }

  Future<void> _addTask() async {
    if (_formKey.currentState!.validate()) {
      final task = TaskModel(id: _taskId, task: _taskController.text);
      setState(() {
        _tasks.add(task);
        _taskId++;
      });
      await _saveTasks();
      _taskController.clear();
    }
  }

  Future<void> _deleteTask(int id) async {
    setState(() {
      _tasks.removeWhere((task) => task.id == id);
    });
    await _saveTasks();
  }

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Load saved tasks on app start
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("To Do List"),
        centerTitle: true,
        backgroundColor: Colors.indigoAccent,
      ),
      backgroundColor: Colors.cyanAccent,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _taskController,
                      decoration: InputDecoration(
                        labelText: 'Task',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter task title';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _addTask,
                    child: Text('Add'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _tasks.isEmpty
                  ? Center(
                child: Text('No tasks available'),
              )
                  : ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_tasks[index].task),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteTask(_tasks[index].id);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}