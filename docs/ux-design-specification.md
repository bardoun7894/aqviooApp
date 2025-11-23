# Aqvioo mobile UX Design Specification

_Created on 2025-11-23 by mohamed_
_Generated using BMad Method - Create UX Design Workflow v1.0_

---

## Executive Summary

**Project Vision:**
Aqvioo is a hybrid mobile application (iOS & Android) that empowers users to create professional marketing videos from simple text ideas or images using AI. The goal is to make high-end video production accessible to non-designers through a "magic" interface.

**Target Users:**
Small business owners, marketers, and content creators who need high-quality video content but lack video editing skills or budget for professional agencies.

**Core Experience:**
Effortless Creation. The user inputs an idea, and the app handles the complexity of scriptwriting, visual selection, voiceover, and editing, delivering a polished result in seconds.

---

## 1. Design System Foundation

### 1.1 Design System Choice

**System:** Custom Flutter Design System
**Rationale:** To achieve the specific "Glassmorphism" aesthetic and "No Black" rule, a custom system is required. Standard libraries (Material/Cupertino) are too rigid for the desired translucency and blur effects.
**Key Characteristics:**
- **Glassmorphism:** Heavy use of `BackdropFilter`, translucent whites, and light borders.
- **RTL First:** Built from the ground up to support Arabic right-to-left layouts naturally.
- **Motion-Centric:** Deep integration with Rive for interactive states.

---

## 2. Core User Experience

### 2.1 Defining Experience

**"The Magic Button"**
The core interaction is the transformation moment. The user presses "Generate," and instead of a boring spinner, they see a "Magic" animation (Rive) that visually represents the AI "thinking" and "building" their video. This turns the waiting time into a delightful part of the experience.

### 2.2 Novel UX Patterns

**Swipe for Style (Preview Screen)**
Instead of complex settings menus, users can "Swipe" on the preview screen (like Instagram filters) to instantly change the "Vibe" of the video (Music + Fonts + Color Grade) without re-generating the core content. This empowers users to "fix" the mood instantly.

---

## 3. Visual Foundation

### 3.1 Color System

**Strategy:** "Crystal Motion" - A dual-theme approach focusing on light and depth.

**Primary Palette:**
- **Purple (Brand):** `#7C3AED` (Primary Action, Brand Identity)
- **White (Surface):** `#FFFFFF` (Backgrounds, Cards in Light Mode)
- **Glass (Overlay):** `rgba(255, 255, 255, 0.1)` to `rgba(255, 255, 255, 0.7)`

**Theme Strategy:**
- **Light Theme:** "Subtle Glass" - Clean, airy, white backgrounds with very subtle frosted glass cards.
- **Dark Theme:** "Vibrant Glass" - Deep purple/neon backgrounds with strong, vibrant glass cards that glow.

**Semantic Colors:**
- **Success:** Soft Green (e.g., `#10B981`)
- **Error:** Soft Red (e.g., `#EF4444`)
- **Warning:** Warm Amber (e.g., `#F59E0B`)
- **Neutral:** Cool Grays (e.g., `#F3F4F6` - `#9CA3AF`) - **NO PURE BLACK**.

**Interactive Visualizations:**
- Color Theme Explorer: [ux-color-themes.html](./ux-color-themes.html)

---

## 4. Design Direction

### 4.1 Chosen Design Approach

**Direction:** "Modern Glass"
**Philosophy:** The interface should feel like a premium tool. It uses depth (blur/shadows) rather than lines to separate content.

**Key Decisions:**
- **Layout:** Bottom Navigation Bar for main sections (Home, Create, History, Profile).
- **Hierarchy:** Spacious. Large inputs, clear typography.
- **Assets:** **Nano Banana Pro** used for Splash Screen and empty state illustrations.
- **Motion:** **Rive** animations for:
    - Splash Screen (Logo Pulse)
    - Loading/Generating State (AI Brain/Magic)
    - Success State (Confetti/Checkmark)
    - Button Interactions (Press states)

**Interactive Mockups:**
- Design Direction Showcase: [ux-design-directions.html](./ux-design-directions.html)

---

## 5. User Journey Flows

### 5.1 Critical User Paths

**Journey 1: The First Creation (Onboarding)**
1.  **Splash:** Animated Logo (Rive) -> Welcome.
2.  **Auth:** "Continue with Phone" or "Guest".
3.  **Home:** Immediate focus on the "Input Field".
4.  **Action:** User types idea -> Taps "Generate".
5.  **Wait:** "Magic" Animation (Rive).
6.  **Result:** Video Auto-plays.
7.  **Conversion:** User taps "Save" -> Prompt to Pay/Sign up (if guest).

**Journey 2: The "Vibe Check" (Refinement)**
1.  **Preview:** User watches generated video.
2.  **Action:** User swipes Left/Right.
3.  **Feedback:** Music and Fonts change instantly.
4.  **Success:** User finds the right vibe -> Taps "Save".

---

## 6. Component Library

### 6.1 Component Strategy

**GlassCard:**
A reusable container with `BackdropFilter`, white opacity, and a subtle white border. Used for everything from inputs to video containers.

**GradientButton:**
Primary action button with a Purple gradient background and shadow.

**MotionIcon:**
Rive-powered icons for the bottom navigation bar that animate on selection.

---

## 7. UX Pattern Decisions

### 7.1 Consistency Rules

- **No Black:** All text is Dark Gray (`#1F2937`) or Purple (`#4C1D95`), never `#000000`.
- **Rounded Corners:** Consistent `24px` radius for cards, `12px` for inner elements.
- **Haptic Feedback:** Subtle vibration on "Success" and "Swipe" actions.

---

## 8. Responsive Design & Accessibility

### 8.1 Responsive Strategy

- **Mobile First:** Optimized for portrait touch interaction.
- **RTL Support:** Critical. All layouts must mirror correctly for Arabic.
- **Text Scaling:** UI must support dynamic type sizes without breaking the glass layout.

---

## 9. Implementation Guidance

### 9.1 Completion Summary

The design specification is locked. The "Glassmorphism" direction with Rive motion provides a unique, premium feel that differentiates Aqvioo from generic utility apps. The dual-theme strategy (Subtle Light / Vibrant Dark) caters to user preferences while maintaining brand identity.

---

## Appendix

### Related Documents

- Product Requirements: `docs/brief.md`
- Brainstorming: `docs/brainstorming-session-results-2025-11-22.md`

### Core Interactive Deliverables

This UX Design Specification was created through visual collaboration:

- **Color Theme Visualizer**: [ux-color-themes.html](./ux-color-themes.html)
  - Interactive HTML showing Light (Subtle) vs Dark (Vibrant) themes.

### Version History

| Date | Version | Changes | Author |
| :--- | :--- | :--- | :--- |
| 2025-11-23 | 1.0 | Initial UX Design Specification | mohamed |

---

_This UX Design Specification was created through collaborative design facilitation, not template generation. All decisions were made with user input and are documented with rationale._
