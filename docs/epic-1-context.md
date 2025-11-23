# Technical Context: Epic 1 - Foundation & Core Architecture

## 1. Overview
This epic establishes the bedrock for the Aqvioo application. It involves setting up the Flutter project structure, implementing the "Glassmorphism" design system (as defined in the UX Spec), and creating the abstract AI service layer (as defined in the Architecture). Success here means a compilable, architecturally sound codebase ready for feature development.

**In-Scope:**
- Flutter Project Initialization (`com.aqvioo`).
- Folder Structure Setup (`core`, `features`, `services`).
- Design System Implementation (`GlassCard`, `GradientButton`, Theme).
- AI Service Strategy Pattern (Abstract Base + Stubs).
- Firebase Initialization.

**Out-of-Scope:**
- Functional AI generation (logic only, no real API calls yet).
- UI Screens (Splash, Home, etc. come in later epics).

## 2. Architecture Alignment
- **Framework:** Flutter (Latest Stable).
- **State Management:** Riverpod (for Dependency Injection of Services).
- **Navigation:** GoRouter (Basic setup).
- **Styling:** Custom "Glass" widgets (No external UI library).
- **Backend:** Firebase Core (Auth/Firestore setup).

## 3. Detailed Design

### 3.1 Module Structure
```
lib/
├── main.dart                  # App Entry Point (Riverpod Scope)
├── app.dart                   # MaterialApp, Theme, Router
├── core/
│   ├── theme/
│   │   ├── app_theme.dart     # Light/Dark Theme Data
│   │   ├── app_colors.dart    # Palette (Purple/White/Glass)
│   │   └── app_text_styles.dart # Cairo/Tajawal Fonts
│   ├── widgets/
│   │   ├── glass_card.dart    # Reusable Glass Container
│   │   └── gradient_button.dart # Primary Action Button
│   └── constants/             # API Keys (Env), Asset Paths
├── services/
│   ├── ai/
│   │   ├── ai_service.dart    # Abstract Base Class
│   │   ├── openai_service.dart# Concrete Impl (Stub)
│   │   ├── kie_service.dart   # Concrete Impl (Stub)
│   │   └── tts_service.dart   # Concrete Impl (Stub)
│   └── firebase_service.dart  # Core Init
```

### 3.2 Design System Components

**`GlassCard` Widget:**
- **Input:** `child`, `opacity` (default 0.2), `borderRadius` (default 24).
- **Implementation:**
    - `ClipRRect` -> `BackdropFilter` (Blur 10-20px).
    - `Container` (Color: White.withOpacity).
    - `Border` (White.withOpacity(0.5)).

**`GradientButton` Widget:**
- **Input:** `onPressed`, `label`, `icon`.
- **Implementation:**
    - `Container` with `LinearGradient` (Purple `#7C3AED` -> Dark Purple `#6D28D9`).
    - Shadow: `BoxShadow` (Purple.withOpacity(0.3)).

### 3.3 AI Service Layer (Strategy Pattern)

**`AIService` Interface:**
```dart
abstract class AIService {
  Future<String> generateScript(String prompt);
  Future<String> generateAudio(String script);
  Future<String> generateVideo(String script, String audioUrl);
}
```
*Note: This allows us to swap `KieService` with `FlikiService` later without breaking the UI.*

## 4. Non-Functional Requirements
- **Performance:** App launch < 2s (Splash optimized).
- **Compatibility:** iOS 14+ and Android 10+.
- **Localization:** Support RTL (Arabic) from day one in `MaterialApp`.

## 5. Dependencies
- `flutter_riverpod: ^2.5.0`
- `go_router: ^14.0.0`
- `firebase_core: ^latest`
- `google_fonts: ^latest`
- `flutter_dotenv: ^latest` (For API Keys)

## 6. Acceptance Criteria
1.  **Project Builds:** `flutter run` works on iOS Simulator and Android Emulator.
2.  **Structure Exists:** `lib/core`, `lib/features`, `lib/services` folders are present.
3.  **Theme Applied:** App starts with Purple/White theme and Arabic font support.
4.  **Glass Widget:** A test screen shows a `GlassCard` with blur effect working.
5.  **Service Injection:** A Riverpod provider for `AIService` can be read without error.

## 7. Risks & Assumptions
- **Risk:** Glassmorphism can be performance-heavy on older Androids.
    - *Mitigation:* Use lower blur radius on low-end devices if needed.
- **Assumption:** User has valid API keys for OpenAI/Kie/ElevenLabs (we will use placeholders for now).
