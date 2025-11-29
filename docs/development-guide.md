# Development Guide

## Prerequisites
- **Flutter SDK**: >=3.0.0 <4.0.0
- **Dart SDK**: Bundled with Flutter
- **IDE**: VS Code or Android Studio with Flutter plugins
- **API Keys**:
    - Kie AI API Key (for `.env`)
    - Firebase Configuration (`google-services.json` / `GoogleService-Info.plist`)

## Setup Instructions

1.  **Clone the repository**
    ```bash
    git clone <repo-url>
    cd aqvioo
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Environment Configuration**
    - Create a `.env` file in the root directory.
    - Add your API keys:
      ```
      KIE_API_KEY=your_key_here
      ```

4.  **Run the Application**
    ```bash
    flutter run
    ```

## Build Commands

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Testing
Run unit and widget tests:
```bash
flutter test
```

## Code Generation
If you modify localization files (`lib/l10n/*.arb`), run:
```bash
flutter gen-l10n
```
