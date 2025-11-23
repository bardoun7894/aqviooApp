# Technical Context: Epic 3 - The "Magic" Creation Flow

## 1. Overview
This epic implements the core value proposition of Aqvioo: converting user input (Text or Image) into a video. It covers the Home Screen (Input), the "Magic" Loading State (orchestrating the AI pipeline), and the transition to the Preview screen.

**In-Scope:**
- Home Screen UI (Glassmorphism Input Area).
- Image Picker Integration (Gallery/Camera).
- `CreationController` (State Management for the pipeline).
- "Magic" Loading Screen (Rive Animation + Progress).
- Error Handling (e.g., API failures).

**Out-of-Scope:**
- Video Playback (Preview is Epic 4).
- Payment Logic (Monetization is Epic 5).

## 2. Architecture Alignment
- **State Management:** `StateNotifier` (`CreationState`) to track the pipeline steps: `idle` -> `script` -> `audio` -> `video` -> `success`.
- **Services:** Uses `AIService` (Composite) defined in Epic 1.
- **Navigation:** `GoRouter` pushes `/preview` upon success, passing the video URL.

## 3. Detailed Design

### 3.1 Module Structure
```
lib/features/creation/
├── presentation/
│   ├── providers/
│   │   └── creation_provider.dart # Manages pipeline state
│   ├── screens/
│   │   └── magic_loading_screen.dart # Rive Animation
│   └── widgets/
│       └── input_area.dart        # Text + Image Picker
lib/features/home/
├── presentation/
│   └── screens/
│       └── home_screen.dart       # Main Entry
```

### 3.2 Creation Pipeline Logic (`CreationController`)
The controller will execute the following sequence:
1.  **Input Validation:** Ensure text is not empty.
2.  **Generate Script:** Call `AIService.generateScript(text)`.
3.  **Generate Audio:** Call `AIService.generateAudio(script)`.
4.  **Generate Video:** Call `AIService.generateVideo(script, audio, image)`.
5.  **Success:** Store result in state and trigger navigation.

### 3.3 UI Components
- **Home Screen:**
    - Large `GlassCard` for text input.
    - "Add Image" button (Icon + Text).
    - "Generate Magic" `GradientButton`.
- **Magic Loading:**
    - Full-screen Rive animation (`assets/rive/magic.riv`).
    - Dynamic text updating ("Dreaming up a story...", "Finding the right voice...", "Painting the pixels...").

## 4. Non-Functional Requirements
- **Feedback:** User must see progress updates (the pipeline can take 10-30s).
- **Resilience:** If one step fails, allow retry without losing input.
- **Assets:** Image uploads must be compressed/resized before sending to API to save bandwidth.

## 5. Dependencies
- `image_picker`
- `rive`
- `go_router`

## 6. Acceptance Criteria
1.  **Input:** User can type text and optionally select an image.
2.  **Trigger:** Clicking "Generate" starts the pipeline and shows loading UI.
3.  **Progress:** Loading screen shows different messages for Script/Audio/Video steps.
4.  **Success:** App navigates to Preview screen with a valid video URL.
5.  **Error:** Failures show a friendly Glassmorphism dialog/snackbar.

## 7. Risks & Assumptions
- **Risk:** AI APIs (especially Video) can be slow.
    - *Mitigation:* Engaging Rive animation is critical to reduce perceived wait time.
- **Assumption:** Mock services from Epic 1 are sufficient for now (real API integration can happen later or in parallel).
