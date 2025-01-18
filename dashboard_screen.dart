import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/project_provider.dart';
import '../models/project.dart';
import '../models/task.dart';

class DashboardScreen extends StatelessWidget {
  Map<ProjectStatus, int> _getProjectStatusCount(List<Project> projects) {
    final statusCount = Map<ProjectStatus, int>.fromIterable(
      ProjectStatus.values,
      key: (status) => status,
      value: (_) => 0,
    );

    for (var project in projects) {
      statusCount[project.status] = (statusCount[project.status] ?? 0) + 1;
    }

    return statusCount;
  }

  Map<TaskPriority, int> _getTaskPriorityCount(List<Task> tasks) {
    final priorityCount = Map<TaskPriority, int>.fromIterable(
      TaskPriority.values,
      key: (priority) => priority,
      value: (_) => 0,
    );

    for (var task in tasks) {
      priorityCount[task.priority] = (priorityCount[task.priority] ?? 0) + 1;
    }

    return priorityCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, projectProvider, child) {
          final projects = projectProvider.projects;
          final tasks = projectProvider.tasks;
          final statusCount = _getProjectStatusCount(projects);
          final priorityCount = _getTaskPriorityCount(tasks);

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(projects, tasks),
                  SizedBox(height: 24),
                  _buildProjectStatusChart(statusCount),
                  SizedBox(height: 24),
                  _buildTaskPriorityChart(priorityCount),
                  SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(List<Project> projects, List<Task> tasks) {
    final completedProjects = projects
        .where((p) => p.status == ProjectStatus.completed)
        .length;
    final completedTasks = tasks.where((t) => t.isCompleted).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 16) / 2; // Account for spacing
        final cardHeight = 100.0; // Fixed height for cards

        return Container(
          height: cardHeight * 2 + 16, // Total height for 2 rows + spacing
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: cardWidth / cardHeight,
            physics: NeverScrollableScrollPhysics(),
            children: [
              _buildSummaryCard(
                'Total Projects',
                projects.length.toString(),
                Icons.folder,
                Colors.blue,
              ),
              _buildSummaryCard(
                'Completed Projects',
                completedProjects.toString(),
                Icons.check_circle,
                Colors.green,
              ),
              _buildSummaryCard(
                'Total Tasks',
                tasks.length.toString(),
                Icons.task,
                Colors.orange,
              ),
              _buildSummaryCard(
                'Completed Tasks',
                completedTasks.toString(),
                Icons.done_all,
                Colors.purple,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectStatusChart(Map<ProjectStatus, int> statusCount) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Projects by Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: statusCount.entries.map((entry) {
                    final color = Color(
                      int.parse(
                        getStatusColor(entry.key).replaceAll('#', '0xFF'),
                      ),
                    );
                    return PieChartSectionData(
                      color: color,
                      value: entry.value.toDouble(),
                      title: entry.value.toString(),
                      radius: 80,
                      titleStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      titlePositionPercentageOffset: 0.5,
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: statusCount.entries.map((entry) {
                final color = Color(
                  int.parse(
                    getStatusColor(entry.key).replaceAll('#', '0xFF'),
                  ),
                );
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      entry.key.toString().split('.').last,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskPriorityChart(Map<TaskPriority, int> priorityCount) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tasks by Priority',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: priorityCount.values
                      .reduce((a, b) => a > b ? a : b)
                      .toDouble() +
                      1,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final priorities = ['High', 'Medium', 'Low'];
                          return Text(
                            priorities[value.toInt()],
                            style: TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _buildBarGroup(
                        0, priorityCount[TaskPriority.high] ?? 0, Colors.red),
                    _buildBarGroup(
                        1, priorityCount[TaskPriority.medium] ?? 0, Colors.orange),
                    _buildBarGroup(
                        2, priorityCount[TaskPriority.low] ?? 0, Colors.green),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, int y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y.toDouble(),
          color: color,
          width: 40,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
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