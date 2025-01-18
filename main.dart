import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:login_page/screens/forget.dart';
import 'package:login_page/screens/login.dart';
import 'package:login_page/screens/signup.dart';
import 'package:login_page/screens/home_screen.dart'; // Import HomeScreen
import 'package:login_page/screens/dashboard_screen.dart'; // Import DashboardScreen
import 'package:login_page/screens/project_details_screen.dart'; // Import ProjectDetailsScreen
import 'package:login_page/screens/task_form_screen.dart'; // Import TaskFormScreen
import 'package:login_page/screens/project_form_screen.dart';
import 'package:provider/provider.dart';
import 'package:login_page/providers/project_provider.dart'; // Import your ProjectProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ProjectProvider(), // Provide the ProjectProvider
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => HomeScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/project-details': (context) => ProjectDetailsScreen(),
        '/edit-project': (context) => ProjectFormScreen(),
        '/add-project': (context) =>  ProjectFormScreen(),
        '/add-task': (context) => TaskFormScreen(),
        '/edit-task': (context) => TaskFormScreen(),
        '/forget': (context) => ForgetPasswordScreen(),
      },
    );
  }
}