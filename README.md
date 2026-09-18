# Expense Manager

Flutter expense manager with BLoC state management, SQLite persistence, categories, transactions, notifications, and API-backed authentication.

## Project scope

Local data uses SQLite and shared preferences. Remote authentication and transaction endpoints are declared in [api_constants.dart](lib/core/constants/api_constants.dart); those flows require the configured service to be available.

## Run locally

Use a Flutter installation whose Dart SDK satisfies `pubspec.yaml`. Configure any services described above before starting the app.

```sh
flutter pub get
flutter run
```

## Source guide

- [lib/main.dart](lib/main.dart)

## Checks

```sh
flutter analyze
flutter test
```
