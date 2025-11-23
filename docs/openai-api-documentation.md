# OpenAI API Documentation

## Table of Contents
1. [Overview](#overview)
2. [Authentication](#authentication)
3. [Available APIs](#available-apis)
4. [Implementation Examples](#implementation-examples)
5. [Error Handling](#error-handling)
6. [Best Practices](#best-practices)

## Overview

OpenAI provides powerful language models that can generate human-like text based on prompts. This documentation covers how to integrate OpenAI's GPT models into your Flutter application for marketing text generation.

### Base URL
```
https://api.openai.com
```

### API Key
To use OpenAI APIs, you need to obtain an API key:
1. Visit [https://platform.openai.com/](https://platform.openai.com/)
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

### 1. Completions API

Generates text based on a prompt using GPT models.

**Endpoint:** `POST /v1/completions`

**Request Body:**
```json
{
  "model": "gpt-4o", // or "gpt-3.5-turbo"
  "prompt": "Generate a marketing text for a new coffee shop",
  "max_tokens": 150,
  "temperature": 0.7, // 0.0 to 2.0
  "top_p": 1.0,
  "frequency_penalty": 0.0,
  "presence_penalty": 0.0
}
```

**Response:**
```json
{
  "id": "chatcmpl-abc123",
  "object": "text.completion",
  "created": 1677652288,
  "model": "gpt-4o",
  "choices": [
    {
      "text": "Welcome to Coffee Haven, where every cup tells a story...",
      "index": 0,
      "logprobs": null,
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 12,
    "completion_tokens": 25,
    "total_tokens": 37
  }
}
```

### 2. Chat Completions API

Generates text using conversational format with GPT models.

**Endpoint:** `POST /v1/chat/completions`

**Request Body:**
```json
{
  "model": "gpt-4o",
  "messages": [
    {
      "role": "system",
      "content": "You are a marketing copywriter that creates compelling promotional text."
    },
    {
      "role": "user",
      "content": "Generate a marketing text for a new coffee shop"
    }
  ],
  "max_tokens": 150,
  "temperature": 0.7
}
```

**Response:**
```json
{
  "id": "chatcmpl-abc123",
  "object": "chat.completion",
  "created": 1677652288,
  "model": "gpt-4o",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "Welcome to Coffee Haven, where every cup tells a story..."
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 25,
    "completion_tokens": 30,
    "total_tokens": 55
  }
}
```

## Implementation Examples

### Flutter Service Implementation

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com';
  final String _apiKey;
  
  OpenAIService(this._apiKey);
  
  // Generate marketing text using Chat Completions
  Future<String> generateMarketingText(String prompt, {String language = 'en'}) async {
    final systemPrompt = language == 'ar' 
        ? 'أنت كاتب تسويقي محترف ينشئ نصوص تسويقية مقنعة.'
        : 'You are a professional marketing copywriter that creates compelling promotional text.';
    
    final response = await http.post(
      Uri.parse('$_baseUrl/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o',
        'messages': [
          {
            'role': 'system',
            'content': systemPrompt,
          },
          {
            'role': 'user',
            'content': prompt,
          }
        ],
        'max_tokens': 150,
        'temperature': 0.7,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['choices'] != null && data['choices'].isNotEmpty) {
        return data['choices'][0]['message']['content'];
      }
    }
    
    throw Exception('Failed to generate marketing text');
  }
  
  // Generate marketing text with specific tone
  Future<String> generateMarketingTextWithTone(
    String prompt, 
    String tone, // 'professional', 'casual', 'friendly'
    {String language = 'en'}
  ) async {
    final toneInstructions = {
      'professional': 'Write in a professional, formal tone suitable for business contexts.',
      'casual': 'Write in a relaxed, informal tone suitable for social media.',
      'friendly': 'Write in a warm, approachable tone that builds trust.',
    };
    
    final systemPrompt = language == 'ar'
        ? 'أنت كاتب تسويقي محترف. ${toneInstructions[tone] ?? ''}'
        : 'You are a professional marketing copywriter. ${toneInstructions[tone] ?? ''}';
    
    final response = await http.post(
      Uri.parse('$_baseUrl/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o',
        'messages': [
          {
            'role': 'system',
            'content': systemPrompt,
          },
          {
            'role': 'user',
            'content': prompt,
          }
        ],
        'max_tokens': 150,
        'temperature': 0.7,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['choices'] != null && data['choices'].isNotEmpty) {
        return data['choices'][0]['message']['content'];
      }
    }
    
    throw Exception('Failed to generate marketing text');
  }
  
  // Generate multiple options for user to choose from
  Future<List<String>> generateMarketingTextOptions(
    String prompt, 
    int count, // Number of options to generate
    {String language = 'en'}
  ) async {
    final systemPrompt = language == 'ar'
        ? 'أنت كاتب تسويقي محترف. قم بإنشاء $count خيارات مختلفة لنص تسويقي بناءً على الفكرة المقدمة.'
        : 'You are a professional marketing copywriter. Generate $count different options for marketing text based on the provided idea.';
    
    final response = await http.post(
      Uri.parse('$_baseUrl/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o',
        'messages': [
          {
            'role': 'system',
            'content': systemPrompt,
          },
          {
            'role': 'user',
            'content': prompt,
          }
        ],
        'max_tokens': 150,
        'temperature': 0.8, // Higher temperature for more variety
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['choices'] != null && data['choices'].isNotEmpty) {
        final content = data['choices'][0]['message']['content'];
        
        // Try to split into numbered options
        final options = content.split(RegExp(r'\n\d+\.\s*'));
        if (options.length >= count) {
          return options.take(count).map((option) => option.trim()).toList();
        }
        
        // If splitting failed, return the whole content as one option
        return [content];
      }
    }
    
    throw Exception('Failed to generate marketing text options');
  }
}
```

### Usage in Flutter App

```dart
class TextGenerationScreen extends StatefulWidget {
  @override
  _TextGenerationScreenState createState() => _TextGenerationScreenState();
}

class _TextGenerationScreenState extends State<TextGenerationScreen> {
  final OpenAIService _openAIService = OpenAIService('YOUR_API_KEY');
  final TextEditingController _ideaController = TextEditingController();
  bool _isGenerating = false;
  String? _generatedText;
  List<String> _textOptions = [];
  int _selectedOptionIndex = 0;
  
  Future<void> _generateMarketingText() async {
    setState(() => _isGenerating = true);
    
    try {
      // Generate multiple options for user to choose from
      final options = await _openAIService.generateMarketingTextOptions(
        _ideaController.text,
        3, // Generate 3 options
        language: 'ar', // Arabic
      );
      
      setState(() {
        _textOptions = options;
        _selectedOptionIndex = 0;
        _generatedText = options[0];
        _isGenerating = false;
      });
    } catch (e) {
      setState(() => _isGenerating = false);
      // Show error message
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Generate Marketing Text')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _ideaController,
              decoration: InputDecoration(
                hintText: 'Enter your idea here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            _isGenerating
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _generateMarketingText,
                    child: Text('Generate Options'),
                  ),
            if (_textOptions.isNotEmpty) ...[
              SizedBox(height: 24),
              Text('Select an option:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ...List.generate(_textOptions.length, (index) {
                return RadioListTile<String>(
                  title: Text(_textOptions[index]),
                  value: _textOptions[index],
                  groupValue: _generatedText,
                  onChanged: (value) {
                    setState(() {
                      _generatedText = value;
                      _selectedOptionIndex = _textOptions.indexOf(value!);
                    });
                  },
                );
              }),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, _generatedText),
                child: Text('Use This Text'),
              ),
            ],
          ],
        ),
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
  "error": {
    "message": "Invalid API key",
    "type": "invalid_request_error",
    "code": "invalid_api_key"
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
   - Use background processing for text generation
   - Show progress indicators during API calls

3. **User Experience**
   - Provide multiple options for users to choose from
   - Allow users to regenerate text if not satisfied
   - Save generated text for later use

4. **Cost Management**
   - Track API usage to control costs
   - Implement limits for free users
   - Monitor usage through your OpenAI dashboard

5. **Arabic Support**
   - Use appropriate system prompts for Arabic text generation
   - Test generated text with Arabic prompts
   - Consider cultural nuances in marketing text

---

For more detailed information, visit the official OpenAI documentation at [https://platform.openai.com/docs](https://platform.openai.com/docs)

