# Technical Context: Epic 4 - Preview & Refinement

## 1. Overview
This epic focuses on the "Result" phase. After the "Magic" creation, the user lands on the Preview Screen. Here, they can watch the generated video, apply different "Vibes" (styles) by swiping, and finally export their creation.

**In-Scope:**
- **Video Player:** Full-screen playback using `video_player` and `chewie`.
- **Swipe for Style:** Horizontal swipe gestures to cycle through pre-defined styles (e.g., "Cinematic", "Cyberpunk", "Cartoon").
- **Save & Share:** Save to Gallery (`gallery_saver`) and Share via system dialog (`share_plus`).
- **Remake:** Option to go back and edit the prompt.

**Out-of-Scope:**
- Advanced Video Editing (Trimming, Text Overlays) - This is a "One-Click" app.

## 2. Architecture Alignment
- **State Management:** `PreviewController` manages the `currentStyleIndex` and the `VideoPlayerController`.
- **Navigation:** `GoRouter` receives the initial `videoUrl` as an extra parameter.
- **Services:**
    - `StyleService`: Provides a list of available styles (mocked for now).
    - `AIService`: Used if "Swipe for Style" triggers a quick re-generation (or just switches assets). *Strategy: For MVP, we will simulate style switching by changing color filters or mock video URLs.*

## 3. Detailed Design

### 3.1 Module Structure
```
lib/features/preview/
├── presentation/
│   ├── providers/
│   │   └── preview_provider.dart # Manages player & styles
│   ├── screens/
│   │   └── preview_screen.dart   # Main UI
│   └── widgets/
│       ├── video_player_view.dart
│       └── style_switcher.dart   # Swipe indicators
```

### 3.2 Swipe for Style Logic
- **Interaction:** User swipes Left/Right.
- **Feedback:** A Glassmorphism overlay shows the new style name (e.g., "Cyberpunk") for 2 seconds then fades out.
- **Implementation:** `GestureDetector` on top of the video player.
- **Effect:**
    - *Ideal:* Triggers a fast re-render with new parameters.
    - *MVP:* Applies a `ColorFilter` or switches to a different pre-generated mock URL to demonstrate the concept.

### 3.3 Save & Share
- **Save:** Checks permissions -> Downloads video -> Saves to Camera Roll -> Shows "Saved!" Snackbar.
- **Share:** Downloads temp file -> Opens System Share Sheet.

## 4. Non-Functional Requirements
- **Performance:** Video playback must be smooth (60fps).
- **Latency:** Style switching should feel instant (<200ms).
- **Storage:** Clean up temporary files after sharing.

## 5. Dependencies
- `video_player`
- `chewie` (optional, might use raw `VideoPlayer` for custom UI) -> *Decision: Use raw `VideoPlayer` for cleaner "TikTok-style" look.*
- `gallery_saver`
- `share_plus`
- `path_provider`

## 6. Acceptance Criteria
1.  **Playback:** Video plays automatically on loop.
2.  **Styles:** Swiping changes the visual style (filter/overlay) and shows the style name.
3.  **Save:** Tapping "Save" successfully stores the video.
4.  **Share:** Tapping "Share" opens the native sheet.
5.  **Navigation:** Back button returns to Home (resetting state).

## 7. Risks & Assumptions
- **Risk:** `video_player` on Windows/Simulator can be flaky.
    - *Mitigation:* Test on real device if possible, or accept Simulator limitations (sometimes black screen).
- **Assumption:** The "Video URL" provided by the previous step is accessible and playable.
