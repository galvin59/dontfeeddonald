# dont_feed_donald

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## CI/CD Integration

Setting up this project in a CI/CD environment (like Codemagic, GitHub Actions, etc.) requires specific configuration for environment variables and build commands.

### Environment Variables

The following environment variables **must** be securely configured in your CI/CD environment for release builds:

*   `API_KEY`: Your production API key.
*   `API_BASE_URL_PROD`: Your production API base URL.

These are typically set as secrets or secure environment variables within your CI/CD platform.

### Build Commands

When building the application for **release**, you **must** use the `--dart-define` flag to inject the environment variables at compile time. This is crucial because the app reads these values using `String.fromEnvironment` in release mode.

**Example iOS Release Build Command:**
```bash
flutter build ipa --release \
  --build-name=<your_version_name> \
  --build-number=<your_build_number> \
  --dart-define=API_KEY=$API_KEY \
  --dart-define=API_BASE_URL=$API_BASE_URL_PROD
```

**Example Android Release Build Command:**
```bash
flutter build appbundle --release \
  --build-name=<your_version_name> \
  --build-number=<your_build_number> \
  --dart-define=API_KEY=$API_KEY \
  --dart-define=API_BASE_URL=$API_BASE_URL_PROD
```

*   Replace `<your_version_name>` and `<your_build_number>` with your versioning strategy (e.g., using CI-provided variables like `$PROJECT_BUILD_NUMBER`).
*   Ensure `$API_KEY` and `$API_BASE_URL_PROD` correspond to the exact names of the environment variables set in your CI/CD platform.

### Android Signing (Release)

The Android release build (`appbundle` or `apk`) requires signing. The `android/app/build.gradle.kts` file is configured to look for the following environment variables in the CI environment (identified by the presence of a `CI=true` variable, common in platforms like Codemagic):

*   `CM_KEYSTORE_PATH`: Path to the `.keystore` file.
*   `CM_KEYSTORE_PASSWORD`: Keystore password.
*   `CM_KEY_ALIAS`: Key alias.
*   `CM_KEY_PASSWORD`: Key password.

These variables and the keystore file itself need to be securely managed within your CI/CD platform.

### iOS Signing (Release)

iOS release builds require standard code signing setup. You will need to configure your CI/CD platform with the necessary Apple Developer certificates and provisioning profiles.
