# Source Tree Analysis

## Directory Structure

```
/Users/mac/aqvioo/
├── android/             # Android native project files
├── assets/              # Static assets (images, etc.)
├── docs/                # Project documentation
├── ios/                 # iOS native project files
├── lib/                 # Main Flutter source code
│   ├── core/            # Shared components and utilities
│   │   ├── presentation/ # Core UI logic
│   │   ├── providers/    # Global providers (e.g., Locale)
│   │   ├── router/       # GoRouter configuration
│   │   ├── services/     # Core services
│   │   ├── theme/        # App theme and colors
│   │   ├── utils/        # Helper functions and extensions
│   │   └── widgets/      # Reusable UI widgets (Glassmorphism)
│   ├── features/        # Feature modules
│   │   ├── auth/         # Authentication (Login, Signup, OTP)
│   │   ├── creation/     # Video/Image Creation Wizard
│   │   ├── design_system/# Design system showcase
│   │   ├── gallery/      # User creations gallery
│   │   ├── home/         # Home screen
│   │   ├── payment/      # Payment integration
│   │   └── preview/      # Media preview screen
│   ├── generated/       # Code-generated files (l10n)
│   ├── l10n/            # Localization ARB files
│   ├── services/        # External API services (AI, etc.)
│   ├── app.dart         # Root App widget
│   └── main.dart        # Application entry point
├── test/                # Unit and widget tests
├── pubspec.yaml         # Dependencies and configuration
└── README.md            # Project entry documentation
```

## Critical Directories

### `lib/features/`
The application follows a **Feature-First** architecture. Each folder in `features/` represents a distinct business domain.
- **auth**: Handles user authentication via Firebase.
- **creation**: The core feature for generating AI content. Contains the wizard logic (`CreationController`) and config models.
- **home**: The landing dashboard for the user.

### `lib/core/`
Contains code shared across multiple features.
- **widgets**: The custom Glassmorphic UI library.
- **router**: Centralized navigation logic using `go_router`.
- **theme**: Application-wide styling definitions.

### `lib/services/`
Contains infrastructure-layer services that communicate with external APIs.
- **ai**: Kie AI, OpenAI, and other generative services.

## Entry Points
- **`lib/main.dart`**: The bootstrap file. Initializes Flutter bindings, Firebase, and runs the app.
- **`lib/app.dart`**: The root widget that sets up the `MaterialApp`, Theme, Router, and Localization.
