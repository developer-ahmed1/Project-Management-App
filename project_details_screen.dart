import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../models/project.dart';
import '../models/task.dart';
import 'package:intl/intl.dart';

class ProjectDetailsScreen extends StatefulWidget {
  @override
  _ProjectDetailsScreenState createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final project = ModalRoute.of(context)!.settings.arguments as Project;
      Provider.of<ProjectProvider>(context, listen: false)
          .fetchTasks(project.id);
    });
  }

  String getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return '#E57373';
      case TaskPriority.medium:
        return '#FFB74D';
      case TaskPriority.low:
        return '#81C784';
      default:
        return '#E0E0E0';
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = ModalRoute.of(context)!.settings.arguments as Project;

    return Scaffold(
      appBar: AppBar(
        title: Text(project.title),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(
              context,
              '/edit-project',
              arguments: project,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProjectHeader(project),
          Expanded(
            child: _buildTaskList(project),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(
          context,
          '/add-task',
          arguments: project,
        ),
      ),
    );
  }

  Widget _buildProjectHeader(Project project) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.description,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Start: ${DateFormat('MMM dd, yyyy').format(project.startDate)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                'End: ${DateFormat('MMM dd, yyyy').format(project.endDate)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Color(int.parse(
                getStatusColor(project.status).replaceAll('#', '0xFF'),
              )),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              project.status.toString().split('.').last,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(Project project) {
    return Consumer<ProjectProvider>(
      builder: (context, projectProvider, child) {
        final tasks = projectProvider.tasks
            .where((task) => task.projectId == project.id)
            .toList();

        if (tasks.isEmpty) {
          return Center(
            child: Text('No tasks added yet'),
          );
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: Checkbox(
                  value: task.isCompleted,
                  onChanged: (bool? value) {
                    projectProvider.updateTask(
                      Task(
                        id: task.id,
                        projectId: task.projectId,
                        title: task.title,
                        description: task.description,
                        dueDate: task.dueDate,
                        priority: task.priority,
                        isCompleted: value ?? false,
                        reminderTime: task.reminderTime,
                      ),
                    );
                  },
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            DateFormat('MMM dd, yyyy').format(task.dueDate),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (task.reminderTime != null) ...[
                          SizedBox(width: 8),
                          Icon(Icons.alarm, size: 16),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              DateFormat('MMM dd, HH:mm')
                                  .format(task.reminderTime!),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                trailing: SizedBox(
                  width: 96, // Fixed width for trailing widgets
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 48, // Fixed width for priority label
                        padding: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Color(int.parse(
                            getPriorityColor(task.priority)
                                .replaceAll('#', '0xFF'),
                          )),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          task.priority.toString().split('.').last,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PopupMenuButton(
                        padding: EdgeInsets.zero,
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: Text('Edit'),
                            value: 'edit',
                          ),
                          PopupMenuItem(
                            child: Text('Delete'),
                            value: 'delete',
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            Navigator.pushNamed(
                              context,
                              '/edit-task',
                              arguments: task,
                            );
                          } else if (value == 'delete') {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Delete Task'),
                                content: Text(
                                  'Are you sure you want to delete this task?',
                                ),
                                actions: [
                                  TextButton(
                                    child: Text('Cancel'),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  TextButton(
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onPressed: () {
                                      projectProvider.deleteTask(
                                        task.id,
                                        task.projectId,
                                      );
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.notStarted:
        return '#E0E0E0';
      case ProjectStatus.inProgress:
        return '#64B5F6';
      case ProjectStatus.onHold:
        return '#FFB74D';
      case ProjectStatus.completed:
        return '#81C784';
      case ProjectStatus.cancelled:
        return '#E57373';
      default:
        return '#E0E0E0';
    }
  }
}