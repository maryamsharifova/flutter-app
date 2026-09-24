# Todo App

A simple, clean to-do list app built with Flutter. Manage your daily tasks with a fast, local-first experience — no internet connection required.

## Features

- User login/authentication
- Add, edit, and delete tasks
- Local data persistence (tasks are saved on-device)
- Clean, card-based task list UI
- State management with Provider

## Screenshots

<!-- Add screenshots here, e.g. -->
<!-- ![Home Screen](screenshots/home.png) -->

## Tech Stack

- **Flutter** & **Dart**
- **Provider** for state management
- Local database for persistent storage

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed
- An emulator or physical device (Android/iOS) or a supported desktop/web target

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/maryamsharifova/flutter-app.git
   cd flutter-app
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Run the app:

   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── auth/            # Login screen
├── models/          # Task data model
├── providers/       # App state management
├── screens/         # Main app screens
├── services/        # Database logic
├── widgets/         # Reusable UI components (task card, task dialog)
└── main.dart        # App entry point
```

## License

This project currently has no license specified.
