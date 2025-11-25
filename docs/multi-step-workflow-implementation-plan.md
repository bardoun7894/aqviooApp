# Implementation Plan: Multi-Step Home Screen Workflow

**Project:** Aqvioo Mobile App  
**Feature:** 3-Step Content Generation Wizard (Idea → Style → Finalize)  
**Author:** Mary (Business Analyst)  
**Date:** 2025-11-25

---

## Overview

Transform the current single-screen home experience into a 3-step wizard that allows users to configure video/image generation preferences before creating content using Kie AI's Sora 2 API.

---

## User Review Required

> [!WARNING]
> **Critical Image Upload Decision Needed**
> 
> The brief mentions "user can upload image and app converts image to marketing video" but **Sora 2 API is text-to-video only** (no image input).
> 
> **Options:**
> - A) Remove image upload from video workflow (keep for image generation only)
> - B) Use uploaded image as visual reference for prompt enhancement
> - C) Find different API for image-to-video conversion
>
> **Please decide before implementation begins.**

> [!IMPORTANT]
> **Simplified Step 2 Configuration**
> 
> Due to Sora 2 API limitations, Step 2 options are now simpler than initially planned:
> - ~~Style selection~~ (REMOVED - not supported)
> - ~~Quality tiers~~ (REMOVED - only one Sora 2 model)
> - ~~25s duration~~ (REMOVED - API only supports 10s/15s)
> 
> **Remaining options:**
> - Duration: 10s or 15s
> - Aspect Ratio: 16:9 or 9:16
> - Watermark: Remove or Keep
> - Voice: Male/Female + Dialect selection
> 
> **Question:** Are these sufficient configuration options?

> [!CAUTION]
> **Audio Merge Complexity**
> 
> Sora 2 doesn't automatically merge TTS audio with video. We need to implement post-processing.
> 
> **Recommended approach:** Server-side merge using Firebase Functions + FFmpeg
> - Requires cloud function deployment
> - Adds 10-20 seconds to generation time
> - More reliable than client-side processing

---

## Proposed Changes

### Component: Home Screen UI

#### [MODIFY] [home_screen.dart](file:///Users/mac/aqvioo/lib/features/home/presentation/screens/home_screen.dart)

**Current State:**
- Single screen with prompt input, image upload, and generate button
- Step indicators showing "Idea, Style, Finalize" but not functional
- Direct navigation to magic loading screen on generate

**Changes:**
1. **Convert to Multi-Step Wizard**
   - Implement PageView or stepper widget for 3 steps
   - Add navigation controls (Back, Next, Generate buttons)
   - Update step indicators to be interactive/clickable

2. **Step 1 - Idea Input** (Minimal changes)
   - Keep existing prompt input field
   - Keep image upload functionality (pending decision on image-to-video)
   - Add "Next" button instead of "Generate"
   - Validate prompt is not empty before allowing next

3. **Step 2 - Style Configuration** (New UI)
   - **Output Type Selector:** Video or Image tabs/toggle
   - **Video Options Section:**
     - Duration selector: 10s or 15s (segmented control)
     - Aspect ratio toggle: 16:9 (landscape) or 9:16 (portrait)
     - Watermark toggle: Remove (default) or Keep
     - Voice gender: Male or Female (radio buttons/segmented control)
     - Arabic dialect dropdown: Saudi (default), Egyptian, UAE, Lebanese, Jordanian, Moroccan
   - **Image Options Section** (when Output Type = Image):
     - Style: Realistic, Cartoon, Artistic
     - Size: Square, Landscape, Portrait
   - "Back" and "Next" buttons

4. **Step 3 - Review & Finalize** (New UI)
   - Display summary card showing:
     - Prompt preview (truncated if long)
     - Image thumbnail if uploaded
     - All selected settings
     - Price: 2.99 SAR
     - Free trial badge if applicable
   - "Edit" buttons for each section → navigate back to respective step
   - "Back" button → return to Step 2
   - "Generate" button (pulsing orb design) → start generation

5. **State Management**
   - Expand `CreationConfig` model to store all step data
   - Preserve state when navigating between steps
   - Clear state only on wizard exit or successful generation

---

### Component: Data Models

#### [NEW] [creation_config.dart](file:///Users/mac/aqvioo/lib/features/creation/domain/models/creation_config.dart)

Create comprehensive configuration model:

```dart
class CreationConfig {
  // Step 1: Idea
  final String prompt;
  final String? imagePath;
  
  // Step 2: Output Type
  final OutputType outputType; // video | image
  
  // Step 2: Video Settings
  final int? videoDuration; // 10 or 15
  final String? videoAspectRatio; // "landscape" or "portrait"
  final bool removeWatermark; // default true
  final VoiceGender? voiceGender; // male | female
  final String? voiceDialect; // ar-SA, ar-EG, etc.
  
  // Step 2: Image Settings
  final ImageStyle? imageStyle; // realistic | cartoon | artistic
  final String? imageSize; // 1024x1024, etc.
}

enum OutputType { video, image }
enum VoiceGender { male, female }
enum ImageStyle { realistic, cartoon, artistic }
```

---

### Component: Kie AI Service

#### [MODIFY] [kie_ai_service.dart](file:///Users/mac/aqvioo/lib/core/services/kie_ai_service.dart)

**Update video generation method to use Sora 2 API:**

```dart
Future<String> generateVideoSora2({
  required String prompt,
  required String aspectRatio, // "landscape" or "portrait"
  required String nFrames, // "10" or "15"
  bool removeWatermark = true,
  String? callBackUrl,
}) async {
  final response = await http.post(
    Uri.parse('https://api.kie.ai/api/v1/jobs/createTask'),
    headers: {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'model': 'sora-2-text-to-video',
      'input': {
        'prompt': prompt,
        'aspect_ratio': aspectRatio,
        'n_frames': nFrames,
        'remove_watermark': removeWatermark,
      },
      if (callBackUrl != null) 'callBackUrl': callBackUrl,
    }),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['code'] == 200) {
      return data['data']['taskId'];
    }
  }
  
  throw Exception('Failed to generate video');
}

Future<Map<String, dynamic>> checkSora2TaskStatus(String taskId) async {
  final response = await http.get(
    Uri.parse('https://api.kie.ai/api/v1/jobs/recordInfo?taskId=$taskId'),
    headers: {
      'Authorization': 'Bearer $_apiKey',
    },
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['code'] == 200) {
      return {
        'state': data['data']['state'], // waiting | success | fail
        'videoUrl': data['data']['state'] == 'success' 
          ? jsonDecode(data['data']['resultJson'])['resultUrls'][0]
          : null,
      };
    }
  }
  
  throw Exception('Failed to check status');
}
```

---

### Component: Creation Provider (State Management)

#### [MODIFY] [creation_provider.dart](file:///Users/mac/aqvioo/lib/features/creation/presentation/providers/creation_provider.dart)

**Add wizard state management:**

```dart
class CreationController extends StateNotifier<CreationState> {
  // ... existing code ...
  
  // New: Store current step and configuration
  int currentStep = 0;
  CreationConfig config = CreationConfig.empty();
  
  void updateConfig(CreationConfig newConfig) {
    config = newConfig;
  }
  
  void goToNextStep() {
    if (currentStep < 2) {
      currentStep++;
      state = state.copyWith(wizardStep: currentStep);
    }
  }
  
  void goToPreviousStep() {
    if (currentStep > 0) {
      currentStep--;
      state = state.copyWith(wizardStep: currentStep);
    }
  }
  
  void goToStep(int step) {
    currentStep = step;
    state = state.copyWith(wizardStep: step);
  }
  
  Future<void> generateVideo() async {
    // Generate based on config.outputType
    if (config.outputType == OutputType.video) {
      await _generateVideoWorkflow();
    } else {
      await _generateImageWorkflow();
    }
  }
  
  Future<void> _generateVideoWorkflow() async {
    try {
      state = state.copyWith(status: CreationStatus.generatingScript);
      
      // 1. Enhance prompt (optional)
      final enhancedPrompt = await _kieService.generateMarketingText(
        config.prompt,
        language: 'ar',
      );
      
      // 2. Generate video with Sora 2
      final taskId = await _kieService.generateVideoSora2(
        prompt: enhancedPrompt,
        aspectRatio: config.videoAspectRatio!,
        nFrames: config.videoDuration!.toString(),
        removeWatermark: config.removeWatermark,
      );
      
      // 3. Poll for completion
      String? videoUrl;
      while (videoUrl == null) {
        await Future.delayed(Duration(seconds: 5));
        final status = await _kieService.checkSora2TaskStatus(taskId);
        
        if (status['state'] == 'success') {
          videoUrl = status['videoUrl'];
        } else if (status['state'] == 'fail') {
          throw Exception('Video generation failed');
        }
        // Update progress in state
      }
      
      // 4. Generate TTS (Arabic voice)
      final audioUrl = await _kieService.generateSpeech(
        enhancedPrompt,
        language: config.voiceDialect ?? 'ar-SA',
        voice: config.voiceGender == VoiceGender.male ? 'male' : 'female',
      );
      
      // 5. Merge audio + video (Firebase Function or skip for MVP)
      final finalVideoUrl = await _mergeAudioVideo(videoUrl, audioUrl);
      
      state = state.copyWith(
        status: CreationStatus.success,
        videoUrl: finalVideoUrl,
      );
    } catch (e) {
      state = state.copyWith(
        status: CreationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}
```

---

### Component: Firebase Cloud Function (Audio Merge)

#### [NEW] [functions/src/mergeAudioVideo.ts](file:///Users/mac/aqvioo/functions/src/mergeAudioVideo.ts)

**Create serverless function to merge audio and video:**

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as ffmpeg from 'fluent-ffmpeg';
import * as fs from 'fs';
import * as path from 'path';
import * as os from 'os';

export const mergeAudioVideo = functions.https.onCall(async (data, context) => {
  const { videoUrl, audioUrl } = data;
  
  // Download video and audio to temp directory
  const tempDir = os.tmpdir();
  const videoPath = path.join(tempDir, 'video.mp4');
  const audioPath = path.join(tempDir, 'audio.mp3');
  const outputPath = path.join(tempDir, 'output.mp4');
  
  // Download files
  await downloadFile(videoUrl, videoPath);
  await downloadFile(audioUrl, audioPath);
  
  // Merge using FFmpeg
  await new Promise((resolve, reject) => {
    ffmpeg()
      .input(videoPath)
      .input(audioPath)
      .outputOptions('-c:v copy')
      .outputOptions('-c:a aac')
      .save(outputPath)
      .on('end', resolve)
      .on('error', reject);
  });
  
  // Upload merged video to Firebase Storage
  const bucket = admin.storage().bucket();
  const fileName = `videos/${Date.now()}_final.mp4`;
  await bucket.upload(outputPath, {
    destination: fileName,
    metadata: { contentType: 'video/mp4' },
  });
  
  // Get public URL
  const file = bucket.file(fileName);
  const [url] = await file.getSignedUrl({
    action: 'read',
    expires: '03-01-2500',
  });
  
  // Cleanup temp files
  fs.unlinkSync(videoPath);
  fs.unlinkSync(audioPath);
  fs.unlinkSync(outputPath);
  
  return { videoUrl: url };
});
```

---

## Verification Plan

### Automated Tests

> [!NOTE]
> Currently no existing tests found in the repository for home screen or creation flow.

**Proposed New Tests:**

1. **Unit Tests for CreationConfig Model**
   - Create: `test/features/creation/domain/models/creation_config_test.dart`
   - Test validation logic
   - Test default values
   - Run with: `flutter test test/features/creation/domain/models/creation_config_test.dart`

2. **Widget Tests for Home Screen Steps**
   - Create: `test/features/home/presentation/screens/home_screen_test.dart`
   - Test step navigation (Next, Back buttons)
   - Test form validation
   - Test state preservation across steps
   - Run with: `flutter test test/features/home/presentation/screens/home_screen_test.dart`

3. **Integration Tests for Kie AI Service**
   - Create: `test/core/services/kie_ai_service_test.dart`
   - Mock HTTP responses for Sora 2 API
   - Test task creation and status polling
   - Run with: `flutter test test/core/services/kie_ai_service_test.dart`

### Manual Verification

> [!IMPORTANT]
> **Manual Testing Required**
> 
> The following scenarios require manual testing with actual Kie AI API:

#### Test Scenario 1: Complete Video Generation Flow

**Prerequisites:**
- Valid Kie AI API key configured
- App running on device/emulator: `flutter run`

**Steps:**
1. Open app and navigate to home screen
2. **Step 1 - Idea:**
   - Enter Arabic prompt: "إعلان سيارة فاخرة في الصحراء"
   - Optionally upload an image
   - Tap "Next"
   - ✅ Verify: Navigation to Step 2
   - ✅ Verify: Step indicator shows Step 2 active

3. **Step 2 - Style:**
   - Select Output Type: **Video**
   - Duration: **15s**
   - Aspect Ratio: **16:9**
   - Watermark: **Remove** (toggle on)
   - Voice: **Female**
   - Dialect: **Saudi**
   - Tap "Next"
   - ✅ Verify: Navigation to Step 3
   - ✅ Verify: No errors or crashes

4. **Step 3 - Review:**
   - ✅ Verify: Prompt preview shows correctly
   - ✅ Verify: All settings displayed accurately
   - ✅ Verify: Price shown as 2.99 SAR
   - Tap "Generate"
   - ✅ Verify: Navigation to magic loading screen
   - ✅ Verify: Progress updates appear

5. **Generation Completion:**
   - Wait for video generation (~60-90 seconds)
   - ✅ Verify: Navigation to preview screen
   - ✅ Verify: Video plays successfully
   - ✅ Verify: Video has Arabic voiceover
   - ✅ Verify: Aspect ratio is 16:9
   - ✅ Verify: No watermark present

#### Test Scenario 2: Image Generation Flow

**Steps:**
1. Navigate to Step 1
2. Enter prompt: "صورة لحديقة جميلة مع أشجار"
3. Tap "Next"
4. **Step 2:**
   - Select Output Type: **Image**
   - Style: **Realistic**
   - Size: **Landscape**
   - Tap "Next"
5. **Step 3:**
   - Verify image settings shown
   - Tap "Generate"
6. ✅ Verify: Image generated successfully using Nano Banana Pro
7. ✅ Verify: Image dimensions match selection

#### Test Scenario 3: Navigation Back & Edit

**Steps:**
1. Complete all 3 steps and reach Step 3 (Review)
2. Tap "Back" button
   - ✅ Verify: Returns to Step 2
   - ✅ Verify: Previous selections preserved
3. Change Duration from 15s to 10s
4. Tap "Next"
   - ✅ Verify: Return to Step 3
   - ✅  Verify: Duration updated in preview
5. Tap "Edit" button next to Idea section
   - ✅ Verify: Navigate back to Step 1
   - ✅ Verify: Original prompt still filled in

#### Test Scenario 4: Validation

**Steps:**
1. **Step 1 - Empty Prompt:**
   - Leave prompt field empty
   - Tap "Next"
   - ✅ Verify: Error message shown
   - ✅ Verify: Cannot proceed to Step 2

2. **Special Characters in Prompt:**
   - Enter prompt with Arabic diacritics and emojis
   - ✅ Verify: Accepted without errors

3. **Maximum Length:**
   - Enter very long prompt (500+ characters)
   - ✅ Verify: Appropriate handling (truncate or show error)

#### Test Scenario 5: Error Handling

**Steps:**
1. Turn off internet connection
2. Complete wizard and tap "Generate"
   - ✅ Verify: Offline error message shown
   - ✅ Verify: Option to retry when back online

2. Use invalid API key (temporarily)
   - ✅ Verify: Authentication error shown clearly
   - ✅ Verify: No app crash

---

## Dependencies

### Flutter Packages

Add to `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0 # For API calls
  flutter_riverpod: ^2.4.9 # State management (already included)
  go_router: ^12.1.3 # Navigation (already included)
  
  # For image picker
  image_picker: ^1.0.5 # (already included)
  
  # For video processing (if client-side merge)
  # ffmpeg_kit_flutter: ^6.0.3 # (optional - only if not using Firebase Function)
```

### Firebase Cloud Functions

```bash
cd functions
npm install fluent-ffmpeg
npm install --save-dev @types/fluent-ffmpeg
```

**Deploy:**
```bash
firebase deploy --only functions:mergeAudioVideo
```

---

## Timeline Estimate

| Phase | Tasks | Estimated Time |
|-------|-------|----------------|
| **Phase 1: Data Models** | Create `CreationConfig` and enums | 2 hours |
| **Phase 2: UI - Step 1** | Minor modifications to existing screen | 1 hour |
| **Phase 3: UI - Step 2** | Build configuration screen | 6 hours |
| **Phase 4: UI - Step 3** | Build review screen | 4 hours |
| **Phase 5: Navigation** | Implement wizard flow and state | 4 hours |
| **Phase 6: API Integration** | Update Kie AI service for Sora 2 | 4 hours |
| **Phase 7: Firebase Function** | Audio/video merge function | 6 hours |
| **Phase 8: Testing** | Unit + widget + manual tests | 8 hours |
| **Phase 9: Polish** | Animations, error handling, UX improvements | 4 hours |
| **Total** | | **39 hours (~5 days)** |

---

## Rollout Strategy

### Phase 1: MVP (Simplified)

**Scope:**
- 3-step wizard with basic UI
- Sora 2 video generation (10s and 15s only)
- **Skip audio merge** - video only (no TTS)
- Image generation with Nano Banana
- Basic error handling

**Benefits:**
- Faster to market (~3 days instead of 5)
- Prove wizard concept
- Gather user feedback on flow

### Phase 2: Full Feature (TTS + Audio Merge)

**Scope:**
- Add TTS integration
- Deploy Firebase Function for audio merge
- Enhanced error handling
- Performance monitoring

---

## Post-Implementation Recommendations

1. **Analytics Tracking**
   - Track which step users abandon most
   - Measure average time per step
   - Monitor generation success rate by duration/aspect ratio

2. **A/B Testing Opportunities**
   - Default duration (10s vs 15s)
   - Step 2 layout (list vs cards)
   - Number of voice dialect options

3. **Future Enhancements**
   - Add "Save Draft" feature
   - Allow editing after generation
   - Batch generation queue
   - Advanced prompt templates/suggestions

---

**Plan Status:** Draft - Awaiting Mohamed's decisions on open questions  
**Next Action:** Review this plan and answer critical questions in requirements doc
