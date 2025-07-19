import 'package:flutter/material.dart';

void main() => runApp(TaskifyApp());

class TaskifyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taskify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: Color(0xFFF4F6FA),
      ),
      home: TaskifyHomePage(),
    );
  }
}

enum TaskCategory { Personal, Work, Urgent }

class Task {
  String title;
  bool isDone;
  DateTime? dueDate;
  TaskCategory category;

  Task({
    required this.title,
    this.isDone = false,
    this.dueDate,
    required this.category,
  });
}

class TaskifyHomePage extends StatefulWidget {
  @override
  _TaskifyHomePageState createState() => _TaskifyHomePageState();
}

class _TaskifyHomePageState extends State<TaskifyHomePage> {
  final List<Task> _tasks = [];
  final TextEditingController _taskController = TextEditingController();
  DateTime? _selectedDate;
  TaskCategory _selectedCategory = TaskCategory.Personal;

  void _addTask() {
    final title = _taskController.text.trim();
    if (title.isNotEmpty) {
      setState(() {
        _tasks.add(Task(
          title: title,
          dueDate: _selectedDate,
          category: _selectedCategory,
        ));
        _taskController.clear();
        _selectedDate = null;
        _selectedCategory = TaskCategory.Personal;
      });
    }
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index].isDone = !_tasks[index].isDone;
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No date';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _categoryToString(TaskCategory category) {
    switch (category) {
      case TaskCategory.Personal:
        return 'Personal';
      case TaskCategory.Work:
        return 'Work';
      case TaskCategory.Urgent:
        return 'Urgent';
    }
  }

  Color _categoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.Personal:
        return Colors.blue.shade400;
      case TaskCategory.Work:
        return Colors.green.shade500;
      case TaskCategory.Urgent:
        return Colors.red.shade400;
    }
  }

  Widget _buildCategoryChip(TaskCategory category) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _categoryColor(category).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _categoryToString(category),
        style: TextStyle(
          color: _categoryColor(category),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  void _showAddTaskModal() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                labelText: 'Task title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<TaskCategory>(
                    value: _selectedCategory,
                    items: TaskCategory.values.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(_categoryToString(cat)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.calendar_today),
                    label: Text(_selectedDate == null ? 'Pick Due Date' : _formatDate(_selectedDate)),
                    onPressed: _pickDate,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _addTask();
                Navigator.pop(context);
              },
              icon: Icon(Icons.check),
              label: Text('Add Task'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editTask(int index) {
    final task = _tasks[index];
    final editController = TextEditingController(text: task.title);
    DateTime? editDate = task.dueDate;
    TaskCategory editCategory = task.category;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editController,
              decoration: InputDecoration(
                labelText: 'Edit Task Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<TaskCategory>(
                    value: editCategory,
                    items: TaskCategory.values.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(_categoryToString(cat)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          editCategory = val;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.calendar_today),
                    label: Text(editDate == null ? 'Pick Due Date' : _formatDate(editDate)),
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: editDate ?? now,
                        firstDate: now,
                        lastDate: DateTime(now.year + 5),
                      );
                      if (picked != null) {
                        setState(() {
                          editDate = picked;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text('Save Changes'),
              onPressed: () {
                final newTitle = editController.text.trim();
                if (newTitle.isNotEmpty) {
                  setState(() {
                    _tasks[index].title = newTitle;
                    _tasks[index].category = editCategory;
                    _tasks[index].dueDate = editDate;
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Taskify'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _tasks.isEmpty
          ? Center(child: Text("No tasks. Tap + to add one!", style: TextStyle(fontSize: 16)))
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Checkbox(
                      value: task.isDone,
                      onChanged: (_) => _toggleTask(index),
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        decoration: task.isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task.dueDate != null)
                          Text('Due: ${_formatDate(task.dueDate)}'),
                        SizedBox(height: 4),
                        _buildCategoryChip(task.category),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () => _editTask(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _deleteTask(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskModal,
        icon: Icon(Icons.add),
        label: Text('Add Task'),
      ),
    );
  }
}
