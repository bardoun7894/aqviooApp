# Data Models Documentation

## Overview
This document describes the core data models used in the Aqvioo application, specifically focusing on the content creation workflow.

## Domain Models

### CreationConfig
**File:** `lib/features/creation/domain/models/creation_config.dart`
**Purpose:** Configuration object for the multi-step creation wizard.

| Field | Type | Description |
|-------|------|-------------|
| `prompt` | `String` | User's text idea or description |
| `imagePath` | `String?` | Local path to input image (optional) |
| `outputType` | `OutputType` | `video` or `image` |
| `videoStyle` | `VideoStyle?` | Enum (Cinematic, Animation, Minimal, etc.) |
| `videoDurationSeconds` | `int?` | Duration in seconds (10 or 15) |
| `videoAspectRatio` | `String?` | "landscape" (16:9) or "portrait" (9:16) |
| `voiceGender` | `VoiceGender?` | `male` or `female` |
| `voiceDialect` | `String?` | Locale code (e.g., `ar-SA`) |
| `imageStyle` | `ImageStyle?` | `Realistic`, `Cartoon`, `Artistic` |
| `imageSize` | `String?` | Resolution string (e.g., "1024x1024") |

### CreationItem
**File:** `lib/features/creation/domain/models/creation_item.dart` (Inferred)
**Purpose:** Represents a generated media item in the user's history.

| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | Unique UUID |
| `taskId` | `String?` | Kie AI Task ID for polling |
| `status` | `CreationStatus` | `processing`, `success`, `failed` |
| `url` | `String?` | URL of the generated media |
| `type` | `CreationType` | `video` or `image` |
| `createdAt` | `DateTime` | Timestamp of creation |

## State Management

### CreationState
**File:** `lib/features/creation/presentation/providers/creation_provider.dart`
**Purpose:** Manages the state of the creation wizard and history.

| Field | Type | Description |
|-------|------|-------------|
| `status` | `CreationWizardStatus` | `idle`, `generatingScript`, `generatingVideo`, `success`, `error` |
| `wizardStep` | `int` | Current step index (0-2) |
| `config` | `CreationConfig` | Current configuration being built |
| `creations` | `List<CreationItem>` | History of generated items |
| `currentTaskId` | `String?` | ID of the task currently being watched |

## Enums

### VideoStyle
Defines visual styles for video generation:
- `cinematic`, `animation`, `minimal`, `modern`, `corporate`
- `socialMedia`, `vintage`, `fantasy`, `documentary`
- `horror`, `comedy`, `sciFi`, `noir`, `dreamlike`, `retro`

### OutputType
- `video`
- `image`
