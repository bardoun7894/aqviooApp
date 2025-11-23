# Aqvioo mobile Architecture Document

_Created on 2025-11-23 by mohamed_
_Generated using BMad Method - Create Architecture Workflow v1.0_

---

## 1. Executive Summary

**Architecture Approach:**
Aqvioo is built as a **Flutter** mobile application using the **MVVM** (Model-View-ViewModel) pattern with **Riverpod** for state management. The backend relies on **Firebase** (Auth, Firestore, Storage) for a serverless, scalable foundation. The core AI logic is encapsulated in a **Strategy Pattern** service layer, allowing seamless switching between AI providers (Kie.ai, Eleven Labs, OpenAI) without affecting the UI.

**Key Differentiator:**
The architecture explicitly supports the "Glassmorphism" design system through a custom UI layer and utilizes **Rive** for high-performance, interactive motion graphics that define the "Magic" user experience.

---

## 2. Project Initialization

The project will be initialized using the standard Flutter CLI with specific flags for organization.

**Initialization Command:**
```bash
flutter create --org com.aqvioo --platforms android,ios aqvioo_app
```

**Provided Decisions:**
- **Language:** Dart (Null Safety)
- **Platforms:** iOS, Android
- **Structure:** Standard Flutter `lib/` structure (customized below)

---

## 3. Decision Summary Table

| Category | Decision | Verified Version | Rationale |
| :--- | :--- | :--- | :--- |
| **Framework** | **Flutter** | 3.24.x (Stable) | Cross-platform, high performance, best for custom UI (Glassmorphism). |
| **State Management** | **Riverpod** | ^2.5.0 | Compile-safe, testable, great for async AI streams. |
| **Backend** | **Firebase** | Latest | Serverless, real-time, easy Auth/Storage integration. |
| **Navigation** | **GoRouter** | ^14.0.0 | Deep linking, declarative routing for complex flows. |
| **AI Video** | **Kie.ai** | API | Initial MVP provider for video/image generation. |
| **AI Audio** | **Eleven Labs** | API | Best-in-class text-to-speech quality for Arabic. |
| **AI Text** | **OpenAI (GPT-4o)** | API | Script generation and refinement. |
| **Payments** | **Tabby SDK** | `tabby_flutter_inapp_sdk` | **User Request:** Saudi BNPL provider integration. |
| **Motion** | **Rive** | `rive: ^0.13.0` | Interactive animations for "Magic" states. |
| **Localization** | **flutter_localizations** | Standard | Native RTL support for Arabic. |

---

## 4. Project Structure

The source code will be organized by **Feature** to ensure scalability.

```
lib/
├── main.dart                  # App Entry Point
├── app.dart                   # App Widget (Theme, Router, Localization)
├── core/                      # Shared Kernel
│   ├── config/                # Env variables, API Keys
│   ├── theme/                 # Glassmorphism Theme Data
│   ├── utils/                 # Helpers (Validators, Formatters)
│   ├── widgets/               # Shared UI (GlassCard, GradientButton)
│   └── constants/             # App Strings, Asset Paths
├── features/                  # Feature Modules
│   ├── auth/                  # Login, OTP, Guest Logic
│   ├── home/                  # Input Screen, Image Picker
│   ├── creation/              # AI Pipeline Logic (The "Magic")
│   ├── preview/               # Video Player, Swipe Logic
│   ├── payment/               # Tabby Integration, Credit Logic
│   └── profile/               # User Settings, History
├── services/                  # Data & API Layer
│   ├── ai/                    # AI Strategy Implementation
│   │   ├── ai_service.dart    # Abstract Base Class
│   │   ├── kie_service.dart   # Video/Image Impl
│   │   ├── openai_service.dart# Text Impl
│   │   └── tts_service.dart   # Audio Impl
│   ├── auth_service.dart      # Firebase Auth Wrapper
│   ├── database_service.dart  # Firestore Wrapper
│   └── payment_service.dart   # Tabby SDK Wrapper
└── models/                    # Data Models (Freezed/JsonSerializable)
    ├── user_model.dart
    ├── project_model.dart
    └── transaction_model.dart
```

---

## 5. Epic to Architecture Mapping

| Epic | Component / Service |
| :--- | :--- |
| **User Auth** | `features/auth`, `AuthService` (Firebase) |
| **Create Video** | `features/home`, `features/creation`, `AIService` (Kie/OpenAI) |
| **Preview & Edit** | `features/preview`, `VideoPlayer`, `Rive` (Swipe Interactions) |
| **Payments** | `features/payment`, `TabbyService` (`tabby_flutter_inapp_sdk`) |
| **History** | `features/profile`, `DatabaseService` (Firestore) |

---

## 6. Integration Points

### 6.1 AI Pipeline (The "Brain")
The app orchestrates multiple APIs to create one video. This logic lives in `features/creation/controllers/creation_controller.dart`.

**Flow:**
1.  **Input:** User Text -> `OpenAIService` -> Refined Script.
2.  **Audio:** Script -> `ElevenLabsService` -> Audio File (URL).
3.  **Visual:** Script/Image -> `KieService` -> Video/Image (URL).
4.  **Assembly:** (If needed) FFmpeg or Cloud Function to merge Audio + Video (or handled by Kie).

### 6.2 Payment Gateway (Tabby)
Integration via `tabby_flutter_inapp_sdk`.
- **Trigger:** User clicks "Pay" or "Subscribe".
- **Flow:** App creates session -> Launches Tabby Webview/SDK -> User pays -> Tabby Webhook updates Firestore -> App unlocks feature.

---

## 7. Implementation Patterns

### 7.1 Naming Conventions
- **Files:** `snake_case` (e.g., `user_profile.dart`)
- **Classes:** `PascalCase` (e.g., `UserProfile`)
- **Variables:** `camelCase` (e.g., `userName`)
- **Constants:** `SCREAMING_SNAKE_CASE` (e.g., `API_BASE_URL`)

### 7.2 State Management (Riverpod)
- Use `AsyncValue` for all API calls to handle Loading/Error/Data states automatically.
- **Controller Pattern:**
    ```dart
    @riverpod
    class AuthController extends _$AuthController {
      Future<void> signIn() async {
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(() => _authService.signIn());
      }
    }
    ```

### 7.3 Error Handling
- **Global:** `runApp` wrapped in `runZonedGuarded` to catch crashes.
- **UI:** `AsyncValue.when` handles UI error states gracefully.
- **User Facing:** Friendly error messages (e.g., "The AI is taking a nap" instead of "500 Server Error").

---

## 8. Data Architecture

### 8.1 Firestore Schema

**Collection: `users`**
- `uid` (String): Auth ID
- `credits` (int): Remaining generations
- `isPremium` (bool): Subscription status
- `createdAt` (Timestamp)

**Collection: `projects`**
- `id` (String): UUID
- `userId` (String): Owner
- `prompt` (String): Original text
- `videoUrl` (String): Final result
- `thumbnailUrl` (String): Preview
- `status` (enum): `generating`, `completed`, `failed`
- `createdAt` (Timestamp)

---

## 9. Security Architecture

- **API Keys:** Stored in `flutter_dotenv` (.env file), **NEVER** committed to Git.
- **Firebase Rules:**
    - `users`: Read/Write only by `request.auth.uid`.
    - `projects`: Read/Write only by owner.
- **Payment:** Server-side verification of Tabby transactions (via Cloud Functions) recommended to prevent client-side spoofing.

---

## 10. Performance Considerations

- **Asset Optimization:** Use `.webp` for static images and `.riv` (Rive) for animations (tiny file size).
- **Lazy Loading:** Use `ListView.builder` for history lists.
- **Caching:** `cached_network_image` for thumbnails to save bandwidth.

---

## 11. Deployment Architecture

- **CI/CD:** GitHub Actions / Codemagic (Future).
- **Stores:**
    - Google Play Console (AAB)
    - Apple App Store (IPA via TestFlight)

---

## 12. Architecture Decision Records (ADR)

**ADR-001: Use of Tabby SDK**
- **Decision:** Use `tabby_flutter_inapp_sdk` for payments.
- **Rationale:** Specific requirement for Saudi market BNPL.
- **Consequence:** Must handle camera permissions for KYC and ensure strict compliance with Tabby's integration guidelines.

**ADR-002: Custom Glassmorphism System**
- **Decision:** Build custom widgets instead of using a UI library.
- **Rationale:** "No Black" rule and specific blur requirements are not met by standard Material/Cupertino libraries.

---

**ADR-003: Platform Adaptation Strategy**
- **Decision:** "Consistent Look, Adaptive Feel".
- **Rationale:** The "Glassmorphism" brand identity must be identical on both platforms (Purple/White/Glass). However, **Navigation Behaviors** (Swipe-back on iOS, System Back on Android) and **System Dialogs** (Permissions, Alerts) must respect platform conventions to feel native.
- **Implementation:** Use `Platform.isIOS` to toggle specific behaviors (e.g., `CupertinoModalPopup` vs `MaterialBottomSheet`) while keeping the custom Glass styling.

---
