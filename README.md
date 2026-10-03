# CNESS Feed

## Project Overview

A Flutter feed screen that renders the latest CNESS posts, supports pull-to-refresh and paginated loading, and provides loading, empty, and retry states.

## Architecture

The feature is organized by responsibility under `lib/features/post`: widgets and screens own presentation, `PostProvider` owns feed state, `PostRepository` maps API results to domain models, and `PostModel` parses response data. Shared HTTP configuration and API errors live under `lib/core/api`; environment configuration lives under `lib/core/config`.

## State Management

The screen uses Provider with a `ChangeNotifier`. `PostProvider` exposes explicit initial, loading, loaded, loading-more, empty, and error states. The repository is injectable, which keeps feed behavior testable without network access.

## API Integration

`ApiClient` centralizes Dio configuration, bearer authentication, timeouts, and network error mapping. The repository requests `/api/user/posts/get/front/latest` with `page_no` and `limit`. The provider prevents overlapping refresh/pagination requests, ignores stale page responses after refresh, appends unique posts, and stops when the reported total is reached (or a short page is returned when no total is provided).

The token is read from the `AUTH_TOKEN` Dart environment define. For local use, copy `.dart_defines.json.example` to `.dart_defines.json` and set the assignment token there. The local file is git-ignored, and the VS Code `simple_app (local auth)` launch configuration uses it. Do not commit a real token; Dart defines are convenient for local assignment runs but are not a secure secret store in a distributed mobile app. Production authentication should use a backend-mediated or short-lived credential flow.

## Running the Application

Install Flutter dependencies, then provide the assignment token at launch:

```sh
flutter pub get
flutter run --dart-define-from-file=.dart_defines.json
```

The VS Code `simple_app (release, local auth)` profile and the `Flutter: Run release (local auth)` task pass the defines file when launching in release mode. Use the `Flutter: Build Android APK (local auth)` or `Flutter: Build Android App Bundle (local auth)` task for release artifacts. Dart defines are compiled into the application, so rebuild after changing the token.

```sh
flutter build apk --release --dart-define-from-file=.dart_defines.json
flutter build appbundle --release --dart-define-from-file=.dart_defines.json
```

Restart or rebuild the app after changing the token. Never commit a real token or distribute it in a public mobile build; use backend-mediated or short-lived authentication for production.

Run the test suite with `flutter test` and static analysis with `flutter analyze`.

## Assumptions

- The API response contains post rows under `data.data.rows` and an optional total count under `data.data.count`.
- A short page indicates the end of pagination when the API omits or returns a zero total count.
- The supplied Figma assets are already included in `assets/`; story and navigation content not returned by the posts endpoint remains presentation-level sample content.
