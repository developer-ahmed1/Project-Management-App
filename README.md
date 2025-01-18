# Project-Management-App
This is a simple yet powerful project management app built with Flutter, designed to help users manage their projects and tasks efficiently. The app integrates Firebase for backend services (Firestore for data storage and Firebase Authentication for user accounts) .
The app allows users to:

Create, view, edit, and delete projects with details like title, description, start date, end date, and status.

Create, view, edit, and delete tasks linked to specific projects, with fields such as title, description, due date, priority, and status.

Track progress through a dashboard that provides a summary of projects, tasks, and their statuses.

Features
Core Features
Project Management:

Add, view, edit, and delete projects.

Project fields: Title, Description, Start Date, End Date, and Status.

Task Management:

Add, view, edit, and delete tasks linked to specific projects.

Task fields: Title, Description, Due Date, Priority, and Status.

User Authentication:

Secure user login and registration using Firebase Authentication.

Real-Time Data Sync:

All data is stored and synced in real-time using Firebase Firestore.

State Management:

Efficiently manage app state using Provider for real-time updates and a smooth user experience.

User Interface
Home Screen:

Displays a list of all projects with basic details (title, status, and progress).

Project Details Screen:

Shows all tasks under a specific project.

Allows users to add, edit, or delete tasks.

Forms:

Intuitive forms for adding/editing projects and tasks with form validation.

Dashboard:

Provides a summary of:

Total projects and their statuses.

Total tasks and their priorities.

Overall progress.

Tech Stack
Frontend: Flutter (Dart)

Backend: Firebase (Firestore, Authentication)

State Management: Provider

UI/UX: Material Design with responsive layouts

