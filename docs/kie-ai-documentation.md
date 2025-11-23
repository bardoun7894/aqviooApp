# Kie AI API Documentation

## Table of Contents
1. [Overview](#overview)
2. [Authentication](#authentication)
3. [Available APIs](#available-apis)
4. [Implementation Examples](#implementation-examples)
5. [Error Handling](#error-handling)
6. [Best Practices](#best-practices)

## Overview

Kie AI provides multiple AI services for content generation including text generation, image generation, video generation, and audio generation. This documentation covers how to integrate these services into your Flutter application.

### Base URL
```
https://api.kie.ai
```

### API Key
To use Kie AI APIs, you need to obtain an API key:
1. Visit [https://kie.ai/](https://kie.ai/)
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

### 1. Text Generation API

Generates marketing text based on a prompt.

**Endpoint:** `POST /api/v1/text/generate`

**Request Body:**
```json
{
  "prompt": "Your marketing idea here",
  "language": "ar", // or "en"
  "tone": "professional", // or "casual", "friendly"
  "length": "short" // or "medium", "long"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "text": "Generated marketing text here...",
    "usage": {
      "tokens": 45
    }
  }
}
```

### 2. Image Generation API (Nano Banana Pro)

Generates images based on text prompts.

**Endpoint:** `POST /api/v1/nano-banana/generate`

**Request Body:**
```json
{
  "prompt": "Description of the image to generate",
  "style": "realistic", // or "cartoon", "artistic"
  "size": "1024x1024", // or "512x512", "2048x2048"
  "format": "jpg" // or "png"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "imageUrl": "https://cdn.kie.ai/generated/images/xyz123.jpg",
    "taskId": "task_12345",
    "status": "completed"
  }
}
```

### 3. Video Generation API (Veo3.1)

Generates videos from text or images.

**Endpoint:** `POST /api/v1/veo3/generate`

**Request Body:**
```json
{
  "prompt": "Description of the video to generate",
  "inputImage": "https://example.com/input.jpg", // optional
  "duration": 15, // in seconds
  "aspectRatio": "16:9", // or "9:16", "1:1"
  "style": "cinematic", // or "animation", "minimal"
  "callBackUrl": "https://your-app.com/callback" // optional
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "taskId": "task_67890",
    "status": "processing", // "processing", "completed", "failed"
    "estimatedTime": "45 seconds"
  }
}
```

### 4. Text-to-Speech API

Generates audio from text.

**Endpoint:** `POST /api/v1/tts/generate`

**Request Body:**
```json
{
  "text": "Text to convert to speech",
  "language": "ar-SA", // Arabic (Saudi) or "en-US"
  "voice": "female", // or "male"
  "speed": 1.0 // 0.5 to 2.0
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "audioUrl": "https://cdn.kie.ai/generated/audio/abc123.mp3",
    "duration": 12.5,
    "size": "1.2MB"
  }
}
```

## Implementation Examples

### Flutter Service Implementation

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class KieAIService {
  static const String _baseUrl = 'https://api.kie.ai';
  final String _apiKey;
  
  KieAIService(this._apiKey);
  
  // Generate marketing text
  Future<String> generateMarketingText(String prompt, {String language = 'ar'}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/text/generate'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'prompt': prompt,
        'language': language,
        'tone': 'professional',
        'length': 'medium',
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return data['data']['text'];
      }
    }
    
    throw Exception('Failed to generate marketing text');
  }
  
  // Generate image using Nano Banana Pro
  Future<String> generateImage(String prompt, {String style = 'realistic'}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/nano-banana/generate'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'prompt': prompt,
        'style': style,
        'size': '1024x1024',
        'format': 'jpg',
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return data['data']['imageUrl'];
      }
    }
    
    throw Exception('Failed to generate image');
  }
  
  // Generate video using Veo3.1
  Future<String> generateVideo(String prompt, {String? inputImage}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/veo3/generate'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'prompt': prompt,
        if (inputImage != null) 'inputImage': inputImage,
        'duration': 15,
        'aspectRatio': '16:9',
        'style': 'cinematic',
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return data['data']['taskId'];
      }
    }
    
    throw Exception('Failed to generate video');
  }
  
  // Check video generation status
  Future<Map<String, dynamic>> checkVideoStatus(String taskId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/veo3/status/$taskId'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
      },
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    
    throw Exception('Failed to check video status');
  }
  
  // Generate speech from text
  Future<String> generateSpeech(String text, {String language = 'ar-SA'}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/tts/generate'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'text': text,
        'language': language,
        'voice': 'female',
        'speed': 1.0,
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
}
```

### Usage in Flutter App

```dart
class VideoCreationScreen extends StatefulWidget {
  @override
  _VideoCreationScreenState createState() => _VideoCreationScreenState();
}

class _VideoCreationScreenState extends State<VideoCreationScreen> {
  final KieAIService _kieService = KieAIService('YOUR_API_KEY');
  bool _isGenerating = false;
  
  Future<void> _generateVideo() async {
    setState(() => _isGenerating = true);
    
    try {
      // 1. Generate marketing text
      final marketingText = await _kieService.generateMarketingText(_ideaController.text);
      
      // 2. Generate image if needed
      final imageUrl = await _kieService.generateImage(marketingText);
      
      // 3. Generate video
      final taskId = await _kieService.generateVideo(
        marketingText,
        inputImage: imageUrl,
      );
      
      // 4. Poll for completion
      String? videoUrl;
      while (videoUrl == null) {
        await Future.delayed(Duration(seconds: 5));
        final status = await _kieService.checkVideoStatus(taskId);
        if (status['data']['status'] == 'completed') {
          videoUrl = status['data']['videoUrl'];
        } else if (status['data']['status'] == 'failed') {
          throw Exception('Video generation failed');
        }
      }
      
      // 5. Generate speech
      final audioUrl = await _kieService.generateSpeech(marketingText);
      
      // 6. Combine video and audio (might need additional processing)
      // ...
      
      setState(() => _isGenerating = false);
      // Navigate to preview screen with videoUrl
    } catch (e) {
      setState(() => _isGenerating = false);
      // Show error message
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            controller: _ideaController,
            decoration: InputDecoration(
              hintText: 'Enter your idea here...',
            ),
          ),
          SizedBox(height: 16),
          _isGenerating
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _generateVideo,
                child: Text('Generate Video'),
              ),
        ],
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
    "code": "INVALID_PROMPT",
    "message": "The prompt is too short or empty"
  }
}
```

## Best Practices

1. **Security**
   - Never expose your API key in client-side code
   - Use environment variables to store API keys
   - Implement proper error handling for API failures

2. **Performance**
   - Implement caching for generated content when appropriate
   - Use background processing for video generation
   - Show progress indicators during API calls

3. **User Experience**
   - Provide clear feedback during generation process
   - Allow users to retry failed generations
   - Save generation history to avoid regenerating the same content

4. **Cost Management**
   - Track API usage to control costs
   - Implement limits for free users
   - Monitor usage through your Kie AI dashboard

5. **Content Moderation**
   - Implement content filtering on user inputs
   - Review generated content before displaying to users
   - Follow Saudi content regulations

## Integration with Your App

### Environment Configuration

Add your Kie AI API key to your environment variables:

```bash
# For development
KIE_AI_API_KEY=your_api_key_here

# For production
# Use secure environment variable management
```

### Flutter Configuration

Update your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^0.13.5
  json_annotation: ^4.8.1
  # Add other dependencies as needed
```

### Testing

Create mock services for testing:

```dart
class MockKieAIService extends KieAIService {
  MockKieAIService() : super('test_key');
  
  @override
  Future<String> generateMarketingText(String prompt, {String language = 'ar'}) async {
    // Return mock response for testing
    return "Mock marketing text based on: $prompt";
  }
  
  // Override other methods as needed
}
```

---

For more detailed information, visit the official Kie AI documentation at [https://docs.kie.ai/](https://docs.kie.ai/)

