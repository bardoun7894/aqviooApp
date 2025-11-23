# Technical Context: Epic 2 - User Authentication & Onboarding

## 1. Overview
This epic focuses on the user's first impression and entry into the app. It covers the Splash Screen (with Rive animation), Phone Authentication (using Firebase), and Guest Mode access. The goal is a seamless, "magical" entry experience that adheres to the Glassmorphism design language.

**In-Scope:**
- Splash Screen with Rive Animation (`assets/rive/splash.riv`).
- Phone Authentication Flow (Input -> OTP -> Verify).
- Guest Mode (Anonymous Auth).
- Auth State Persistence (Auto-login).

**Out-of-Scope:**
- User Profile creation (Name, Photo) - deferred to later or post-auth.

## 2. Architecture Alignment
- **State Management:** Riverpod `AsyncNotifier` for Auth State.
- **Navigation:** GoRouter redirects based on Auth State (`/splash` -> `/home` or `/login`).
- **Backend:** Firebase Auth (Phone Provider, Anonymous Provider).
- **UI:** Uses `GlassCard` and `GradientButton` from Epic 1.

## 3. Detailed Design

### 3.1 Module Structure
```
lib/features/auth/
├── data/
│   └── auth_repository.dart   # Firebase Auth Wrapper
├── presentation/
│   ├── providers/
│   │   └── auth_provider.dart # Riverpod StateController
│   ├── screens/
│   │   ├── splash_screen.dart # Rive Animation
│   │   ├── login_screen.dart  # Phone Input
│   │   └── otp_screen.dart    # Code Verification
│   └── widgets/
│       └── auth_glass_card.dart # Specialized GlassCard
```

### 3.2 Auth State Management
We will use a `StreamProvider` to listen to `FirebaseAuth.instance.authStateChanges()`.
GoRouter will use this provider to redirect users:
- If `null` (loading) -> Splash.
- If `User` exists -> Home.
- If `null` (no user) -> Login.

### 3.3 Rive Integration
- **Package:** `rive`
- **Asset:** `assets/rive/splash.riv` (Placeholder for now).
- **Logic:**
    - Play animation on load.
    - Wait for *both* Animation Completion AND Auth State check before navigating.

### 3.4 Phone Auth Logic
1.  **Request Code:** `verifyPhoneNumber`
    - `verificationCompleted`: Auto-sign-in (Android only).
    - `verificationFailed`: Show error snackbar.
    - `codeSent`: Navigate to OTP Screen.
    - `codeAutoRetrievalTimeout`: Handle timeout.
2.  **Verify Code:** `signInWithCredential`.

## 4. Non-Functional Requirements
- **UX:** Splash animation should not exceed 3 seconds unless loading takes longer.
- **Security:** Phone Auth must use reCAPTCHA verification (handled by Firebase SDK).
- **Platform:** iOS requires APNs setup for Phone Auth (simulators use reCAPTCHA).

## 5. Dependencies
- `firebase_auth`
- `rive`
- `pinput` (Optional, for nice OTP fields, or build custom) -> *Decision: Build custom Glass OTP fields.*

## 6. Acceptance Criteria
1.  **Splash:** App opens with animation, then transitions.
2.  **Login UI:** Phone input uses Glassmorphism style.
3.  **Guest:** "Skip" button logs in anonymously and goes to Home.
4.  **Phone:** Valid phone number sends SMS, valid code logs in.
5.  **Logout:** User can log out and return to Login screen.

## 7. Risks & Assumptions
- **Risk:** SMS delivery can be slow.
    - *Mitigation:* Show clear countdown timer and "Resend" button.
- **Assumption:** Developer has enabled "Phone" and "Anonymous" providers in Firebase Console.
