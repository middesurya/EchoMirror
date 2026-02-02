import 'dart:math';
import '../../shared/models/reflection.dart';
import '../errors/app_exception.dart';
import '../logging/app_logger.dart';
import '../utils/result.dart';

/// On-device sentiment analysis service
/// Uses rule-based analysis with keyword matching for privacy
/// Can be upgraded to TFLite model for better accuracy
class SentimentService {
  SentimentService._();
  static final SentimentService instance = SentimentService._();

  static const String _tag = 'SentimentService';

  // Positive keywords with weights
  static const Map<String, double> _positiveWords = {
    'happy': 1.0, 'joy': 1.0, 'love': 1.0, 'excited': 0.9, 'grateful': 0.9,
    'wonderful': 0.9, 'amazing': 0.9, 'great': 0.8, 'good': 0.7, 'nice': 0.6,
    'pleased': 0.7, 'delighted': 0.9, 'fantastic': 0.9, 'awesome': 0.9,
    'brilliant': 0.8, 'excellent': 0.9, 'beautiful': 0.8, 'peaceful': 0.8,
    'calm': 0.7, 'relaxed': 0.7, 'content': 0.7, 'satisfied': 0.7,
    'proud': 0.8, 'accomplished': 0.8, 'successful': 0.8, 'hopeful': 0.7,
    'optimistic': 0.8, 'confident': 0.7, 'energetic': 0.7, 'inspired': 0.8,
    'motivated': 0.7, 'blessed': 0.8, 'thankful': 0.8, 'appreciate': 0.7,
  };

  // Negative keywords with weights
  static const Map<String, double> _negativeWords = {
    'sad': -1.0, 'depressed': -1.0, 'angry': -0.9, 'frustrated': -0.8,
    'anxious': -0.8, 'worried': -0.7, 'stressed': -0.8, 'terrible': -0.9,
    'horrible': -0.9, 'bad': -0.7, 'awful': -0.9, 'miserable': -1.0,
    'upset': -0.7, 'disappointed': -0.8, 'hurt': -0.8, 'lonely': -0.8,
    'scared': -0.8, 'afraid': -0.8, 'nervous': -0.7, 'overwhelmed': -0.8,
    'exhausted': -0.7, 'tired': -0.5, 'bored': -0.5, 'annoyed': -0.6,
    'irritated': -0.6, 'hate': -1.0, 'despair': -1.0, 'hopeless': -1.0,
    'failed': -0.8, 'failure': -0.8, 'lost': -0.7, 'confused': -0.6,
    'uncertain': -0.5, 'doubtful': -0.6, 'regret': -0.7, 'guilty': -0.7,
  };

  // Theme keywords
  static const Map<String, List<String>> _themeKeywords = {
    'work': ['work', 'job', 'office', 'meeting', 'boss', 'colleague', 'project', 'deadline', 'career'],
    'relationships': ['friend', 'family', 'partner', 'love', 'relationship', 'date', 'marriage', 'parent', 'child'],
    'health': ['health', 'sick', 'exercise', 'gym', 'diet', 'sleep', 'tired', 'energy', 'doctor', 'medicine'],
    'growth': ['learn', 'grow', 'improve', 'goal', 'achievement', 'progress', 'skill', 'develop', 'change'],
    'adventure': ['travel', 'explore', 'adventure', 'discover', 'journey', 'trip', 'vacation', 'new'],
    'creativity': ['create', 'art', 'music', 'write', 'design', 'imagine', 'idea', 'inspire', 'build'],
    'nature': ['nature', 'outside', 'park', 'garden', 'tree', 'sky', 'sun', 'rain', 'ocean', 'mountain'],
    'technology': ['computer', 'phone', 'app', 'code', 'internet', 'game', 'tech', 'digital', 'software'],
  };

  // Negation words that flip sentiment
  static const List<String> _negationWords = [
    'not', "don't", "doesn't", "didn't", "won't", "wouldn't", "couldn't",
    "shouldn't", "can't", "cannot", 'never', 'no', 'neither', 'nobody',
  ];

  // Intensifiers that amplify sentiment
  static const Map<String, double> _intensifiers = {
    'very': 1.5, 'really': 1.4, 'extremely': 1.8, 'absolutely': 1.7,
    'totally': 1.5, 'completely': 1.6, 'so': 1.3, 'incredibly': 1.7,
    'highly': 1.4, 'deeply': 1.5, 'truly': 1.4, 'quite': 1.2,
  };

  /// Analyze text and return sentiment data wrapped in Result
  /// 
  /// Returns [Success<SentimentData>] on successful analysis
  /// Returns [Failure] with [AnalysisException] on error
  Future<Result<SentimentData>> analyze(String text) async {
    logDebug('Starting sentiment analysis', tag: _tag, context: {
      'textLength': text.length,
    });

    // Validate input
    if (text.trim().isEmpty) {
      logWarning('Empty text provided for analysis', tag: _tag);
      return Failure(AnalysisException.emptyInput());
    }

    try {
      final lowerText = text.toLowerCase();
      final words = _tokenize(lowerText);
      
      // Calculate sentiment score
      double score = 0.0;
      int sentimentWordCount = 0;
      final keywords = <String>[];

      for (int i = 0; i < words.length; i++) {
        final word = words[i];
        double wordScore = 0.0;

        // Check positive words
        if (_positiveWords.containsKey(word)) {
          wordScore = _positiveWords[word]!;
          keywords.add(word);
        }
        // Check negative words
        else if (_negativeWords.containsKey(word)) {
          wordScore = _negativeWords[word]!;
          keywords.add(word);
        }

        if (wordScore != 0.0) {
          // Check for negation in previous words
          if (_hasNegationBefore(words, i)) {
            wordScore = -wordScore * 0.8; // Flip and slightly reduce
          }

          // Check for intensifiers
          final intensifier = _getIntensifierBefore(words, i);
          if (intensifier > 1.0) {
            wordScore *= intensifier;
          }

          score += wordScore;
          sentimentWordCount++;
        }
      }

      // Normalize score to -1.0 to 1.0 range
      if (sentimentWordCount > 0) {
        score = score / sentimentWordCount;
        score = score.clamp(-1.0, 1.0);
      }

      // Extract themes
      final themes = _extractThemes(lowerText);

      // Determine sentiment label
      String sentiment;
      if (score > 0.2) {
        sentiment = 'positive';
      } else if (score < -0.2) {
        sentiment = 'negative';
      } else {
        sentiment = 'neutral';
      }

      final result = SentimentData(
        sentiment: sentiment,
        score: score,
        keywords: keywords.take(10).toList(),
        themes: themes,
      );

      logInfo('Sentiment analysis completed', tag: _tag, context: {
        'sentiment': sentiment,
        'score': score,
        'keywordCount': keywords.length,
        'themeCount': themes.length,
      });

      return Success(result);
    } catch (e, stackTrace) {
      logError(
        'Sentiment analysis failed',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
        context: {'textLength': text.length},
      );
      return Failure(AnalysisException(
        'Sentiment analysis failed: $e',
        code: 'ANALYSIS_FAILED',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Legacy method for backward compatibility
  /// Prefer using [analyze] which returns Result<SentimentData>
  @Deprecated('Use analyze() with Result type instead')
  Future<SentimentData> analyzeUnsafe(String text) async {
    final result = await analyze(text);
    return result.fold(
      onSuccess: (data) => data,
      onFailure: (_) => _getDefaultSentiment(),
    );
  }

  List<String> _tokenize(String text) {
    // Remove punctuation and split into words
    return text
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
  }

  bool _hasNegationBefore(List<String> words, int index) {
    // Check up to 3 words before for negation
    final start = max(0, index - 3);
    for (int i = start; i < index; i++) {
      if (_negationWords.contains(words[i])) {
        return true;
      }
    }
    return false;
  }

  double _getIntensifierBefore(List<String> words, int index) {
    // Check immediate previous word for intensifier
    if (index > 0) {
      final prevWord = words[index - 1];
      if (_intensifiers.containsKey(prevWord)) {
        return _intensifiers[prevWord]!;
      }
    }
    return 1.0;
  }

  List<String> _extractThemes(String text) {
    final themes = <String>[];

    for (final entry in _themeKeywords.entries) {
      for (final keyword in entry.value) {
        if (text.contains(keyword)) {
          if (!themes.contains(entry.key)) {
            themes.add(entry.key);
          }
          break;
        }
      }
    }

    return themes.take(5).toList();
  }

  SentimentData _getDefaultSentiment() {
    return SentimentData(
      sentiment: 'neutral',
      score: 0.0,
      keywords: [],
      themes: [],
    );
  }

  /// Combine emotion and sentiment data into a unified mood analysis
  /// Returns Result with combined analysis or failure
  Result<Map<String, dynamic>> combinedAnalysis({
    EmotionData? emotionData,
    SentimentData? sentimentData,
  }) {
    logDebug('Combining emotion and sentiment data', tag: _tag);

    try {
      String dominantMood = 'neutral';
      double confidence = 0.5;

      if (emotionData != null && sentimentData != null) {
        // Weight: 40% emotion, 60% sentiment (text is usually more expressive)
        const emotionWeight = 0.4;
        const sentimentWeight = 0.6;

        // Map emotion to numeric score
        final emotionScore = _emotionToScore(emotionData.dominantEmotion);
        final combinedScore = (emotionScore * emotionWeight) +
            (sentimentData.score * sentimentWeight);

        if (combinedScore > 0.3) {
          dominantMood = 'positive';
        } else if (combinedScore < -0.3) {
          dominantMood = 'negative';
        } else {
          dominantMood = 'neutral';
        }

        confidence = (emotionData.confidence + (1 - sentimentData.score.abs())) / 2;
      } else if (emotionData != null) {
        dominantMood = _emotionToMood(emotionData.dominantEmotion);
        confidence = emotionData.confidence;
      } else if (sentimentData != null) {
        dominantMood = sentimentData.sentiment;
        confidence = sentimentData.score.abs();
      }

      final result = {
        'dominantMood': dominantMood,
        'confidence': confidence,
        'emotionData': emotionData,
        'sentimentData': sentimentData,
      };

      logInfo('Combined analysis completed', tag: _tag, context: {
        'dominantMood': dominantMood,
        'confidence': confidence,
      });

      return Success(result);
    } catch (e, stackTrace) {
      logError(
        'Combined analysis failed',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return Failure(AnalysisException(
        'Combined analysis failed: $e',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  double _emotionToScore(String emotion) {
    switch (emotion) {
      case 'happy':
      case 'surprised':
        return 0.8;
      case 'sad':
      case 'angry':
        return -0.8;
      case 'anxious':
        return -0.5;
      case 'neutral':
      default:
        return 0.0;
    }
  }

  String _emotionToMood(String emotion) {
    switch (emotion) {
      case 'happy':
      case 'surprised':
        return 'positive';
      case 'sad':
      case 'angry':
      case 'anxious':
        return 'negative';
      case 'neutral':
      default:
        return 'neutral';
    }
  }
}
