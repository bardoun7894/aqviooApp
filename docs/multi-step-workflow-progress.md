# Multi-Step Workflow - Implementation Progress

**Date:** 2025-11-25  
**Status:** ⚙️ In Progress - Core Components Complete

---

## ✅ Completed Components

### 1. Data Model ✓
**File:** [`creation_config.dart`](file:///Users/mac/aqvioo/lib/features/creation/domain/models/creation_config.dart)

Created comprehensive configuration model with:
- ✅ Video settings (style, duration, aspect ratio, voice)
- ✅ Image settings (style, size)
- ✅ Validation logic
- ✅ Enum types (`OutputType`, `VideoStyle`, `VoiceGender`, `ImageStyle`)
- ✅ Helper extensions for display names and prompt modifiers

---

### 2. State Management ✓
**File:** [`creation_provider.dart`](file:///Users/mac/aqvioo/lib/features/creation/presentation/providers/creation_provider.dart)

Enhanced provider with:
- ✅ Wizard step tracking (`wizardStep`: 0-2)
- ✅ Configuration storage (`CreationConfig`)
- ✅ Navigation methods (`goToNextStep`, `goToPreviousStep`, `goToStep`)
- ✅ Individual update methods for each setting
- ✅ Backward compatible with existing `generateVideo` method

---

### 3. Step 2 Widget ✓
**File:** [`style_configuration_step.dart`](file:///Users/mac/aqvioo/lib/features/home/presentation/widgets/style_configuration_step.dart)

Fully functional configuration screen with:
- ✅ Output type selector (Video/Image toggle)
- ✅ **Video Settings:**
  - Style chips (Cinematic, Animation, Minimal, Modern, Corporate, Social Media)
  - Duration cards (10s, 15s)
  - Aspect ratio selector (16:9 landscape, 9:16 portrait)
  - Voice settings (Male/Female + Dialect dropdown)
- ✅ **Image Settings:**
  - Style selector(Realistic, Cartoon, Artistic)
  - Size selector (Square, Landscape, Portrait)
- ✅ Real-time state updates via Riverpod
- ✅ Glassmorphic design matching app theme

---

### 4. Step 3 Widget ✓
**File:** [`review_finalize_step.dart`](file:///Users/mac/aqvioo/lib/features/home/presentation/widgets/review_finalize_step.dart)

Review screen showing:
- ✅ Prompt preview with character truncation
- ✅ Image thumbnail if uploaded
- ✅ Complete settings summary
- ✅ "Edit" buttons for each section (navigate back to respective step)
- ✅ Cost display (2.99 SAR with new Riyal symbol)
- ✅ Generate button with icon
- ✅ Conditional rendering based on output type

---

## 🚧 Next Steps Required

### 5. Home Screen Integration (Critical)
**File:** [`home_screen.dart`](file:///Users/mac/aqvioo/lib/features/home/presentation/screens/home_screen.dart)

**What needs to be done:**

1. **Import new widgets:**
   ```dart
   import 'widgets/style_configuration_step.dart';
   import 'widgets/review_finalize_step.dart';
   import '../../creation/domain/models/creation_config.dart';
   ```

2. **Replace main content area with PageView:**
   ```dart
   Expanded(
     child: PageView(
       controller: _pageController,
       physics: const NeverScrollableScrollPhysics(), // Prevent swipe, use buttons only
       onPageChanged: (index) {
         ref.read(creationControllerProvider.notifier).goToStep(index);
       },
       children: const [
         _IdeaInputStep(), // Step 1 (existing prompt input - keep as is)
         StyleConfigurationStep(), // Step 2 (new widget)
         ReviewFinalizeStep(), // Step 3 (new widget)
       ],
     ),
   )
   ```

3. **Add PageController:**
   ```dart
   class _HomeScreenState extends ConsumerState<HomeScreen> {
     final _pageController = PageController();
     // ... existing code
     
     @override
     void dispose() {
       _pageController.dispose();
       super.dispose();
     }
   }
   ```

4. **Update step indicators to be interactive:**
   - Make them clickable to navigate between steps
   - Update active state based on `ref.watch(creationControllerProvider).wizardStep`

5. **Add navigation buttons:**
   - **Back button** (Steps 1-2): Navigate to previous step
   - **Next button** (Steps 0-1): Navigate to next step (validate before proceeding)
   - **Generate button** (Step 2): Already in `ReviewFinalizeStep` widget

6. **Update Step 1 (Idea Input):**
   - Keep existing prompt TextField and image picker
   - Replace "Generate" button with "Next" button
   - Add validation: prompt must not be empty

---

## 📝 Detailed Integration Code

I'll create a complete refactored `home_screen.dart` in the next step.  
For now, here's the high-level structure:

```dart
// home_screen.dart structure

class HomeScreen extends ConsumerStatefulWidget { }

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _promptController = TextEditingController();
  final _pageController = PageController();
  File? _selectedImage;
  
  @override
  Widget build(BuildContext context) {
    final wizardStep = ref.watch(creationControllerProvider).wizardStep;
    final config = ref.watch(creationControllerProvider).config;
    
    // Listen to wizardStep changes and update PageController
    ref.listen(creationControllerProvider, (previous, next) {
      if (previous?.wizardStep != next.wizardStep) {
        _pageController.animateToPage(
          next.wizardStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
      
      // Existing navigation logic for magic loading/preview
      if (next.status == CreationStatus.generatingScript) {
        context.push('/magic-loading');
      } else if (next.status == CreationStatus.success) {
        context.push('/preview', extra: next.videoUrl);
      }
    });
    
    return Scaffold(
      body: Stack(
        children: [
          // Existing gradient blobs
          
          SafeArea(
            child: Column(
              children: [
                // Top app bar (unchanged)
                
                // Step indicators (make interactive)
                _buildStepIndicators(wizardStep),
                
                // PageView with 3 steps
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildIdeaStep(), // Step 0
                      const StyleConfigurationStep(), // Step 1
                      const ReviewFinalizeStep(), // Step 2
                    ],
                  ),
                ),
                
                // Bottom navigation buttons
                _buildBottomButtons(wizardStep),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildIdeaStep() {
    // Keep existing glassmorphic card with TextField and image picker
    // Replace generate button with Next button
  }
  
  Widget _buildStepIndicators(int currentStep) {
    // Make clickable to jump to any completed step
  }
  
  Widget _buildBottomButtons(int currentStep) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ref.read(creationControllerProvider.notifier).goToPreviousStep();
                },
                child: const Text('Back'),
              ),
            ),
          if (currentStep > 0) const SizedBox(width: 12),
          if (currentStep < 2)
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _canProceedToNextStep()
                    ? () {
                        ref.read(creationControllerProvider.notifier).goToNextStep();
                      }
                    : null,
                child: const Text('Next'),
              ),
            ),
        ],
      ),
    );
  }
  
  bool _canProceedToNextStep() {
    final config = ref.read(creationControllerProvider).config;
    final currentStep = ref.read(creationControllerProvider).wizardStep;
    
    switch (currentStep) {
      case 0: // Idea step
        return config.prompt.isNotEmpty;
      case 1: // Style step
        return config.isValid;
      default:
        return false;
    }
  }
}
```

---

## 🔧 API Integration (Next phase)

After home screen integration is complete, we need to:

1. **Create Kie AI service methods:**
   - `generateVideoWithSora2()` - Text-to-video using Sora 2
   - `generateVideoWithVeo3()` - Image-to-video using Veo3
   - `enhancePromptWithGPT()` - Prompt enhancement based on style

2. **Update `generateVideo()` in creation_provider:**
   - Check if `imagePath` exists
   - If yes → use Veo3 API
   - If no → use Sora 2 API
   - Auto-enhance prompt with GPT + style modifier

---

## 📊 Progress Summary

| Component | Status | File |
|-----------|--------|------|
| Data Model | ✅ Complete | `creation_config.dart` |
| State Management | ✅ Complete | `creation_provider.dart` |
| Step 2 Widget | ✅ Complete | `style_configuration_step.dart` |
| Step 3 Widget | ✅ Complete | `review_finalize_step.dart` |
| Home Screen Update | 🚧 In Progress | `home_screen.dart` |
| API Integration | ⏳ Pending | `kie_ai_service.dart` |
| Testing | ⏳ Pending | - |

**Completion:** ~60% (4/7 major components done)

---

## 🎯 Immediate Next Action

**Would you like me to:**

**Option A:** Complete the `home_screen.dart` refactoring (will be a large file rewrite)  
**Option B:** Show you the key code sections to integrate manually  
**Option C:** Continue with API integration first

**Recommendation:** Option A - Complete home screen refactoring so you can test the full wizard flow

---

**Ready to proceed when you are!** 🚀
