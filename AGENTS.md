# Repository Guidelines

## Project Structure & Module Organization

Lumadrive Control is a Flutter application for connecting to Lumadrive devices over BLE and displaying mesh state. `lib/main.dart` initializes the app. Keep UI in `lib/widgets/pages/` and `lib/widgets/ble_states/`, Riverpod state in `lib/controllers/` and `lib/providers/`, BLE and persistence access in `lib/repositories/`, Drift tables in `lib/data/`, and GoRouter configuration in `lib/routing/`.

`lib/generated/` contains protobuf bindings derived from `../proto/mesh.proto`. Platform directories contain native runners and permissions. Tests belong in `test/`; no custom asset bundle is currently declared in `pubspec.yaml`.

## Build, Test, and Development Commands

Run commands from `lumadrive_control/` with Flutter and a Dart SDK satisfying `pubspec.yaml` (`^3.13.0`):

- `flutter pub get`: install locked dependencies.
- `flutter run -d <device-id>`: launch on a selected device; use BLE-capable hardware for connection checks.
- `flutter build apk`: build an Android release APK with the Android toolchain installed.
- `flutter analyze`: run static analysis using `analysis_options.yaml`.
- `dart format lib test`: format Dart source and tests.
- `flutter test`: run Flutter tests.
- `dart run build_runner build`: regenerate Drift code after database changes.

With `protoc` and `protoc-gen-dart` installed, regenerate protocol bindings using `protoc -I ../proto --dart_out=lib/generated ../proto/mesh.proto`.

## Coding Style & Architecture

Use two-space indentation, `snake_case.dart` filenames, `UpperCamelCase` types, and `lowerCamelCase` members. Follow `flutter_lints` and the configured Riverpod analyzer plugin. Keep Bluetooth operations behind repositories and state transitions in controllers; widgets should observe providers. Dispose stream subscriptions when their owner is disposed. Regenerate `database.g.dart` and protobuf files instead of editing them manually; these outputs are tracked here.

## Testing Guidelines

Use `flutter_test` with `*_test.dart` filenames and behavior-focused test descriptions. The existing widget test is the starter counter test and needs adaptation to the current app; it does not establish BLE coverage. No coverage threshold is configured. Use provider overrides and test doubles to isolate hardware. For BLE changes, manually verify scanning, permissions, pairing, reconnects, and mesh notifications against firmware.

## Commit & Pull Request Guidelines

Recent commits use short `feat:` subjects; continue concise, imperative messages. PRs should explain changed behavior, link relevant issues, list checks and tested devices, and include screenshots for UI changes. Identify companion firmware or protocol changes. Keep caches and build outputs out of commits.
