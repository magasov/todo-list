import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TaskScreen(),
    );
  }
}

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List<Map<String, String>> tasks = [];
  String _filterStatus = 'all';

  void _addTask(String taskName, String priority) {
    setState(() {
      tasks.add({'name': taskName, 'priority': priority, 'status': 'incomplete'});
    });
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  void _updateTaskStatus(int index) {
    setState(() {
      tasks[index]['status'] = tasks[index]['status'] == 'incomplete' ? 'complete' : 'incomplete';
    });
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddTaskDialog(onTaskAdded: _addTask),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        onFilterChanged: (statusFilter) {
          setState(() {
            _filterStatus = statusFilter;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredTasks = tasks.where((task) {
      if (_filterStatus == 'completed' && task['status'] != 'complete') {
        return false;
      } else if (_filterStatus == 'incomplete' && task['status'] != 'incomplete') {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Список задач"),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: filteredTasks.isEmpty
          ? Center(child: Text("Нет задач"))
          : ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: ListTile(
                    title: Text(filteredTasks[index]['name']!),
                    subtitle: Text("Приоритет: ${filteredTasks[index]['priority']}"),
                    trailing: IconButton(
                      icon: Icon(
                        filteredTasks[index]['status'] == 'complete'
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: filteredTasks[index]['status'] == 'complete' ? Colors.green : null,
                      ),
                      onPressed: () => _updateTaskStatus(tasks.indexOf(filteredTasks[index])),
                    ),
                    onLongPress: () => _deleteTask(tasks.indexOf(filteredTasks[index])),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}

class _AddTaskDialog extends StatefulWidget {
  final Function(String, String) onTaskAdded;

  _AddTaskDialog({required this.onTaskAdded});

  @override
  __AddTaskDialogState createState() => __AddTaskDialogState();
}

class __AddTaskDialogState extends State<_AddTaskDialog> {
  final TextEditingController _taskController = TextEditingController();
  String _selectedPriority = 'Низкий';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text("Добавить задачу"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _taskController,
            decoration: InputDecoration(labelText: "Название задачи"),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Приоритет:"),
              DropdownButton<String>(
                value: _selectedPriority,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPriority = newValue!;
                  });
                },
                items: ['Низкий', 'Средний', 'Высокий']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Отмена"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_taskController.text.isNotEmpty) {
              widget.onTaskAdded(_taskController.text, _selectedPriority);
              Navigator.of(context).pop();
            }
          },
          child: Text("Добавить"),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }
}

class FilterDialog extends StatefulWidget {
  final Function(String) onFilterChanged;

  FilterDialog({required this.onFilterChanged});

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  String _selectedStatus = 'all';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Фильтрация задач"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Фильтровать по статусу:"),
          ListTile(
            title: Text('Все'),
            onTap: () {
              widget.onFilterChanged('all');
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: Text('Выполненные'),
            onTap: () {
              widget.onFilterChanged('completed');
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: Text('Невыполненные'),
            onTap: () {
              widget.onFilterChanged('incomplete');
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
