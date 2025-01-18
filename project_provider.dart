// lib/providers/project_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/project.dart';
import '../models/task.dart';

class ProjectProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Project> _projects = [];
  List<Task> _tasks = [];

  List<Project> get projects => _projects;
  List<Task> get tasks => _tasks;

  // Fetch all projects for the current user
  Future<void> fetchProjects() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final snapshot = await _firestore
          .collection('projects')
          .where('userId', isEqualTo: userId)
          .get();

      _projects = snapshot.docs
          .map((doc) => Project.fromMap(doc.data(), doc.id))
          .toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching projects: $e');
    }
  }

  // Add new project
  Future<void> addProject(Project project) async {
    try {
      await _firestore.collection('projects').add(project.toMap());
      await fetchProjects();
    } catch (e) {
      print('Error adding project: $e');
    }
  }

  // Update existing project
  Future<void> updateProject(Project project) async {
    try {
      await _firestore
          .collection('projects')
          .doc(project.id)
          .update(project.toMap());
      await fetchProjects();
    } catch (e) {
      print('Error updating project: $e');
    }
  }

  // Delete project
  Future<void> deleteProject(String projectId) async {
    try {
      await _firestore.collection('projects').doc(projectId).delete();
      // Also delete associated tasks
      final taskDocs = await _firestore
          .collection('tasks')
          .where('projectId', isEqualTo: projectId)
          .get();

      for (var doc in taskDocs.docs) {
        await doc.reference.delete();
      }

      await fetchProjects();
      await fetchTasks();
    } catch (e) {
      print('Error deleting project: $e');
    }
  }

  // Fetch tasks for a specific project
  Future<void> fetchTasks([String? projectId]) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('tasks');

      if (projectId != null) {
        query = query.where('projectId', isEqualTo: projectId);
      }

      final snapshot = await query.get();
      _tasks = snapshot.docs
          .map((doc) => Task.fromMap(doc.data(), doc.id))
          .toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  // Add new task
  Future<void> addTask(Task task) async {
    try {
      await _firestore.collection('tasks').add(task.toMap());
      await fetchTasks(task.projectId);
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  // Update existing task
  Future<void> updateTask(Task task) async {
    try {
      await _firestore
          .collection('tasks')
          .doc(task.id)
          .update(task.toMap());
      await fetchTasks(task.projectId);
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  // Delete task
  Future<void> deleteTask(String taskId, String projectId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
      await fetchTasks(projectId);
    } catch (e) {
      print('Error deleting task: $e');
    }
  }
}