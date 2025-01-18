import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../models/project.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ProjectProvider>(context, listen: false).fetchProjects());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Projects'),
        actions: [
          IconButton(
            icon: Icon(Icons.dashboard),
            onPressed: () => Navigator.pushNamed(context, '/dashboard'),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Add logout logic here
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, projectProvider, child) {
          final projects = projectProvider.projects;

          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Project Details (Clickable with InkWell)
                    InkWell(
                      onTap: () {
                        print('Navigating to /project-details with project: ${project.title}');
                        Navigator.pushNamed(
                          context,
                          '/project-details',
                          arguments: project,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    project.title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
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
                            SizedBox(height: 8),
                            Text(
                              project.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Due: ${DateFormat('MMM dd, yyyy').format(project.endDate)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Buttons Row (View Details, Edit, Delete)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // View Details Button
                        TextButton(
                          onPressed: () {
                            print('Navigating to /project-details with project: ${project.title}');
                            Navigator.pushNamed(
                              context,
                              '/project-details',
                              arguments: project,
                            );
                          },
                          child: Text(
                            'View Details',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        // Edit Button
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/edit-project',
                            arguments: project,
                          ),
                        ),
                        // Delete Button
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Delete Project'),
                              content: Text(
                                'Are you sure you want to delete this project?',
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
                                    projectProvider.deleteProject(project.id);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, '/add-project'),
      ),
    );
  }
}