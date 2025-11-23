# Fliki API Documentation

## Table of Contents
1. [Overview](#overview)
2. [Authentication](#authentication)
3. [Available APIs](#available-apis)
4. [Implementation Examples](#implementation-examples)
5. [Error Handling](#error-handling)
6. [Best Practices](#best-practices)

## Overview

Fliki provides AI-powered video generation and text-to-speech services that can transform text into engaging videos with realistic voiceovers. This documentation covers how to integrate Fliki services into your Flutter application.

### Base URL
```
https://api.fliki.ai
```

### API Key
To use Fliki APIs, you need to obtain an API key:
1. Visit [https://developer.fliki.ai/](https://developer.fliki.ai/)
2. Create an account or sign in
3. Navigate to API keys section
4. Generate a new API key
5. Store the API key securely in your app's environment variables

## Authentication

All API requests must include your API key in the Authorization header:

```dart
final headers = {
  'Authorization': 'Bearer YOUR_API_KEY',
  'Content-Type': 'application/json',
};
```

## Available APIs

### 1. Text-to-Speech API

Converts text to natural-sounding speech.

**Endpoint:** `POST /v1/generate/text-to-speech`

**Request Body:**
```json
{
  "content": "Text to convert to speech",
  "voiceId": "en-US-JennyNeural", // Voice ID
  "voiceStyleId": "cheerful", // Voice style
  "sampleRate": 24000, // Audio quality
  "outputFormat": "mp3" // or "wav"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "audioUrl": "https://cdn.fliki.ai/generated/audio/xyz123.mp3",
    "duration": 12.5,
    "size": "1.2MB"
  }
}
```

### 2. Video Generation API

Creates videos from text with optional background music and voiceovers.

**Endpoint:** `POST /v1/generate/video`

**Request Body:**
```json
{
  "content": "Text for video generation",
  "voiceId": "en-US-JennyNeural",
  "voiceStyleId": "cheerful",
  "backgroundMusicId": "corporate", // Optional
  "aspectRatio": "16:9", // or "9:16", "1:1"
  "duration": 30, // in seconds
  "quality": "high" // or "medium", "low"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "videoId": "video_67890",
    "status": "processing", // "processing", "completed", "failed"
    "estimatedTime": "45 seconds"
  }
}
```

### 3. Check Video Status

Checks the status of a video generation request.

**Endpoint:** `GET /v1/video/status/{videoId}`

**Response:**
```json
{
  "success": true,
  "data": {
    "videoId": "video_67890",
    "status": "completed", // "processing", "completed", "failed"
    "videoUrl": "https://cdn.fliki.ai/generated/video/abc123.mp4",
    "thumbnailUrl": "https://cdn.fliki.ai/generated/thumbnails/abc123.jpg"
  }
}
```

### 4. Available Voices

Retrieves a list of available voices for text-to-speech.

**Endpoint:** `GET /v1/voices`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "en-US-JennyNeural",
      "name": "Jenny",
      "language": "English (US)",
      "gender": "Female",
      "previewUrl": "https://cdn.fliki.ai/previews/jenny.mp3"
    },
    {
      "id": "ar-SA-ZaydNeural",
      "name": "Zayd",
      "language": "Arabic (Saudi)",
      "gender": "Male",
      "previewUrl": "https://cdn.fliki.ai/previews/zayd.mp3"
    }
    // ... more voices
  ]
}
```

## Implementation Examples

### Flutter Service Implementation

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class FlikiService {
  static const String _baseUrl = 'https://api.fliki.ai';
  final String _apiKey;
  
  FlikiService(this._apiKey);
  
  // Generate speech from text
  Future<String> generateSpeech(String text, {String voiceId = 'ar-SA-ZaydNeural'}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/v1/generate/text-to-speech'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'content': text,
        'voiceId': voiceId,
        'voiceStyleId': 'cheerful',
        'sampleRate': 24000,
        'outputFormat': 'mp3',
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return data['data']['audioUrl'];
      }
    }
    
    throw Exception('Failed to generate speech');
  }
  
  // Generate video from text
  Future<String> generateVideo(String text, {String voiceId = 'ar-SA-ZaydNeural'}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/v1/generate/video'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'content': text,
        'voiceId': voiceId,
        'voiceStyleId': 'cheerful',
        'backgroundMusicId': 'corporate',
        'aspectRatio': '16:9',
        'duration': 30,
        'quality': 'high',
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return data['data']['videoId'];
      }
    }
    
    throw Exception('Failed to generate video');
  }
  
  // Check video generation status
  Future<Map<String, dynamic>> checkVideoStatus(String videoId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/v1/video/status/$videoId'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
      },
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    
    throw Exception('Failed to check video status');
  }
  
  // Get available voices
  Future<List<Map<String, dynamic>>> getVoices() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/v1/voices'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
      },
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
    }
    
    throw Exception('Failed to get voices');
  }
}
```

### Usage in Flutter App

```dart
class VoiceSelectionScreen extends StatefulWidget {
  @override
  _VoiceSelectionScreenState createState() => _VoiceSelectionScreenState();
}

class _VoiceSelectionScreenState extends State<VoiceSelectionScreen> {
  final FlikiService _flikiService = FlikiService('YOUR_API_KEY');
  List<Map<String, dynamic>> _voices = [];
  bool _isLoading = true;
  String? _selectedVoiceId;
  
  @override
  void initState() {
    super.initState();
    _loadVoices();
  }
  
  Future<void> _loadVoices() async {
    try {
      final voices = await _flikiService.getVoices();
      setState(() {
        _voices = voices;
        _isLoading = false;
        // Default to Arabic voice if available
        _selectedVoiceId = voices.firstWhere(
          (voice) => voice['language'].toString().contains('Arabic'),
          orElse: () => voices.first,
        )['id'];
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Show error message
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Voice')),
      body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _voices.length,
            itemBuilder: (context, index) {
              final voice = _voices[index];
              return ListTile(
                title: Text(voice['name']),
                subtitle: Text(voice['language']),
                trailing: Radio<String>(
                  value: voice['id'],
                  groupValue: _selectedVoiceId,
                  onChanged: (value) {
                    setState(() => _selectedVoiceId = value);
                  },
                ),
                onTap: () {
                  // Play preview if available
                  if (voice['previewUrl'] != null) {
                    // Play preview audio
                  }
                },
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _selectedVoiceId != null
            ? () => Navigator.pop(context, _selectedVoiceId)
            : null,
        child: Icon(Icons.check),
      ),
    );
  }
}
```

## Error Handling

### Common Error Codes

| Code | Description | Solution |
|------|-------------|----------|
| 400 | Bad Request | Check request parameters and format |
| 401 | Unauthorized | Verify API key is correct and included in headers |
| 429 | Too Many Requests | Implement rate limiting in your app |
| 500 | Server Error | Try again later or contact support |

### Error Response Format

```json
{
  "success": false,
  "error": {
    "code": "INVALID_VOICE_ID",
    "message": "The specified voice ID is not valid"
  }
}
```

## Best Practices

1. **Security**
   - Never expose your API key in client-side code
   - Use environment variables to store API keys
   - Implement proper error handling for API failures

2. **Performance**
   - Implement caching for voice data
   - Use background processing for video generation
   - Show progress indicators during API calls

3. **User Experience**
   - Provide voice previews to help users choose
   - Allow users to select preferred voice quality
   - Save voice preferences for returning users

4. **Cost Management**
   - Track API usage to control costs
   - Implement limits for free users
   - Monitor usage through your Fliki dashboard

5. **Arabic Support**
   - Use Arabic-specific voice IDs for better pronunciation
   - Test generated audio with Arabic text samples
   - Consider cultural preferences in voice selection

---

For more detailed information, visit the official Fliki documentation at [https://developer.fliki.ai/docs](https://developer.fliki.ai/docs)

