import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

import '../../shared/models/reflection.dart';

class EmotionService {
  EmotionService._();
  static final EmotionService instance = EmotionService._();

  FaceDetector? _faceDetector;
  bool _isInitialized = false;

  // Emotion labels based on facial landmarks analysis
  static const List<String> emotionLabels = [
    'happy',
    'sad',
    'angry',
    'surprised',
    'fearful',
    'disgusted',
    'neutral',
  ];

  Future<void> initialize() async {
    if (_isInitialized) return;

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
        enableContours: true,
        enableTracking: false,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );

    _isInitialized = true;
  }

  Future<EmotionData?> analyzeImage(String imagePath) async {
    if (!_isInitialized) await initialize();

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final faces = await _faceDetector!.processImage(inputImage);

      if (faces.isEmpty) {
        return _getDefaultEmotion();
      }

      // Analyze the first (most prominent) face
      final face = faces.first;
      return _analyzeFace(face);
    } catch (e) {
      print('Error analyzing image: $e');
      return _getDefaultEmotion();
    }
  }

  Future<EmotionData?> analyzeFromCamera(CameraImage cameraImage, int rotation) async {
    if (!_isInitialized) await initialize();

    try {
      final inputImage = _convertCameraImage(cameraImage, rotation);
      if (inputImage == null) return null;

      final faces = await _faceDetector!.processImage(inputImage);

      if (faces.isEmpty) return null;

      final face = faces.first;
      return _analyzeFace(face);
    } catch (e) {
      print('Error analyzing camera image: $e');
      return null;
    }
  }

  InputImage? _convertCameraImage(CameraImage image, int rotation) {
    try {
      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      if (format == null) return null;

      final plane = image.planes.first;

      return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.values.firstWhere(
            (r) => r.rawValue == rotation,
            orElse: () => InputImageRotation.rotation0deg,
          ),
          format: format,
          bytesPerRow: plane.bytesPerRow,
        ),
      );
    } catch (e) {
      print('Error converting camera image: $e');
      return null;
    }
  }

  EmotionData _analyzeFace(Face face) {
    final scores = <String, double>{};

    // Get smile probability
    final smileProbability = face.smilingProbability ?? 0.0;
    
    // Get eye open probabilities
    final leftEyeOpen = face.leftEyeOpenProbability ?? 0.5;
    final rightEyeOpen = face.rightEyeOpenProbability ?? 0.5;
    final eyesOpen = (leftEyeOpen + rightEyeOpen) / 2;

    // Calculate emotion scores based on facial features
    // Happy: High smile probability
    scores['happy'] = smileProbability;

    // Sad: Low smile, slightly closed eyes
    scores['sad'] = (1 - smileProbability) * 0.6 * (1 - eyesOpen * 0.3);

    // Surprised: Wide eyes
    scores['surprised'] = eyesOpen > 0.8 ? (eyesOpen - 0.8) * 5 : 0.0;

    // Angry: Low smile, intense features
    scores['angry'] = (1 - smileProbability) * 0.4;

    // Neutral: Neither happy nor sad
    final extremeScore = (scores['happy']! + scores['sad']! + scores['surprised']!) / 3;
    scores['neutral'] = 1 - extremeScore;

    // Normalize scores
    final total = scores.values.reduce((a, b) => a + b);
    if (total > 0) {
      scores.updateAll((key, value) => value / total);
    }

    // Find dominant emotion
    final dominantEntry = scores.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    return EmotionData(
      dominantEmotion: dominantEntry.key,
      confidence: dominantEntry.value,
      emotionScores: scores,
    );
  }

  EmotionData _getDefaultEmotion() {
    return EmotionData(
      dominantEmotion: 'neutral',
      confidence: 0.5,
      emotionScores: {
        'happy': 0.1,
        'sad': 0.1,
        'angry': 0.1,
        'surprised': 0.1,
        'neutral': 0.6,
      },
    );
  }

  Future<String?> captureAndSaveImage(CameraController controller) async {
    try {
      final image = await controller.takePicture();
      return image.path;
    } catch (e) {
      print('Error capturing image: $e');
      return null;
    }
  }

  void dispose() {
    _faceDetector?.close();
    _faceDetector = null;
    _isInitialized = false;
  }
}
