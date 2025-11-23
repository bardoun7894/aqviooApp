# Brainstorming Session Results

**Session Date:** 2025-11-22
**Facilitator:** Business Analyst Mary
**Participant:** mohamed

## Session Start

**Topic:** Aqvioo mobile - AI Video Generation App
**Goals:** Explore User Experience (seamless flow) and Differentiation (Purple/White identity, AI features).

## Executive Summary

**Topic:** Aqvioo mobile - AI Video Generation App

**Session Goals:** Explore User Experience (seamless flow) and Differentiation (Purple/White identity, AI features).

**Techniques Used:** SCAMPER Method, Analogical Thinking

**Total Ideas Generated:** 12+

### Key Themes Identified:

- **Empowerment:** Positioning Aqvioo as the "Canva for Video Marketing" implies a focus on making non-designers feel like pros.
- **Frictionless Creation:** Features like "Swipe for Styles" and "Auto-save" reduce the effort to get a good result.
- **Quality Control:** The "AI Refinement" step ensures the input is good before the cost of generation is incurred.

## Technique Sessions

### Technique: SCAMPER Method

**Focus:** Refining the "Create -> Preview" flow and Differentiation.

**C - Combine:**
- **Combine Preview & Edit:** Allow users to make quick edits (e.g., change music, regenerate voice) directly on the preview screen without going back.
- **Combine Social & Save:** Automatically save the video to the local gallery when the user shares it to a social platform.

**A - Adapt:**
- **Swipe for Styles/Music:** Adapt the "filter swipe" interaction from social apps to allow users to quickly cycle through different music tracks or visual styles on the preview screen without re-generating the entire video.

**M - Modify:**
- **Modify Aspect Ratio:** Allow users to toggle between 9:16 (TikTok), 1:1 (Instagram), and 16:9 (YouTube) post-generation to maximize utility across platforms.
- **Modify Duration:** Enable users to "extend" a video if the initial output is too short for their needs.

**P - Put to other uses:**
- **Different Modes:** Expand beyond marketing to include "Personal Greetings" (birthdays), "Educational Summaries" (text-to-video), and "Daily Motivation" as distinct creation modes. Ensure **YouTube (16:9)** is fully supported.

**E - Eliminate:**
- **Eliminate Advanced Editor:** Remove complex timeline editing; stick to simple "Regenerate" or "Swipe Style" to keep it easy.
- **Eliminate Guest Payment:** Require login before payment to ensure purchase security and data retention.
- **Keep TTS:** Ensure robust Text-to-Speech capabilities are central (do not eliminate).

**R - Rearrange/Reverse:**
- **Rearrange Flow:** Insert an "AI Refinement" step: User Input -> AI Suggests/Refines Script -> User Approves -> Generate Video. This ensures quality before generation.
- **Payment Model:** Confirmed "Pay to Create" model (Standard) rather than Pay to Download.

### Technique: Analogical Thinking

**Focus:** Differentiation and Brand Identity.

**Analogy:** "Aqvioo is the **Canva for Video Marketing**."
- **Core Value:** Ease of use, accessibility, and empowering non-designers to create professional results.
- **Feature Implication:** Implement a **"Brand Kit"** (upload logo, set colors once) so every generated video is automatically branded. This is a key differentiator for business users.

## Idea Categorization

### Immediate Opportunities

_Ideas ready to implement now_

- **AI Refinement Step:** Add the script refinement step before video generation.
- **Swipe for Styles:** Implement the swipe interaction for music/style changes in Preview.
- **Aspect Ratio Toggle:** Support 9:16, 1:1, and 16:9 outputs.

### Future Innovations

_Ideas requiring development/research_

- **Brand Kit:** Allow users to save logos and hex codes for auto-branding.
- **Personal/Edu Modes:** Specialized templates for non-marketing use cases.

### Moonshots

_Ambitious, transformative concepts_

- **Full Creative Suite:** A complete mobile video editor (like CapCut) integrated into the generation flow.

### Insights and Learnings

_Key realizations from the session_

- Users want to feel like they are "fixing" the video (changing the vibe) without doing the hard work of editing.
- The "Canva" analogy provides a clear roadmap for future features (templates, assets, ease of use).

## Action Planning

### Top 3 Priority Ideas

#### #1 Priority: AI Script Refinement

- Rationale: Ensures high quality input before incurring API costs for video generation.
- Next steps: Design the UI for the "Refinement" intermediate screen.
- Resources needed: OpenAI API (GPT-4o).
- Timeline: M0 (MVP)

#### #2 Priority: Swipe for Styles (Preview)

- Rationale: High impact on user satisfaction and conversion to paid.
- Next steps: Prototype the swipe interaction in Flutter.
- Resources needed: Multiple audio tracks/style presets.
- Timeline: M1

#### #3 Priority: Brand Kit

- Rationale: Major differentiator for the target audience (business owners).
- Next steps: Define the data model for storing user brand assets.
- Resources needed: Firebase Storage/Firestore.
- Timeline: M1/M2

## Reflection and Follow-up

### What Worked Well

- SCAMPER was excellent for refining the specific user flow steps.
- Analogical Thinking provided a strong strategic direction ("Canva").

### Areas for Further Exploration

- Technical feasibility of "post-generation" aspect ratio changes (might require re-rendering).

### Recommended Follow-up Techniques

- **Research:** Investigate API capabilities for aspect ratio resizing.

### Questions That Emerged

- Can we change the aspect ratio *after* generation without a full re-gen cost?

### Next Session Planning

- **Suggested topics:** API Feasibility for "Swipe" and "Resize".
- **Recommended timeframe:** Immediate (Research Phase).
- **Preparation needed:** API Keys and Documentation.

---

_Session facilitated using the BMAD CIS brainstorming framework_
