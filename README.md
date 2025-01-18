# Project-Management-App
Project Management App with Flutter, Firebase, and Provider
Overview
This is a simple yet powerful project management app built with Flutter, designed to help users manage their projects and tasks efficiently. The app integrates Firebase for backend services (Firestore for data storage and Firebase Authentication for user accounts) and uses Provider for state management to ensure a seamless and responsive user experience.
The app allows users to:
•	Create, view, edit, and delete projects with details like title, description, start date, end date, and status.
•	Create, view, edit, and delete tasks linked to specific projects, with fields such as title, description, due date, priority, and status.
•	Track progress through a dashboard that provides a summary of projects, tasks, and their statuses.
________________________________________
Features
Core Features
1.	Project Management:
o	Add, view, edit, and delete projects.
o	Project fields: Title, Description, Start Date, End Date, and Status.
2.	Task Management:
o	Add, view, edit, and delete tasks linked to specific projects.
o	Task fields: Title, Description, Due Date, Priority, and Status.
3.	User Authentication:
o	Secure user login and registration using Firebase Authentication.
4.	Real-Time Data Sync:
o	All data is stored and synced in real-time using Firebase Firestore.
5.	State Management:
o	Efficiently manage app state using Provider for real-time updates and a smooth user experience.
User Interface
1.	Home Screen:
o	Displays a list of all projects with basic details (title, status, and progress).
2.	Project Details Screen:
o	Shows all tasks under a specific project.
o	Allows users to add, edit, or delete tasks.
3.	Forms:
o	Intuitive forms for adding/editing projects and tasks with form validation.
4.	Dashboard:
o	Provides a summary of:
	Total projects and their statuses.
	Total tasks and their priorities.
	Overall progress.
________________________________________
Tech Stack
•	Frontend: Flutter (Dart)
•	Backend: Firebase (Firestore, Authentication)
•	State Management: Provider
•	UI/UX: Material Design with responsive layouts
