# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Aqvioo is a Flutter app (iOS/Android/Web) that generates promotional videos and images from text or photos using AI. It integrates Kie.ai for video/image generation, OpenAI for text, Eleven Labs for voiceover, Firebase for backend, and Tap Payments for payments.

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run app (auto-detects platform)
flutter run

# Run on specific platform
flutter run -d chrome --web-port=8080    # Web
flutter run -d ios                        # iOS Simulator
flutter run -d android                    # Android Emulator

# Generate localization files after editing .arb files
flutter gen-l10n

# Analyze code for issues
flutter analyze

# Run tests
flutter test
```

## Architecture

### State Management: Riverpod
- All providers are in `*_provider.dart` files within feature folders
- Use `AsyncValue` for API calls (handles Loading/Error/Data states)
- Key providers: `authStateProvider`, `creditsProvider`, `creationProvider`, `adminAuthControllerProvider`

### Navigation: GoRouter
- Routes defined in `lib/core/router/app_router.dart`
- Two separate auth flows:
  - **Mobile app**: Firebase phone OTP auth (`/login`, `/home`, `/my-creations`, etc.)
  - **Admin web dashboard**: Firestore-based admin auth (`/admin/*` routes)
- Admin routes are checked FIRST in redirect logic before mobile auth

### Feature Structure
```
lib/features/{feature}/
├── data/           # Repositories, data sources
├── domain/         # Models, business logic
└── presentation/   # Screens, widgets, providers
```

### Key Features
- `auth/` - Phone OTP login, account settings, admin login
- `home/` - Multi-step video creation wizard (idea → style → review)
- `creation/` - AI pipeline orchestration, loading animations
- `preview/` - Video player, sharing
- `payment/` - Tap Payments integration (credit/debit cards, MADA)
- `admin/` - Web dashboard (users, content, payments)

### AI Services (`lib/services/ai/`)
Strategy pattern for swappable AI providers:
- `kie_ai_service.dart` - Kie.ai for video/image generation (Sora 2, Veo3, Nano Banana Pro)
- `openai_service.dart` - GPT for prompt enhancement
- `eleven_labs_service.dart` - Text-to-speech

### Firestore Data Model
- **Phantom documents issue**: User documents may have subcollections (`creations`, `data`) but no parent document data. When querying users, use `collectionGroup('creations')` to discover users via their content, then extract user IDs from document paths.
- `users/{userId}/creations/{creationId}` - Generated videos/images
- `users/{userId}/data/credits` - User credit balance
- `transactions/` - Payment records

### Localization
- Files: `lib/l10n/app_en.arb`, `lib/l10n/app_ar.arb`
- Generated output: `lib/generated/app_localizations.dart`
- Access in widgets: `AppLocalizations.of(context)!.keyName`
- Supports RTL for Arabic

## Environment Configuration

Required `.env` file (not committed):
```
KIE_API_KEY=your_key
OPENAI_API_KEY=your_key
ELEVEN_LABS_API_KEY=your_key
TAP_PUBLIC_KEY=pk_live_xxxxx
TAP_SECRET_KEY=sk_live_xxxxx
TAP_MERCHANT_ID=your_merchant_id
```

## Key Patterns

### DateTime Handling in Firestore
`createdAt` may be stored as either `Timestamp` or ISO `String`. Always check type before parsing:
```dart
DateTime? createdAt;
if (data['createdAt'] is Timestamp) {
  createdAt = (data['createdAt'] as Timestamp).toDate();
} else if (data['createdAt'] is String) {
  createdAt = DateTime.parse(data['createdAt']);
}
```

### Admin Dashboard Data Queries
Use `collectionGroup` queries instead of direct collection queries to handle phantom user documents:
```dart
final allCreationsSnapshot = await _firestore.collectionGroup('creations').get();
// Extract user IDs from document paths: users/{userId}/creations/{creationId}
```

### UI Theme
Custom "Glassmorphism" design system - purple/white/glass aesthetic. Core widgets in `lib/core/widgets/` (GlassCard, GlassButton, NeumorphicContainer).

## Documentation

- Architecture: `docs/architecture.md`
- API docs: `docs/kie-ai-documentation.md`, `docs/openai-api-documentation.md`
- Localization: `docs/LOCALIZATION_GUIDE.md`
