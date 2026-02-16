import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';

class ImageGenerationService {
  static final ImageGenerationService _instance =
      ImageGenerationService._internal();
  factory ImageGenerationService() => _instance;
  ImageGenerationService._internal();

  // TODO: Move this to a secure configuration file or environment variable
  // For now, this needs to be configured before building for production
  static const String _apiKey = 'YOUR_OPENAI_API_KEY_HERE';
  static const String _openAiImageUrl =
      'https://api.openai.com/v1/images/generations';
  static const String _openAiChatUrl =
      'https://api.openai.com/v1/chat/completions';

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ---------------------------------------------------------------------------
  // Ask ChatGPT to decide the page count and write all Swahili sentences.
  // Returns a map: {'sentences': List<String>, 'pageCount': int}
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> generateSwahiliStory({
    required String storyTitle,
    required String storyPrompt,
    int maxRetries = 3,
  }) async {
    final systemMsg =
        'You are a children\'s picture book author who writes in Swahili. '
        'You decide how many pages (between 4 and 12) a story needs based on its complexity. '
        'Each page gets exactly ONE short Swahili sentence (10–20 words). '
        'Sentences must be vivid, simple, child-friendly (ages 3–10), and progress the story naturally from start to finish. '
        'Use proper Swahili grammar. Do not include any English text.';

    final userMsg =
        'Create a complete children\'s picture book story in Swahili. '
        'Title: "$storyTitle". '
        'Description: $storyPrompt. '
        'Decide how many pages (4–12) best suit this story. '
        'Return ONLY a valid JSON object with exactly these two keys: '
        '"pageCount" (an integer) and "sentences" (an array of that many Swahili strings). '
        'Example: {"pageCount": 6, "sentences": ["Sentence 1.", "Sentence 2.", ...]}';

    int attempt = 0;
    while (true) {
      attempt++;
      try {
        final client = http.Client();
        try {
          final response = await client
              .post(
                Uri.parse(_openAiChatUrl),
                headers: {
                  'Authorization': 'Bearer $_apiKey',
                  'Content-Type': 'application/json',
                },
                body: jsonEncode({
                  'model': 'gpt-4o-mini',
                  'messages': [
                    {'role': 'system', 'content': systemMsg},
                    {'role': 'user', 'content': userMsg},
                  ],
                  'temperature': 0.8,
                  'max_tokens': 900,
                  'response_format': {'type': 'json_object'},
                }),
              )
              .timeout(const Duration(seconds: 30));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final content =
                data['choices'][0]['message']['content'] as String;
            final Map<String, dynamic> parsed = jsonDecode(content);
            final sentences = (parsed['sentences'] as List<dynamic>)
                .map((e) => e.toString())
                .toList();
            final pageCount =
                parsed['pageCount'] as int? ?? sentences.length;
            // Guard: clamp to 4–12, align list length
            final clamped = pageCount.clamp(4, 12);
            while (sentences.length < clamped) {
              sentences.add('Hadithi inaendelea...');
            }
            return {
              'sentences': sentences.take(clamped).toList(),
              'pageCount': clamped,
            };
          } else if (response.statusCode == 429 ||
              response.statusCode >= 500) {
            if (attempt >= maxRetries) {
              throw Exception(
                  'ChatGPT Error ${response.statusCode} after $maxRetries attempts.');
            }
            await Future.delayed(Duration(seconds: 3 * attempt));
          } else {
            final err = jsonDecode(response.body);
            throw Exception(
                'ChatGPT Error: ${(err['error'] as Map?)?['message'] ?? response.body}');
          }
        } finally {
          client.close();
        }
      } on Exception catch (e) {
        final msg = e.toString();
        final isRetryable = msg.contains('SocketException') ||
            msg.contains('TimeoutException') ||
            msg.contains('connection abort') ||
            msg.contains('Broken pipe') ||
            msg.contains('Software caused');
        if (isRetryable && attempt < maxRetries) {
          await Future.delayed(Duration(seconds: 2 * attempt));
          continue;
        }
        // On failure fall back to a 6-page placeholder so generation continues
        const fallback = 6;
        return {
          'sentences': List.generate(
              fallback, (i) => 'Ukurasa ${i + 1} wa hadithi ya $storyTitle.'),
          'pageCount': fallback,
        };
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Generate a single DALL-E 3 image (no text in image)
  // ---------------------------------------------------------------------------
  Future<String> generateImage(String prompt,
      {String size = '1024x1024', int maxRetries = 3}) async {
    int attempt = 0;
    while (true) {
      attempt++;
      try {
        final client = http.Client();
        try {
          final response = await client
              .post(
                Uri.parse(_openAiImageUrl),
                headers: {
                  'Authorization': 'Bearer $_apiKey',
                  'Content-Type': 'application/json',
                },
                body: jsonEncode({
                  'model': 'dall-e-3',
                  'prompt': prompt,
                  'n': 1,
                  'size': size,
                  'response_format': 'b64_json',
                  'quality': 'standard',
                  'style': 'vivid',
                }),
              )
              .timeout(const Duration(seconds: 90));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final b64 = data['data'][0]['b64_json'] as String;
            return b64;
          } else if (response.statusCode == 429 ||
              response.statusCode >= 500) {
            if (attempt >= maxRetries) {
              throw Exception(
                  'DALL-E Error ${response.statusCode} after $maxRetries attempts.');
            }
            await Future.delayed(Duration(seconds: 3 * attempt));
          } else {
            Map<String, dynamic> error;
            try {
              error = jsonDecode(response.body) as Map<String, dynamic>;
            } catch (_) {
              throw Exception(
                  'DALL-E Error ${response.statusCode}: ${response.body}');
            }
            final msg =
                (error['error'] as Map?)?.containsKey('message') == true
                    ? error['error']['message']
                    : response.body;
            throw Exception('DALL-E Error: $msg');
          }
        } finally {
          client.close();
        }
      } on Exception catch (e) {
        final msg = e.toString();
        final isRetryable = msg.contains('connection abort') ||
            msg.contains('SocketException') ||
            msg.contains('TimeoutException') ||
            msg.contains('Connection reset') ||
            msg.contains('Broken pipe') ||
            msg.contains('Software caused');
        if (isRetryable && attempt < maxRetries) {
          await Future.delayed(Duration(seconds: 2 * attempt));
          continue;
        }
        rethrow;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Upload bytes to Firebase Storage
  // ---------------------------------------------------------------------------
  Future<String> uploadImageToStorage(
      String base64Image, String storagePath) async {
    final bytes = base64Decode(base64Image);
    final ref = _storage.ref().child(storagePath);
    final metadata = SettableMetadata(contentType: 'image/png');
    final uploadTask =
        await ref.putData(Uint8List.fromList(bytes), metadata);
    return await uploadTask.ref.getDownloadURL();
  }

  // ---------------------------------------------------------------------------
  // Split & clean pasted story text into well-sized verse sentences via GPT.
  // Returns a List<String> of clean verses ready for the reader.
  // ---------------------------------------------------------------------------
  Future<List<String>> splitPastedStory({
    required String rawText,
    int maxRetries = 3,
  }) async {
    final systemMsg =
        'You are an expert text formatter for children\'s story books. '
        'You receive raw story text (may be Swahili or any language) and split it into '
        'clean, well-sized reading verses — each verse being one meaningful sentence or '
        'short paragraph (15–40 words). Fix punctuation and spacing. '
        'Do NOT translate or rewrite the content — preserve the original wording exactly. '
        'Return ONLY a valid JSON object with one key "verses" containing an array of strings.';

    final userMsg =
        'Split this story into clean reading verses. '
        'Preserve the original text exactly — do not translate or change the words. '
        'Each verse should be one clear sentence or short thought (15–40 words). '
        'Return JSON: {"verses": ["verse 1", "verse 2", ...]}\n\n'
        'Story text:\n$rawText';

    int attempt = 0;
    while (true) {
      attempt++;
      try {
        final client = http.Client();
        try {
          final response = await client
              .post(
                Uri.parse(_openAiChatUrl),
                headers: {
                  'Authorization': 'Bearer $_apiKey',
                  'Content-Type': 'application/json',
                },
                body: jsonEncode({
                  'model': 'gpt-4o-mini',
                  'messages': [
                    {'role': 'system', 'content': systemMsg},
                    {'role': 'user', 'content': userMsg},
                  ],
                  'temperature': 0.2,
                  'max_tokens': 2000,
                  'response_format': {'type': 'json_object'},
                }),
              )
              .timeout(const Duration(seconds: 45));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final content =
                data['choices'][0]['message']['content'] as String;
            final Map<String, dynamic> parsed = jsonDecode(content);
            final verses = (parsed['verses'] as List<dynamic>)
                .map((e) => e.toString().trim())
                .where((s) => s.isNotEmpty)
                .toList();
            return verses.isNotEmpty ? verses : _fallbackSplit(rawText);
          } else if (response.statusCode == 429 ||
              response.statusCode >= 500) {
            if (attempt >= maxRetries) {
              return _fallbackSplit(rawText);
            }
            await Future.delayed(Duration(seconds: 3 * attempt));
          } else {
            return _fallbackSplit(rawText);
          }
        } finally {
          client.close();
        }
      } on Exception catch (e) {
        final msg = e.toString();
        final isRetryable = msg.contains('SocketException') ||
            msg.contains('TimeoutException') ||
            msg.contains('connection abort') ||
            msg.contains('Broken pipe') ||
            msg.contains('Software caused');
        if (isRetryable && attempt < maxRetries) {
          await Future.delayed(Duration(seconds: 2 * attempt));
          continue;
        }
        return _fallbackSplit(rawText);
      }
    }
  }

  // Simple local fallback: split on sentence-ending punctuation
  List<String> _fallbackSplit(String text) {
    final raw = text.trim();
    // Split on . ! ? followed by whitespace or end
    final parts = raw
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.isEmpty) return [raw];
    // Merge very short fragments (< 5 words) with the next one
    final merged = <String>[];
    String buffer = '';
    for (final part in parts) {
      if (buffer.isEmpty) {
        buffer = part;
      } else if (buffer.split(' ').length < 5) {
        buffer = '$buffer $part';
      } else {
        merged.add(buffer);
        buffer = part;
      }
    }
    if (buffer.isNotEmpty) merged.add(buffer);
    return merged;
  }

  // ---------------------------------------------------------------------------
  // Generate full book: cover image + story text.
  // If [pastedStoryText] is provided, that text is formatted into verses.
  // Otherwise GPT generates a new Swahili story from [storyPrompt].
  // Only ONE cover image is generated. Returns: 'coverUrl', 'pageUrls', 'pageTexts'
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> generateBookImages({
    required String storyTitle,
    required String bookId,
    String storyPrompt = '',
    String? pastedStoryText,
    void Function(String status, double progress)? onProgress,
  }) async {
    List<String> pageTexts;

    if (pastedStoryText != null && pastedStoryText.trim().isNotEmpty) {
      // Mode A: User pasted their own story — format it into verses
      onProgress?.call('Kupanga hadithi katika mistari...', 0.0);
      pageTexts = await splitPastedStory(rawText: pastedStoryText.trim());
    } else {
      // Mode B: AI generates a new Swahili story from the prompt
      onProgress?.call('Kuandika hadithi kwa Kiswahili...', 0.0);
      final storyResult = await generateSwahiliStory(
        storyTitle: storyTitle,
        storyPrompt: storyPrompt,
      );
      pageTexts = List<String>.from(storyResult['sentences'] as List);
    }

    // Generate the cover illustration based on title only
    onProgress?.call('Kutengeneza picha ya jalada...', 0.5);
    final coverPrompt =
        'Children\'s picture book cover illustration for a story called "$storyTitle". '
        'Colorful, vibrant, African art style, friendly characters, suitable for young children. '
        'Professional picture book cover composition. '
        'IMPORTANT: Do NOT include any text, letters, words, or writing anywhere in the image.';

    final coverB64 = await generateImage(coverPrompt, size: '1024x1024');
    final coverUrl =
        await uploadImageToStorage(coverB64, 'books/$bookId/cover.png');

    onProgress?.call('Kitabu kimetengenezwa!', 1.0);

    return {
      'coverUrl': coverUrl,
      'pageUrls': <String>[],
      'pageTexts': pageTexts,
    };
  }
}
