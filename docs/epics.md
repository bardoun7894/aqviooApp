# Aqvioo Epics & User Stories

_Created on 2025-11-23 by mohamed_
_Generated using BMad Method - Create Epics & Stories Workflow v1.0_

---

## Epic 1: Foundation & Core Architecture
**Goal:** Establish the project structure, design system, and core service layers to enable feature development.

### Story 1.1: Project Initialization & Architecture Setup
**User Story:** As a developer, I want to initialize the Flutter project with the defined architecture so that the team has a consistent codebase.
**Acceptance Criteria:**
- [ ] Flutter project created (`com.aqvioo`)
- [ ] Folder structure set up (`features/`, `core/`, `services/`)
- [ ] `flutter_riverpod` and `go_router` configured
- [ ] `firebase_core` initialized (iOS/Android)
- [ ] Environment variables (`.env`) set up for API keys
**Technical Notes:** See Architecture Doc Section 2 & 4.

### Story 1.2: Glassmorphism Design System Implementation
**User Story:** As a user, I want to see a consistent "Glass" aesthetic so that the app feels premium.
**Acceptance Criteria:**
- [ ] `GlassCard` widget created (BackdropFilter, Border, Gradient)
- [ ] `GradientButton` widget created (Purple gradient)
- [ ] Theme data configured (Light/Dark modes per UX spec)
- [ ] Font family (Cairo/Tajawal) integrated
**Technical Notes:** See UX Spec Section 1.1 & 3.1.

### Story 1.3: AI Service Strategy Implementation
**User Story:** As a developer, I want a flexible AI layer so that we can switch providers easily.
**Acceptance Criteria:**
- [ ] `AIService` abstract class defined
- [ ] `OpenAIService` implemented (Text generation stub)
- [ ] `ElevenLabsService` implemented (Audio generation stub)
- [ ] `KieService` implemented (Video generation stub)
**Technical Notes:** See Architecture Doc Section 6.1.

---

## Epic 2: User Authentication & Onboarding
**Goal:** Enable users to access the app securely via Phone or Guest mode.

### Story 2.1: Splash Screen with Rive Animation
**User Story:** As a user, I want to see a delightful animation when I open the app so that I feel excited.
**Acceptance Criteria:**
- [ ] Splash screen displays Rive animation (Logo Pulse)
- [ ] Checks auth state during animation
- [ ] Navigates to Home (if logged in) or Auth (if not)
**Technical Notes:** Use `rive` package.

### Story 2.2: Phone Authentication (Firebase)
**User Story:** As a user, I want to log in with my phone number so that my account is secure.
**Acceptance Criteria:**
- [ ] Phone number input field (Glass style)
- [ ] OTP verification screen
- [ ] Firebase Auth integration (Verify Phone Number)
- [ ] Error handling for invalid codes
**Technical Notes:** Handle `Platform.isIOS` for auto-fill hints.

### Story 2.3: Guest Mode Access
**User Story:** As a user, I want to try the app without signing up so that I can see if I like it.
**Acceptance Criteria:**
- [ ] "Continue as Guest" button
- [ ] Creates Anonymous Auth session in Firebase
- [ ] Limits functionality (1 free trial)
**Technical Notes:** Convert anonymous to permanent later.

---

## Epic 3: The "Magic" Creation Flow
**Goal:** Implement the core value proposition: Text/Image -> Video.

### Story 3.1: Home Screen & Input
**User Story:** As a user, I want to easily input my idea or image so that I can start creating.
**Acceptance Criteria:**
- [ ] Large text input area (GlassCard)
- [ ] Image picker (Gallery/Camera)
- [ ] "Generate" button (Gradient)
**Technical Notes:** See UX Spec Section 5.1 (Journey 1).

### Story 3.2: The "Magic" Loading State
**User Story:** As a user, I want to be entertained while waiting so that the delay feels shorter.
**Acceptance Criteria:**
- [ ] Full-screen Rive animation ("AI Brain" or "Magic")
- [ ] Progress indicators (Generating Script -> Audio -> Video)
- [ ] Prevents back navigation during generation
**Technical Notes:** Critical for UX.

### Story 3.3: AI Pipeline Orchestration
**User Story:** As a user, I want the app to generate a complete video from my input.
**Acceptance Criteria:**
- [ ] Controller calls `OpenAIService` -> `ElevenLabsService` -> `KieService`
- [ ] Handles errors at each step (with friendly messages)
- [ ] Returns a playable video URL
**Technical Notes:** See Architecture Doc Section 6.1.

---

## Epic 4: Preview & Refinement (The "Vibe Check")
**Goal:** Allow users to view and tweak their generated video.

### Story 4.1: Video Player Implementation
**User Story:** As a user, I want to watch my generated video smoothly.
**Acceptance Criteria:**
- [ ] Video player with Play/Pause controls
- [ ] Auto-play on load
- [ ] Loop functionality
**Technical Notes:** Use `video_player` + `chewie`.

### Story 4.2: Swipe for Style (Rive Integration)
**User Story:** As a user, I want to swipe to change the music/style so that I can fix the "vibe" instantly.
**Acceptance Criteria:**
- [ ] Horizontal swipe gesture detected
- [ ] Triggers Rive state change (visual feedback)
- [ ] Swaps background music track (without re-generating video)
**Technical Notes:** See UX Spec Section 2.2.

### Story 4.3: Save & Share
**User Story:** As a user, I want to save the video to my gallery so that I can post it.
**Acceptance Criteria:**
- [ ] "Save to Gallery" button
- [ ] Permission handling (Storage/Photos)
- [ ] Native Share sheet trigger
**Technical Notes:** Use `gallery_saver` and `share_plus`.

---

## Epic 5: Monetization (Tabby & Credits)
**Goal:** Implement the business model and payment gateway.

### Story 5.1: Credit System Logic
**User Story:** As a user, I want to know how many free videos I have left.
**Acceptance Criteria:**
- [ ] Display credit count in Home/Profile
- [ ] Decrement credit on successful generation
- [ ] Block generation if 0 credits
**Technical Notes:** Firestore `users` collection.

### Story 5.2: Tabby Payment Integration
**User Story:** As a user, I want to pay using Tabby so that I can split the cost.
**Acceptance Criteria:**
- [ ] "Get More Credits" modal
- [ ] Tabby SDK integration (`tabby_flutter_inapp_sdk`)
- [ ] Handle Success/Cancel callbacks
- [ ] Update credits via Cloud Function (secure) or client (MVP)
**Technical Notes:** See Architecture Doc ADR-001.

---

## FR Coverage Matrix
- **FR1 (Auth):** Epic 2 (Stories 2.2, 2.3)
- **FR2 (Create):** Epic 3 (Stories 3.1, 3.3)
- **FR3 (Preview):** Epic 4 (Stories 4.1, 4.2)
- **FR4 (Share):** Epic 4 (Story 4.3)
- **FR5 (Pay):** Epic 5 (Stories 5.1, 5.2)
- **NFR (UX/UI):** Epic 1 (Story 1.2), Epic 2 (Story 2.1), Epic 3 (Story 3.2)
