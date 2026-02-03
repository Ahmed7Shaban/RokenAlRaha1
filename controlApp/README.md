# Roken Al Raha Control App

This is the admin dashboard for the Roken Al Raha application.

## Features

- **Support Section Toggle**: Enable/disable the support section in real-time.
- **Link Management**: Update Developer and TikTok URLs.
- **Real-time Sync**: Uses Firebase Realtime Database.

## Setup

1. **Firebase Configuration**:
   - Add your `google-services.json` (for Android) into the `android/app` directory.
   - Or use `flutterfire configure` to generate `firebase_options.dart`.

2. **Run**:
   ```bash
   flutter pub get
   flutter run
   ```

## Architecture

- **State Management**: Flutter Bloc (Cubit)
- **Database**: Firebase Realtime Database
- **Design**: Material 3 with Custom Dark Theme (Google Fonts: Outfit & Inter)
