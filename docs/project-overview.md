# Project Overview

## Aqvioo Mobile App

**Aqvioo** is a Flutter-based mobile application that leverages Generative AI to create promotional videos and images from text prompts or uploaded images.

### Executive Summary
The app provides a streamlined "wizard" interface for users to generate content. It integrates with **Kie AI** (Sora 2 for video, Nano Banana Pro for images) to produce high-quality media. The app features a premium **Glassmorphic** UI design, robust authentication, and a credit-based payment system.

### Technology Stack

| Category | Technology | Description |
|----------|------------|-------------|
| **Framework** | Flutter | Cross-platform mobile development (iOS/Android) |
| **Language** | Dart | Primary programming language |
| **State Management** | Riverpod | Reactive state management and dependency injection |
| **Navigation** | GoRouter | Declarative routing |
| **Backend** | Firebase | Auth (Phone/OTP), Firestore (Data), Storage (Media) |
| **AI Services** | Kie AI | Sora 2 (Video), Nano Banana Pro (Image) |
| **Payments** | Tabby / In-App | Credit purchase system |
| **Localization** | flutter_localizations | English and Arabic support |

### Architecture
The project follows a **Feature-First / Clean Architecture** pattern:
- **Presentation Layer**: Widgets, Providers, States (in `lib/features/*/presentation`)
- **Domain Layer**: Models, Entities (in `lib/features/*/domain`)
- **Data Layer**: Repositories, Data Sources (in `lib/features/*/data`)
- **Core Layer**: Shared utilities and UI components (in `lib/core`)

### Key Features
1.  **Magic Creation Wizard**: Step-by-step flow to generate content.
2.  **AI Integration**: Seamless connection to Kie AI for media generation.
3.  **My Creations**: Gallery to view and manage generated history.
4.  **Credit System**: Monetization model based on generation credits.
5.  **Bilingual**: Full support for Arabic (RTL) and English (LTR).
