# ElevenLabs API Documentation

## Table of Contents
1. [Overview](#overview)
2. [Authentication](#authentication)
3. [Available APIs](#available-apis)
4. [Implementation Examples](#implementation-examples)
5. [Error Handling](#error-handling)
6. [Best Practices](#best-practices)

## Overview

ElevenLabs provides advanced text-to-speech (TTS) capabilities with highly realistic AI voices. This documentation covers how to integrate ElevenLabs TTS into your Flutter application for generating voiceovers in multiple languages, including Arabic.

### Base URL
```
https://api.elevenlabs.io
```

### API Key
To use ElevenLabs APIs, you need to obtain an API key:
1. Visit [https://elevenlabs.io/](https://elevenlabs.io/)
2. Create an account or sign in
3. Navigate to API keys section
4. Generate a new API key
5. Store the API key securely in your app's environment variables

## Authentication

All API requests must include your API key in the `xi-api-key` header:

```dart
final headers = {
  'xi-api-key': 'YOUR_API_KEY',
  'Content-Type': 'application/json',
};
```

## Available APIs

### 1. Text-to-Speech API

Converts text to highly realistic speech.

**Endpoint:** `POST /v1/text-to-speech/{voice_id}`

**Request Body:**
```json
{
  "text": "Text to convert to speech",
  "model_id": "eleven_multilingual_v2", // or "eleven_turbo_v2"
  "voice_settings": {
    "stability": 0.75, // 0.0 to 1.0
    "similarity_boost": 0.75, // 0.0 to 1.0
    "style": "moderate", // or "soft", "energetic", etc.
    "use_speaker_boost": true
  }
}
```

**Response:**
```json
{
  "audio_base64": "UklGRiQAAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQAAAAA==...",
  "content_type": "audio/mpeg"
}
```

### 2. Get Voices API

Retrieves a list of available voices.

**Endpoint:** `GET /v1/voices`

**Response:**
```json
{
  "voices": [
    {
      "voice_id": "rachel",
      "name": "Rachel",
      "category": "female",
      "description": "Warm and engaging voice",
      "preview_url": "https://storage.googleapis.com/eleven-public-prod/previews/rachel.mp3"
    },
    {
      "voice_id": "adam",
      "name": "Adam",
      "category": "male",
      "description": "Deep and authoritative voice",
      "preview_url": "https://storage.googleapis.com/eleven-public-prod/previews/adam.mp3"
    },
    {
      "voice_id": "bella",
      "name": "Bella",
      "category": "female",
      "description": "Warm and gentle voice with Arabic accent",
      "preview_url": "https://storage.googleapis.com/eleven-public-prod/previews/bella.mp3"
    }
    // ... more voices
  ]
}
```

### 3. Get Voice Settings API

Retrieves default settings for a specific voice.

**Endpoint:** `GET /v1/voices/{voice_id}/settings`

**Response:**
```json
{
  "voice_id": "rachel",
  "name": "Rachel",
  "category": "female",
  "description": "Warm and engaging voice",
  "language": "english",
  "accent": "american",
  "age": "young",
  "gender": "female",
  "use_case": "general"
}
```

## Implementation Examples

### Flutter Service Implementation

```dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ElevenLabsService {
  static const String _baseUrl = 'https://api.elevenlabs.io';
  final String _apiKey;
  
  ElevenLabsService(this._apiKey);
  
  // Get available voices
  Future<List<Map<String, dynamic>>> getVoices() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/v1/voices'),
      headers: {
        'xi-api-key': _apiKey,
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['voices'] != null) {
        return List<Map<String, dynamic>>.from(data['voices']);
      }
    }
    
    throw Exception('Failed to get voices');
  }
  
  // Generate speech from text
  Future<String> generateSpeech(
    String text, 
    String voiceId, {
    String modelId = 'eleven_multilingual_v2',
    double stability = 0.75,
    double similarityBoost = 0.75,
    String style = 'moderate',
    bool useSpeakerBoost = true,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/v1/text-to-speech/$voiceId'),
      headers: {
        'xi-api-key': _apiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'text': text,
        'model_id': modelId,
        'voice_settings': {
          'stability': stability,
          'similarity_boost': similarityBoost,
          'style': style,
          'use_speaker_boost': useSpeakerBoost,
        },
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['audio_base64'] != null) {
        // Convert base64 to bytes and save to file or upload to storage
        final audioBytes = base64Decode(data['audio_base64']);
        
        // For now, return a placeholder URL
        // In a real implementation, you would upload to Firebase Storage
        // and return the download URL
        return 'https://firebase-storage-url/generated/audio.mp3';
      }
    }
    
    throw Exception('Failed to generate speech');
  }
  
  // Get Arabic voices specifically
  Future<List<Map<String, dynamic>>> getArabicVoices() async {
    final allVoices = await getVoices();
    
    // Filter for voices that support Arabic
    final arabicVoices = allVoices.where((voice) {
      final name = voice['name']?.toString().toLowerCase() ?? '';
      final description = voice['description']?.toString().toLowerCase() ?? '';
      
      return name.contains('arabic') || 
             name.contains('bella') || // Bella is known to support Arabic
             description.contains('arabic');
    }).toList();
    
    return arabicVoices;
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
  final ElevenLabsService _elevenLabsService = ElevenLabsService('YOUR_API_KEY');
  List<Map<String, dynamic>> _voices = [];
  List<Map<String, dynamic>> _arabicVoices = [];
  bool _isLoading = true;
  String? _selectedVoiceId;
  
  @override
  void initState() {
    super.initState();
    _loadVoices();
  }
  
  Future<void> _loadVoices() async {
    try {
      final voices = await _elevenLabsService.getVoices();
      final arabicVoices = await _elevenLabsService.getArabicVoices();
      
      setState(() {
        _voices = voices;
        _arabicVoices = arabicVoices;
        _isLoading = false;
        
        // Default to an Arabic voice if available
        if (_arabicVoices.isNotEmpty) {
          _selectedVoiceId = _arabicVoices.first['voice_id'];
        } else if (_voices.isNotEmpty) {
          _selectedVoiceId = _voices.first['voice_id'];
        }
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
        : DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  tabs: [
                    Tab(text: 'All Voices'),
                    Tab(text: 'Arabic Voices'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // All voices tab
                      ListView.builder(
                        itemCount: _voices.length,
                        itemBuilder: (context, index) {
                          final voice = _voices[index];
                          return VoiceTile(
                            voice: voice,
                            isSelected: _selectedVoiceId == voice['voice_id'],
                            onTap: () {
                              setState(() => _selectedVoiceId = voice['voice_id']);
                            },
                          );
                        },
                      ),
                      // Arabic voices tab
                      ListView.builder(
                        itemCount: _arabicVoices.length,
                        itemBuilder: (context, index) {
                          final voice = _arabicVoices[index];
                          return VoiceTile(
                            voice: voice,
                            isSelected: _selectedVoiceId == voice['voice_id'],
                            onTap: () {
                              setState(() => _selectedVoiceId = voice['voice_id']);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
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

class VoiceTile extends StatelessWidget {
  final Map<String, dynamic> voice;
  final bool isSelected;
  final VoidCallback onTap;
  
  const VoiceTile({
    Key? key,
    required this.voice,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(voice['name'] ?? 'Unknown'),
      subtitle: Text(voice['description'] ?? 'No description'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (voice['preview_url'] != null)
            IconButton(
              icon: Icon(Icons.play_arrow),
              onPressed: () {
                // Play preview audio
                _playPreview(voice['preview_url']);
              },
            ),
          Radio<String>(
            value: voice['voice_id'],
            groupValue: isSelected ? voice['voice_id'] : null,
            onChanged: (value) => onTap(),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
  
  void _playPreview(String? previewUrl) {
    if (previewUrl != null) {
      // Implement audio player to play preview
      // This could use the audioplayers package
    }
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
  "detail": {
    "status": "invalid_request_error",
    "message": "Invalid voice ID"
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
   - Use background processing for audio generation
   - Show progress indicators during API calls

3. **User Experience**
   - Provide voice previews to help users choose
   - Allow users to adjust voice settings (stability, similarity boost)
   - Save voice preferences for returning users

4. **Cost Management**
   - Track API usage to control costs
   - Implement limits for free users
   - Monitor usage through your ElevenLabs dashboard

5. **Arabic Support**
   - Use voices that support Arabic for better pronunciation
   - Test generated audio with Arabic text samples
   - Consider cultural preferences in voice selection

---

For more detailed information, visit the official ElevenLabs documentation at [https://elevenlabs.io/docs](https://elevenlabs.io/docs)

