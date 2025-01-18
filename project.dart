// lib/models/project.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum ProjectStatus {
  notStarted,
  inProgress,
  onHold,
  completed,
  cancelled
}

class Project {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final ProjectStatus status;
  final String userId;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': status.toString(),
      'userId': userId,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map, String id) {
    return Project(
      id: id,
      title: map['title'],
      description: map['description'],
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      status: ProjectStatus.values.firstWhere(
            (e) => e.toString() == map['status'],
        orElse: () => ProjectStatus.notStarted,
      ),
      userId: map['userId'],
    );
  }
}

