# KG Auto redesign-only handoff

This package is the redesigned mobile application checkpoint created after the login/API correction and before the later Mobile Tools feature set.

## Included

- Website-aligned KG Auto visual system
- Redesigned login, dashboard, vehicle, container, user, finance, and detail screens
- Working production API configuration and improved login error handling
- Android, iOS, web, Windows, macOS, and Linux Flutter project files

## Intentionally excluded

- Mobile Tools tab
- Saved searches, favorites, and recently viewed tools
- Local pickup-draft autosave
- Privacy and biometric tools
- CSV/PDF local exports
- Barcode and QR scanning tools
- All other features requested after the design-only checkpoint

## Continue with Codex

Open this folder as a project in Codex and use this starting prompt:

> Continue development of the KG Auto Flutter app from this redesign-only checkpoint. Preserve the current website-aligned design and login/API fixes. Inspect the existing architecture before making changes. Implement only the feature I request, run Flutter analysis for changed files, and build a debug APK for testing.

## Setup

1. Install a Flutter SDK compatible with Dart `>=3.0.5 <4.0.0`.
2. Run `flutter pub get`.
3. Run `flutter analyze`.
4. Run `flutter build apk --debug`.

The client's private Play Store signing key is not included. Debug builds work without it. Configure secure release signing separately before publishing.
