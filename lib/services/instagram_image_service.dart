import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Service to fetch and process Instagram images
class InstagramImageService {
  /// Extract image URL from Instagram post URL
  ///
  /// This method fetches the Instagram post page and extracts the image URL
  /// from the page's metadata.
  static Future<String?> getImageUrlFromInstagramPost(String postUrl) async {
    try {
      // Clean the URL (remove query parameters if any)
      final cleanUrl = postUrl.split('?').first;

      // Add ?__a=1&__d=dis to get JSON response (Instagram's embed endpoint)
      final embedUrl = '$cleanUrl?__a=1&__d=dis';

      debugPrint('Fetching Instagram post: $embedUrl');

      // Fetch the page
      final response = await http.get(
        Uri.parse(embedUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': 'text/html,application/json',
        },
      );

      if (response.statusCode != 200) {
        debugPrint('Failed to fetch Instagram post: ${response.statusCode}');

        // Fallback: Try scraping the HTML
        return await _scrapeImageFromHtml(cleanUrl);
      }

      // Try to parse as JSON
      try {
        final jsonData = json.decode(response.body);

        // Navigate through the JSON structure to find the image URL
        if (jsonData['graphql'] != null) {
          final media = jsonData['graphql']['shortcode_media'];
          if (media != null) {
            // Get the highest quality image
            return media['display_url'] as String?;
          }
        }

        // Try alternative structure
        if (jsonData['items'] != null && jsonData['items'].isNotEmpty) {
          final item = jsonData['items'][0];
          if (item['image_versions2'] != null) {
            final candidates = item['image_versions2']['candidates'] as List;
            if (candidates.isNotEmpty) {
              return candidates[0]['url'] as String?;
            }
          }
        }
      } catch (e) {
        debugPrint('JSON parsing failed, trying HTML scraping: $e');
        return await _scrapeImageFromHtml(cleanUrl);
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching Instagram image: $e');
      return null;
    }
  }

  /// Scrape image URL from Instagram HTML page
  static Future<String?> _scrapeImageFromHtml(String postUrl) async {
    try {
      final response = await http.get(
        Uri.parse(postUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode != 200) {
        return null;
      }

      final html = response.body;

      // Look for display_url in the HTML
      final displayUrlPattern = RegExp(r'"display_url":"([^"]+)"');
      final match = displayUrlPattern.firstMatch(html);

      if (match != null && match.groupCount > 0) {
        var imageUrl = match.group(1)!;
        // Decode escaped characters
        imageUrl = imageUrl.replaceAll(r'\u0026', '&');
        return imageUrl;
      }

      // Alternative: Look for og:image meta tag
      final ogImagePattern = RegExp(r'<meta property="og:image" content="([^"]+)"');
      final ogMatch = ogImagePattern.firstMatch(html);

      if (ogMatch != null && ogMatch.groupCount > 0) {
        return ogMatch.group(1);
      }

      return null;
    } catch (e) {
      debugPrint('Error scraping Instagram HTML: $e');
      return null;
    }
  }

  /// Download image from URL and upload to Firebase Storage
  ///
  /// [imageUrl] The direct image URL
  /// [storagePath] Path in Firebase Storage (e.g., 'covers/story-name.jpg')
  static Future<String?> downloadAndUploadToFirebase({
    required String imageUrl,
    required String storagePath,
  }) async {
    try {
      debugPrint('Downloading image from: $imageUrl');

      // Download the image
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode != 200) {
        debugPrint('Failed to download image: ${response.statusCode}');
        return null;
      }

      final imageBytes = response.bodyBytes;
      debugPrint('Image downloaded: ${imageBytes.length} bytes');

      // Upload to Firebase Storage
      debugPrint('Uploading to Firebase: $storagePath');
      final ref = FirebaseStorage.instance.ref().child(storagePath);

      // Set metadata
      final metadata = SettableMetadata(
        contentType: _getContentType(imageUrl),
        cacheControl: 'public, max-age=31536000',
      );

      // Upload
      final uploadTask = await ref.putData(imageBytes, metadata);

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      debugPrint('Upload complete: $downloadUrl');

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading to Firebase: $e');
      return null;
    }
  }

  /// Process Instagram URL: Extract image and upload to Firebase
  ///
  /// This is a convenience method that combines extraction and upload
  static Future<String?> processInstagramUrl({
    required String instagramUrl,
    required String firebaseStoragePath,
  }) async {
    try {
      // Step 1: Extract image URL from Instagram
      final imageUrl = await getImageUrlFromInstagramPost(instagramUrl);

      if (imageUrl == null) {
        debugPrint('Failed to extract image URL from Instagram');
        return null;
      }

      debugPrint('Extracted Instagram image URL: $imageUrl');

      // Step 2: Download and upload to Firebase
      final firebaseUrl = await downloadAndUploadToFirebase(
        imageUrl: imageUrl,
        storagePath: firebaseStoragePath,
      );

      return firebaseUrl;
    } catch (e) {
      debugPrint('Error processing Instagram URL: $e');
      return null;
    }
  }

  /// Get content type from URL
  static String _getContentType(String url) {
    final uri = Uri.parse(url);
    final path = uri.path.toLowerCase();

    if (path.endsWith('.jpg') || path.endsWith('.jpeg')) {
      return 'image/jpeg';
    } else if (path.endsWith('.png')) {
      return 'image/png';
    } else if (path.endsWith('.gif')) {
      return 'image/gif';
    } else if (path.endsWith('.webp')) {
      return 'image/webp';
    }

    return 'image/jpeg'; // Default
  }

  /// Validate Instagram URL format
  static bool isValidInstagramUrl(String url) {
    final instagramPattern = RegExp(
      r'^https?://(www\.)?instagram\.com/(p|reel)/[A-Za-z0-9_-]+',
      caseSensitive: false,
    );
    return instagramPattern.hasMatch(url);
  }

  /// Extract post code from Instagram URL
  /// Example: https://instagram.com/p/ABC123/ -> ABC123
  static String? getPostCode(String url) {
    final pattern = RegExp(r'/(p|reel)/([A-Za-z0-9_-]+)');
    final match = pattern.firstMatch(url);
    return match?.group(2);
  }
}
