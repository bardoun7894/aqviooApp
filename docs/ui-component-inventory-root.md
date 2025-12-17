# UI Component Inventory

## Overview
This document catalogs the reusable UI components and design system elements used in the Aqvioo application.

## Design System

### Glassmorphism
The application heavily relies on a glassmorphic design aesthetic, characterized by translucent backgrounds, blurs, and light borders.

**Core Widgets:** `lib/core/widgets/`

| Component | File | Description |
|-----------|------|-------------|
| `GlassContainer` | `glass_container.dart` | Base container with blur and translucency |
| `GlassCard` | `glass_card.dart` | Card variant of GlassContainer for content grouping |
| `GlassButton` | `glass_button.dart` | Interactive button with glass effect |
| `GlassTextField` | `glass_text_field.dart` | Input field with glass styling |
| `NeumorphicContainer` | `neumorphic_container.dart` | Container with soft depth/shadow effects |
| `GradientButton` | `gradient_button.dart` | Button with gradient background (primary action) |

### Responsive System
The application implements a custom responsive design system to handle various screen sizes.

**Widgets:**
- `ResponsiveScaffold`: Base scaffold that handles safe areas and layout constraints.
- `ResponsivePadding`: Widget that adjusts padding based on screen size.

**Extensions:**
- `ResponsiveExtensions`: (Likely in `lib/core/utils/`) Provides `.sp`, `.w`, `.h` extensions for responsive sizing.

## Feature Components

### Creation Wizard
- **Progress Indicators**: Custom animated loaders (pulsing circles/stars).
- **Style Selectors**: Grid/List views for selecting Video/Image styles.
- **Preview Player**: Video player wrapper with controls.

### Authentication
- **OTP Input**: Custom pin code input field.
- **Social Login Buttons**: Styled buttons for Apple/Google auth.
