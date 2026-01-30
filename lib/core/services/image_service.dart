import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'storage_service.dart';

/// Service for generating images via Replicate API (Stable Diffusion)
/// Falls back gracefully when offline or API unavailable
class ImageService {
  ImageService._();
  static final ImageService instance = ImageService._();

  static const String _replicateBaseUrl = 'https://api.replicate.com/v1';
  static const String _modelVersion = 'stability-ai/sdxl:39ed52f2a78e934b3ba6e2a89f5b1c712de7dfea535525255b1aa35c5565e08b';

  String? _apiKey;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Get API key from secure storage
    _apiKey = await StorageService.instance.getSecure('replicate_api_key');
    _isInitialized = true;
  }

  Future<void> setApiKey(String apiKey) async {
    _apiKey = apiKey;
    await StorageService.instance.saveSecure('replicate_api_key', apiKey);
  }

  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  /// Generate an image from a text prompt
  /// Returns the local path to the saved image, or null if failed
  Future<String?> generateImage({
    required String prompt,
    String? negativePrompt,
    int width = 1024,
    int height = 1024,
  }) async {
    if (!_isInitialized) await initialize();
    
    if (!hasApiKey) {
      print('No Replicate API key configured');
      return null;
    }

    try {
      // Create prediction
      final predictionResponse = await http.post(
        Uri.parse('$_replicateBaseUrl/predictions'),
        headers: {
          'Authorization': 'Token $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'version': _modelVersion.split(':').last,
          'input': {
            'prompt': prompt,
            'negative_prompt': negativePrompt ?? 'low quality, blurry, distorted, deformed, ugly, bad anatomy',
            'width': width,
            'height': height,
            'num_outputs': 1,
            'scheduler': 'K_EULER',
            'num_inference_steps': 25,
            'guidance_scale': 7.5,
            'refine': 'expert_ensemble_refiner',
          },
        }),
      );

      if (predictionResponse.statusCode != 201) {
        print('Failed to create prediction: ${predictionResponse.body}');
        return null;
      }

      final prediction = jsonDecode(predictionResponse.body);
      final predictionId = prediction['id'];

      // Poll for completion
      String? imageUrl;
      for (int i = 0; i < 60; i++) {
        await Future.delayed(const Duration(seconds: 2));

        final statusResponse = await http.get(
          Uri.parse('$_replicateBaseUrl/predictions/$predictionId'),
          headers: {
            'Authorization': 'Token $_apiKey',
          },
        );

        if (statusResponse.statusCode != 200) {
          print('Failed to check prediction status: ${statusResponse.body}');
          continue;
        }

        final status = jsonDecode(statusResponse.body);
        final state = status['status'];

        if (state == 'succeeded') {
          final output = status['output'];
          if (output is List && output.isNotEmpty) {
            imageUrl = output.first as String;
          }
          break;
        } else if (state == 'failed' || state == 'canceled') {
          print('Prediction failed: ${status['error']}');
          return null;
        }
      }

      if (imageUrl == null) {
        print('Prediction timed out');
        return null;
      }

      // Download and save image
      return await _downloadImage(imageUrl);
    } catch (e) {
      print('Error generating image: $e');
      return null;
    }
  }

  Future<String?> _downloadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode != 200) {
        print('Failed to download image: ${response.statusCode}');
        return null;
      }

      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/images');
      await imagesDir.create(recursive: true);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${imagesDir.path}/echo_$timestamp.png';
      
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      return filePath;
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }

  /// Generate a placeholder image when API is unavailable
  /// Returns a gradient-based placeholder
  Future<String> generatePlaceholder({
    required String genre,
    int width = 512,
    int height = 512,
  }) async {
    // For now, return a path to a local placeholder
    // In production, this would generate a procedural image
    final directory = await getApplicationDocumentsDirectory();
    final placeholderPath = '${directory.path}/images/placeholder_$genre.png';
    
    // Check if placeholder exists
    if (await File(placeholderPath).exists()) {
      return placeholderPath;
    }
    
    // Return a default path - the UI will handle missing images
    return placeholderPath;
  }

  /// Check if the service is available (has API key and connectivity)
  Future<bool> isAvailable() async {
    if (!_isInitialized) await initialize();
    if (!hasApiKey) return false;

    try {
      final response = await http.get(
        Uri.parse('$_replicateBaseUrl/models'),
        headers: {
          'Authorization': 'Token $_apiKey',
        },
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
