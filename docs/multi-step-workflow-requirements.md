# Multi-Step Workflow - Requirements Specification

**Project:** Aqvioo Mobile App  
**Feature:** 3-Step Content Generation Wizard  
**Version:** 1.0  
**Date:** 2025-11-25  
**Analyst:** Mary (Business Analyst)

---

## Executive Summary

Transform the current single-screen home experience into a comprehensive 3-step wizard that allows users to configure their video/image generation preferences before creating content. This provides better control, clearer expectations, and a more professional user experience.

---

## User Flow Overview

```
Step 1: Idea Input
    ↓
Step 2: Style & Settings Configuration
    ↓
Step 3: Review & Finalize
    ↓
Generate → Magic Loading Screen → Preview
```

---

## Detailed Requirements

### Step 1: Idea (Prompt & Image Input)

**Purpose:** Capture the user's creative idea or input image

**Components:**
- Multi-line text field for prompt entry (5 lines minimum)
- "Add Image" button for optional image upload
- Image preview with remove option (if uploaded)
- "Next" button (enabled when prompt is not empty)
- Progress indicator: "1 of 3"

**Validation Rules:**
- ✅ Prompt must not be empty to proceed
- ✅ Image is optional
- ✅ Maximum prompt length: 500 characters

**Navigation:**
- Forward: "Next" button → Step 2
- Back: N/A (first step)

---

### Step 2: Style & Settings Configuration

**Purpose:** Allow users to configure output preferences and quality settings

#### 2.1 Output Type Selection

**Options:**
- 📹 **Video** (default)
- 🖼️ **Image**

**Behavior:**
- Selecting "Video" shows video-specific options
- Selecting "Image" hides video options and shows image-specific settings

---

#### 2.2 Video Configuration (when Output Type = Video)

##### 2.2.1 ~~Style Selection~~ (Removed - Not Supported by API)

> **API Limitation:** Sora 2 API does not support style parameters. The model generates videos based solely on the text prompt. Style/aesthetic must be controlled through prompt engineering.

**Recommendation:** Remove style selector UI or move to "Advanced Settings" as prompt modifiers

---

##### 2.2.2 Duration

**Field:** Segmented button control

**Options:**
| Duration | API Value | Estimated Generation Time | Notes |
|----------|-----------|---------------------------|-------|
| 10s | `"10"` | ~30-45 seconds | Fast generation |
| 15s | `"15"` | ~60-90 seconds | **Recommended** - Longer processing |

**Default:** 10s (API default)

**UI:** Display info icon for 15s option indicating longer generation time

> **API Constraint:** Sora 2 only supports 10s and 15s durations (n_frames parameter)

---

##### 2.2.3 Watermark Removal

**Field:** Toggle switch

**Options:**
- ✅ **Remove Watermark** (enabled by default)
- ❌ **Keep Watermark**

**Default:** true (watermark removed)

**API Parameter:** `remove_watermark: boolean`

> **Important:** Sora 2 API does not have "Pro" variant or quality tiers. There is only one Sora 2 model. All videos use the same quality level.

---

##### 2.2.2 Aspect Ratio

**Field:** Toggle or visual selector

**Options:**
| Display | API Value | Use Case |
|---------|-----------|----------|
| **16:9** Horizontal | `"landscape"` | YouTube, TV, Web |
| **9:16** Vertical | `"portrait"` | TikTok, Instagram Reels, Stories |

**Default:** `"landscape"` (16:9)

**API Parameter:** `aspect_ratio: "landscape" | "portrait"`

**UI:** Show visual preview of aspect ratio with platform icons

---

##### 2.2.5 Language

**Field:** Selector (currently single option)

**Options:**
- 🇸🇦 Arabic (default and only option for MVP)

**Future:** English support

---

##### 2.2.6 Voice Settings

**Sub-section:** Arabic Voice Configuration

**Fields:**

1. **Gender Selection**
   - Male
   - Female (default)

2. **Dialect/Region Selection**
   
   **Options:**
   - 🇸🇦 Saudi (ar-SA) - **Default**
   - 🇪🇬 Egyptian (ar-EG)
   - 🇦🇪 UAE (ar-AE)
   - 🇱🇧 Lebanese (ar-LB)
   - 🇯🇴 Jordanian (ar-JO)
   - 🇲🇦 Moroccan (ar-MA)

**API Mapping:** 
- Language codes map to Kie AI TTS API `language` parameter
- Example: Saudi Female → `language: "ar-SA", voice: "female"`

---

#### 2.3 Image Configuration (when Output Type = Image)

**Simplified settings for image generation using Nano Banana Pro**

##### 2.3.1 Style

**Options:**
- Realistic (default)
- Cartoon
- Artistic

##### 2.3.2 Size/Aspect Ratio

**Options:**
- Square (1024x1024) - default
- Landscape (1920x1080)
- Portrait (1080x1920)

**Note:** Maps to Nano Banana Pro size parameter

---

### Step 3: Review & Finalize

**Purpose:** Show all user selections before initiating generation

**Layout:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📝 Your Idea
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[User's prompt text preview - truncated if too long]
[Image thumbnail if uploaded]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ Settings Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Output Type: Video
Style: Cinematic
Duration: 15 seconds
Quality: Professional (Sora 2 Pro)
Aspect Ratio: 16:9 (Horizontal)
Language: Arabic
Voice: Female - Saudi dialect

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💰 Cost
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Price: 2.99 ر.س
[Free trial remaining badge if applicable]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Actions:**
- "Edit" buttons next to each section → Navigate back to respective step
- "Back" button → Return to Step 2
- "Generate" button (primary CTA) → Start generation process

**Validations:**
- All required fields must be set
- Display warning if using Professional quality about longer processing time

---

## Navigation & State Management

### Navigation Rules

| Current Step | Back Action | Next/Generate Action |
|--------------|-------------|---------------------|
| Step 1 (Idea) | Exit wizard | → Step 2 |
| Step 2 (Style) | ← Step 1 | → Step 3 |
| Step 3 (Review) | ← Step 2 | Start Generation |

### State Preservation

**Requirements:**
- All user selections must be preserved when navigating between steps
- If user goes back and changes settings, forward steps should retain other selections
- On wizard exit/cancellation, offer to save draft (future enhancement)

### Data Model

```dart
class CreationConfig {
  // Step 1
  String prompt;
  String? imagePath;
  
  // Step 2 - Common
  OutputType outputType; // video | image
  
  // Step 2 - Video specific
  VideoStyle? videoStyle; // cinematic, animation, etc.
  int? videoDuration; // 10, 15, 25
  VideoQualityModel? qualityModel; // sora2, sora2_pro
  AspectRatio? aspectRatio; // 16:9, 9:16
  String language; // "ar" (default)
  VoiceGender? voiceGender; // male, female
  String? voiceDialect; // ar-SA, ar-EG, etc.
  
  // Step 2 - Image specific
  ImageStyle? imageStyle; // realistic, cartoon, artistic
  String? imageSize; // 1024x1024, 1920x1080, etc.
}
```

---

## API Integration Specifications

### Video Generation Flow

#### Step-by-Step API Calls:

1. **Text Enhancement** (Optional)
   - Endpoint: `POST /api/v1/text/generate`
   - Enhance user prompt to marketing-quality text
   - Use language from settings (Arabic)

2. **Video Generation with Sora 2**
   - Endpoint: `POST https://api.kie.ai/api/v1/jobs/createTask`
   - Model: `sora-2-text-to-video`
   - Parameters:
     ```json
     {
       "model": "sora-2-text-to-video",
       "input": {
         "prompt": "[enhanced marketing text from user]",
         "aspect_ratio": "landscape" | "portrait",
         "n_frames": "10" | "15",
         "remove_watermark": true
       },
       "callBackUrl": "[optional: your callback endpoint]"
     }
     ```
   - Response: Returns `taskId` for status polling

3. **Poll for Video Completion**
   - Endpoint: `GET https://api.kie.ai/api/v1/jobs/recordInfo?taskId={taskId}`
   - Check every 5 seconds
   - Update magic loading screen with progress
   - States: `waiting` → `success` or `fail`
   - When `state: "success"`, extract video URL from `resultJson.resultUrls[0]`

4. **Text-to-Speech (Arabic Voice)**
   - Endpoint: `/api/v1/tts/generate`
   - Parameters:
     ```json
     {
       "text": "[enhanced marketing text]",
       "language": "[ar-SA|ar-EG|ar-AE|ar-LB|ar-JO|ar-MA]",
       "voice": "male" | "female",
       "speed": 1.0
     }
     ```

5. **Combine Audio & Video** (Post-Processing)
   - Download generated video from Sora 2
   - Download TTS audio file
   - Use FFmpeg or video processing library to merge
   - Upload final video to Firebase Storage
   - Return final URL to user

---

### Image Generation Flow

1. **Text Enhancement** (Optional)
   - Same as video flow

2. **Image Generation**
   - Endpoint: `/api/v1/nano-banana/generate`
   - Parameters:
     ```json
     {
       "prompt": "[enhanced text]",
       "style": "[realistic|cartoon|artistic]",
       "size": "[1024x1024|1920x1080|1080x1920]",
       "format": "jpg"
     }
     ```

---

## UI/UX Specifications

### Step Indicators

**Visual Design:**
- Horizontal progress bar at top
- 3 dots/circles representing steps
- Active step highlighted in purple
- Completed steps show checkmark
- Future steps greyed out

**Labels:**
```
● Idea  →  ○ Style  →  ○ Finalize
```

**Mobile Considerations:**
- Stack labels below circles on small screens
- Ensure touch targets are minimum 44x44pt

---

### Responsive Design

#### Mobile (Portrait)
- Single column layout
- Full-width cards for option selection
- Sticky "Next" button at bottom
- Collapsible sections for long option lists

#### Tablet/iPad
- Two-column layout where appropriate
- Side-by-side comparison for quality options

---

### Accessibility

- All interactive elements have minimum touch target size (44x44)
- Text contrast ratio meets WCAG AA standards
- Support for screen readers (Arabic)
- Keyboard navigation for web version

---

### Animations & Transitions

**Between Steps:**
- Slide transition (right to left for forward, left to right for back)
- Duration: 300ms
- Easing: ease-in-out

**Option Selection:**
- Subtle scale animation (1.0 → 1.02 → 1.0)
- Color transition for selected state
- Haptic feedback on iOS

---

## Technical Constraints & Considerations

### ✅ Sora 2 API Confirmed Capabilities

**Endpoint:** `POST https://api.kie.ai/api/v1/jobs/createTask`

**Supported Parameters:**
- ✅ Duration: `10s` or `15s` only
- ✅ Aspect Ratio: `landscape` (16:9) or `portrait` (9:16)
- ✅ Watermark Control: `remove_watermark` boolean
- ✅ Task polling via `GET /api/v1/jobs/recordInfo?taskId={taskId}`

**NOT Supported:**
- ❌ No 25s duration option
- ❌ No "Sora 2 Pro" variant (only one Sora 2 model)
- ❌ No style parameter (Cinematic, Animation, etc.)
- ❌ No quality tiers (all videos use same quality)
- ❌ No input image parameter (text-to-video only)

---

### 🚨 Requirements Adjustments Needed

Mohamed's initial requirements vs API reality:

| Feature | Requested | API Reality | Action Required |
|---------|-----------|-------------|-----------------|
| Duration options | 10s, 15s, 25s | 10s, 15s only | **Remove 25s option** ✅ Done |
| Quality tiers | Normal (Sora 2), Professional (Sora 2 Pro) | Single Sora 2 model only | **Remove quality selector** ✅ Done |
| Style selection | Cinematic, Animation, etc. | No style parameter | **Remove style selector** ✅ Done |
| Input image | Upload image for video | Not supported | **Clarify with Mohamed** |
| Price tiers | 2.99 SAR (Normal), TBD (Pro) | Single model only | All videos 2.99 SAR |

---

### Performance Expectations

| Operation | Expected Time | User Feedback |
|-----------|---------------|---------------|
| Step navigation | <100ms | Instant transition |
| Text enhancement | 2-5 seconds | Loading spinner |
| Image generation (Nano Banana) | 10-30 seconds | Progress indicator |
| Video generation (10s) | 30-60 seconds | Magic loading screen |
| Video generation (15s) | 60-120 seconds | Extended magic loading screen |
| TTS generation | 3-10 seconds | Loading spinner |
| Audio+Video merge | 10-20 seconds | Processing indicator |

---

### Error Handling

**Scenarios to Handle:**

1. **API Failures**
   - Retry logic (max 3 attempts)
   - Clear error messages in Arabic
   - Option to save draft and retry later

2. **Network Issues**
   - Detect offline state
   - Queue generation for when online
   - Show connectivity status

3. **Rate Limiting (429)**
   - Display friendly message
   - Show estimated wait time
   - Implement request throttling

4. **Content Moderation**
   - Filter inappropriate prompts before API call
   - Show clear rejection reason
   - Allow edit and resubmit

---

## Cost & Pricing Considerations

### Current Pricing Model

- Free trial: 1 generation
- Per generation: 2.99 SAR

### Future Tiered Pricing (Recommended)

| Tier | Price | Quality |
|------|-------|---------|
| Normal | 2.99 SAR | Sora 2 |
| Professional | 4.99 SAR | Sora 2 Pro |
| Express | 5.99 SAR | Faster processing |

**Note:** Confirm pricing strategy with product owner before implementing professional tier.

---

## Open Questions & Risks

### ❓ Critical Questions for Mohamed

1. **Image Upload Feature** ⚠️
   - Your brief mentions: "user can upload image and app converts image to marketing video"
   - **Problem:** Sora 2 API is text-to-video only (no image input parameter)
   - **Options:**
     - A) Remove image upload feature from video workflow
     - B) Use image as reference for prompt enhancement only
     - C) Use different model/API for image-to-video
   - **Decision needed:** What should happen when user uploads an image?

2. **Simplified UI** 📝
   - Since Sora 2 has no style/quality options, Step 2 is now very simple:
     - Duration (10s or 15s)
     - Aspect Ratio (16:9 or 9:16)
     - Watermark (on/off)
     - Voice settings
   - **Question:** Is this enough options, or should we add other creative controls?

3. **Text Enhancement** 🤖
   - Should we always auto-enhance user prompts via GPT/Kie text API?
   - Or give users option to use their original prompt as-is?

4. **Default Values** ✅
   - Duration: 10s (matches API default)
   - Aspect Ratio: landscape (16:9)
   - Watermark: Remove (true)
   - Voice: Female
   - Dialect: Saudi (ar-SA)
   - **Confirm:** Are these correct?

5. **Audio Merge Strategy** 🎵
   - Sora 2 doesn't merge audio automatically
   - We need to download video + audio and merge them
   - **Options:**
     - A) Client-side merge (FFmpeg WASM - complex)
     - B) Server-side merge (Firebase Functions + FFmpeg)
     - C) Skip TTS for MVP, add later
   - **Recommendation:** Option B (server-side)


### Technical Risks

| Risk | Impact | Mitigation |
|------|--------|-----------|
| API model mismatch (Sora vs Veo) | High | Clarify before development |
| Long generation times | Medium | Clear user expectations, progress updates |
| Complex state management | Medium | Use Riverpod with proper state model |
| Voice quality varies by dialect | Low | Test all dialects before launch |
| Cost overruns from API usage | High | Implement usage tracking and limits |

---

## Success Criteria

### User Experience
- ✅ Users can complete all 3 steps in under 60 seconds
- ✅ 95% of users understand what each option means
- ✅ Less than 5% abandon rate at Step 2
- ✅ Users can successfully navigate back to edit settings

### Technical
- ✅ All API integrations work reliably
- ✅ State is preserved correctly across navigation
- ✅ Error rates below 2%
- ✅ App doesn't crash during wizard flow

### Business
- ✅ Increased user satisfaction (measure via in-app rating)
- ✅ Higher perceived value (justify pricing)
- ✅ Reduced support tickets about "how to change settings"

---

## Next Steps

1. **Immediate:** Clarify Sora 2 vs Veo3.1 API question with Mohamed
2. **Planning:** Create implementation plan once requirements are approved
3. **Design:** Create high-fidelity mockups for each step
4. **Development:** Implement in phases (Step 1 → Step 2 → Step 3)
5. **Testing:** Test all combinations of options
6. **Beta:** Roll out to limited users for feedback

---

**Document Status:** Draft - Awaiting Review  
**Next Review:** After Mohamed confirms open questions

