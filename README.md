# Lumadrive Control

Lumadrive Control is the control app for Lumadrive.

## Versioned builds

Build with the wrapper to derive the app version from the nearest reachable Git
tag named `vMAJOR.MINOR.PATCH` (or `MAJOR.MINOR.PATCH`):

```sh
bash tool/flutter_versioned.sh build apk
bash tool/flutter_versioned.sh --print-version
```

For example, tag `v0.1.1` produces build name `0.1.1`. Commits after the tag
keep that build name; the wrapper prints the full Git description, including
the commit and `-dirty` suffix, for identification. Without a reachable version
tag, the build name is `0.0.0`.

The numeric build number defaults to the number of commits reachable from
`HEAD`. It is stable for a commit, but may not increase across branches or
rebases. For published builds, use a monotonically increasing CI build number,
for example `LUMADRIVE_BUILD_NUMBER=42 bash tool/flutter_versioned.sh build apk`.
Shallow checkouts must be unshallowed or provide this override, and need the
release tags fetched to derive the intended version.

Ordinary `flutter build` and IDE launch commands still use the version in
`pubspec.yaml`; use the wrapper whenever Git-derived versioning is required.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
