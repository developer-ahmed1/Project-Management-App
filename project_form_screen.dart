// lib/screens/project_form_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../models/project.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ProjectFormScreen extends StatefulWidget {
  @override
  _ProjectFormScreenState createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _startDate;
  DateTime? _endDate;
  ProjectStatus _status = ProjectStatus.notStarted;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();

    Future.microtask(() {
      final project = ModalRoute.of(context)?.settings.arguments as Project?;
      if (project != null) {
        _titleController.text = project.title;
        _descriptionController.text = project.description;
        _startDate = project.startDate;
        _endDate = project.endDate;
        _status = project.status;
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final project = ModalRoute.of(context)?.settings.arguments as Project?;
      final userId = FirebaseAuth.instance.currentUser!.uid;

      if (project == null) {
        // Add new project
        await Provider.of<ProjectProvider>(context, listen: false).addProject(
          Project(
            id: '',
            title: _titleController.text,
            description: _descriptionController.text,
            startDate: _startDate!,
            endDate: _endDate!,
            status: _status,
            userId: userId,
          ),
        );
      } else {
        // Update existing project
        await Provider.of<ProjectProvider>(context, listen: false).updateProject(
          Project(
            id: project.id,
            title: _titleController.text,
            description: _descriptionController.text,
            startDate: _startDate!,
            endDate: _endDate!,
            status: _status,
            userId: userId,
          ),
        );
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = ModalRoute.of(context)?.settings.arguments as Project?;
    final isEditing = project != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Project' : 'Add Project'),
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
                title: Text('Start Date'),
                subtitle: Text(
                  _startDate == null
                      ? 'Select date'
                      : DateFormat('MMM dd, yyyy').format(_startDate!),
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              ListTile(
                title: Text('End Date'),
                subtitle: Text(
                  _endDate == null
                      ? 'Select date'
                      : DateFormat('MMM dd, yyyy').format(_endDate!),
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<ProjectStatus>(
                value: _status,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: ProjectStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (ProjectStatus? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _status = newValue;
                    });
                  }
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_startDate == null || _endDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select both start and end dates'),
                      ),
                    );
                    return;
                  }
                  if (_endDate!.isBefore(_startDate!)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('End date must be after start date'),
                      ),
                    );
                    return;
                  }
                  _submitForm();
                },
                child: Text(isEditing ? 'Update Project' : 'Create Project'),
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