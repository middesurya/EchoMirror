import 'package:hive/hive.dart';

part 'reflection.g.dart';

@HiveType(typeId: 0)
class Reflection extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final String? voiceRecordingPath;

  @HiveField(4)
  final String? imagePath;

  @HiveField(5)
  final EmotionData? emotionData;

  @HiveField(6)
  final SentimentData? sentimentData;

  @HiveField(7)
  final String? echoResponseId;

  Reflection({
    required this.id,
    required this.text,
    required this.createdAt,
    this.voiceRecordingPath,
    this.imagePath,
    this.emotionData,
    this.sentimentData,
    this.echoResponseId,
  });

  Reflection copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
    String? voiceRecordingPath,
    String? imagePath,
    EmotionData? emotionData,
    SentimentData? sentimentData,
    String? echoResponseId,
  }) {
    return Reflection(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      voiceRecordingPath: voiceRecordingPath ?? this.voiceRecordingPath,
      imagePath: imagePath ?? this.imagePath,
      emotionData: emotionData ?? this.emotionData,
      sentimentData: sentimentData ?? this.sentimentData,
      echoResponseId: echoResponseId ?? this.echoResponseId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'voiceRecordingPath': voiceRecordingPath,
        'imagePath': imagePath,
        'emotionData': emotionData?.toJson(),
        'sentimentData': sentimentData?.toJson(),
        'echoResponseId': echoResponseId,
      };

  factory Reflection.fromJson(Map<String, dynamic> json) => Reflection(
        id: json['id'] as String,
        text: json['text'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        voiceRecordingPath: json['voiceRecordingPath'] as String?,
        imagePath: json['imagePath'] as String?,
        emotionData: json['emotionData'] != null
            ? EmotionData.fromJson(json['emotionData'] as Map<String, dynamic>)
            : null,
        sentimentData: json['sentimentData'] != null
            ? SentimentData.fromJson(
                json['sentimentData'] as Map<String, dynamic>)
            : null,
        echoResponseId: json['echoResponseId'] as String?,
      );
}

@HiveType(typeId: 1)
class EmotionData {
  @HiveField(0)
  final String dominantEmotion;

  @HiveField(1)
  final double confidence;

  @HiveField(2)
  final Map<String, double> emotionScores;

  EmotionData({
    required this.dominantEmotion,
    required this.confidence,
    required this.emotionScores,
  });

  Map<String, dynamic> toJson() => {
        'dominantEmotion': dominantEmotion,
        'confidence': confidence,
        'emotionScores': emotionScores,
      };

  factory EmotionData.fromJson(Map<String, dynamic> json) => EmotionData(
        dominantEmotion: json['dominantEmotion'] as String,
        confidence: (json['confidence'] as num).toDouble(),
        emotionScores: Map<String, double>.from(
          (json['emotionScores'] as Map).map(
            (k, v) => MapEntry(k as String, (v as num).toDouble()),
          ),
        ),
      );
}

@HiveType(typeId: 2)
class SentimentData {
  @HiveField(0)
  final String sentiment; // positive, negative, neutral

  @HiveField(1)
  final double score; // -1.0 to 1.0

  @HiveField(2)
  final List<String> keywords;

  @HiveField(3)
  final List<String> themes;

  SentimentData({
    required this.sentiment,
    required this.score,
    required this.keywords,
    required this.themes,
  });

  Map<String, dynamic> toJson() => {
        'sentiment': sentiment,
        'score': score,
        'keywords': keywords,
        'themes': themes,
      };

  factory SentimentData.fromJson(Map<String, dynamic> json) => SentimentData(
        sentiment: json['sentiment'] as String,
        score: (json['score'] as num).toDouble(),
        keywords: List<String>.from(json['keywords'] as List),
        themes: List<String>.from(json['themes'] as List),
      );
}
