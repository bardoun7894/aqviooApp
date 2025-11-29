# API Contracts Documentation

## Overview
This document outlines the API contracts and service integrations for the Aqvioo mobile application. The primary integration is with **Kie AI** for generative media capabilities.

## AI Services

### Kie AI Service
**File:** `lib/services/ai/kie_ai_service.dart`
**Base URL:** `https://api.kie.ai`

#### Authentication
- **Method:** Bearer Token
- **Header:** `Authorization: Bearer <KIE_API_KEY>`

#### Endpoints

| Method | Endpoint | Description | Input | Output |
|--------|----------|-------------|-------|--------|
| `POST` | `/api/v1/jobs/createTask` | Create Video (Sora 2) | `model: sora-2-text-to-video`, `prompt`, `aspect_ratio`, `n_frames` | `taskId` |
| `POST` | `/api/v1/jobs/createTask` | Create Image (Nano Banana) | `model: nano-banana-pro`, `prompt`, `aspect_ratio`, `resolution` | `taskId` |
| `POST` | `/api/v1/veo/generate` | Create Video (Veo3) | `prompt`, `model`, `aspectRatio`, `imageUrls` (optional) | `taskId` |
| `GET` | `/api/v1/jobs/recordInfo` | Check Task Status | `taskId` | `state`, `resultJson` (urls), `failMsg` |

#### Error Handling
The service maps HTTP status codes and API error messages to user-friendly strings:
- **401**: Invalid API key
- **402**: Insufficient credits
- **429**: Rate limit exceeded
- **Timeout**: Request timed out
- **Content Flag**: Inappropriate content detected

### Composite AI Service
**File:** `lib/services/ai/composite_ai_service.dart`
- Acts as a unified facade for multiple AI providers (Kie AI, OpenAI, ElevenLabs).
- Currently delegates video/image generation to `KieAIService`.

## Future Integrations
- **Fliki API**: Planned for advanced video generation.
- **ElevenLabs**: Planned for high-quality voice synthesis (currently using Kie AI or placeholders).
