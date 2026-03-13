# project_morpheus

Morpheus Flutter app (profile, resume, learning, job application, etc.).

## API base URL

The app talks to the Morpheus backend. By default it uses the deployed Cloud Run URL.

- **Android emulator** (backend on your machine): use your host’s “localhost” as `10.0.2.2`:
  ```bash
  flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
  ```
- **iOS simulator** (backend on your machine): use `localhost`:
  ```bash
  flutter run --dart-define=API_BASE_URL=http://localhost:8000
  ```
- **Physical device** (backend on your machine): use your computer’s LAN IP (e.g. `http://192.168.1.5:8000`).

If the backend is unreachable (e.g. wrong URL or no network), the app will no longer crash; the home screen will fall back to showing the default initial.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
