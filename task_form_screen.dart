import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../models/task.dart';
import '../models/project.dart'; // Import the Project model
import 'package:intl/intl.dart';

class TaskFormScreen extends StatefulWidget {
  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _dueDate;
  DateTime? _reminderTime;
  TaskPriority _priority = TaskPriority.medium;
  bool _isCompleted = false;
  String? _projectId; // Add this variable

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();

    Future.microtask(() {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is Task) {
        // Editing an existing task
        final task = arguments;
        _titleController.text = task.title;
        _descriptionController.text = task.description;
        _dueDate = task.dueDate;
        _reminderTime = task.reminderTime;
        _priority = task.priority;
        _isCompleted = task.isCompleted;
      } else if (arguments is Project) {
        // Adding a new task for a project
        final project = arguments;
        _projectId = project.id; // Store the project ID
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _selectReminderTime(BuildContext context) async {
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a due date first')),
      );
      return;
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _reminderTime ?? _dueDate!,
      firstDate: DateTime.now(),
      lastDate: _dueDate!,
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_reminderTime ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _reminderTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is Task) {
        // Editing an existing task
        final task = arguments;
        await Provider.of<ProjectProvider>(context, listen: false).updateTask(
          Task(
            id: task.id,
            projectId: task.projectId,
            title: _titleController.text,
            description: _descriptionController.text,
            dueDate: _dueDate!,
            priority: _priority,
            isCompleted: _isCompleted,
            reminderTime: _reminderTime,
          ),
        );
      } else if (arguments is Project) {
        // Adding a new task
        await Provider.of<ProjectProvider>(context, listen: false).addTask(
          Task(
            id: '', // Generate a unique ID if needed
            projectId: _projectId!, // Use the stored project ID
            title: _titleController.text,
            description: _descriptionController.text,
            dueDate: _dueDate!,
            priority: _priority,
            isCompleted: _isCompleted,
            reminderTime: _reminderTime,
          ),
        );
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    final isEditing = arguments is Task;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'Add Task'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('Due Date'),
                subtitle: Text(
                  _dueDate == null
                      ? 'Select date'
                      : DateFormat('MMM dd, yyyy').format(_dueDate!),
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              ListTile(
                title: Text('Reminder Time'),
                subtitle: Text(
                  _reminderTime == null
                      ? 'Set reminder'
                      : DateFormat('MMM dd, yyyy – HH:mm').format(_reminderTime!),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_reminderTime != null)
                      IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _reminderTime = null;
                          });
                        },
                      ),
                    Icon(Icons.alarm),
                  ],
                ),
                onTap: () => _selectReminderTime(context),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<TaskPriority>(
                value: _priority,
                decoration: InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: TaskPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (TaskPriority? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _priority = newValue;
                    });
                  }
                },
              ),
              if (isEditing) ...[
                SizedBox(height: 16),
                CheckboxListTile(
                  title: Text('Mark as completed'),
                  value: _isCompleted,
                  onChanged: (bool? value) {
                    setState(() {
                      _isCompleted = value ?? false;
                    });
                  },
                ),
              ],
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_dueDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select a due date'),
                      ),
                    );
                    return;
                  }
                  _submitForm();
                },
                child: Text(isEditing ? 'Update Task' : 'Create Task'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}