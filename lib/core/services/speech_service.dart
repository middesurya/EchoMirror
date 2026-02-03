import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SpeechService {
  SpeechService._();
  static final SpeechService instance = SpeechService._();

  final SpeechToText _speechToText = SpeechToText();
  final AudioRecorder _audioRecorder = AudioRecorder();

  bool _isInitialized = false;
  bool _isListening = false;
  bool _isRecording = false;
  String? _currentRecordingPath;

  bool get isListening => _isListening;
  bool get isRecording => _isRecording;
  String? get currentRecordingPath => _currentRecordingPath;

  // Callbacks
  Function(String)? onResult;
  Function(String)? onPartialResult;
  Function()? onListeningStarted;
  Function()? onListeningStopped;
  Function(String)? onError;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speechToText.initialize(
        onError: (error) {
          onError?.call(error.errorMsg);
        },
        onStatus: (status) {
          if (status == 'listening') {
            _isListening = true;
            onListeningStarted?.call();
          } else if (status == 'notListening' || status == 'done') {
            _isListening = false;
            onListeningStopped?.call();
          }
        },
      );
      return _isInitialized;
    } catch (e) {
      onError?.call('Failed to initialize speech recognition: $e');
      return false;
    }
  }

  Future<void> startListening({
    String localeId = 'en_US',
    Duration? listenFor,
    Duration? pauseFor,
  }) async {
    if (!_isInitialized) {
      final success = await initialize();
      if (!success) return;
    }

    if (_isListening) return;

    try {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: localeId,
        listenFor: listenFor ?? const Duration(seconds: 30),
        pauseFor: pauseFor ?? const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: false,
        listenMode: ListenMode.dictation,
      );
    } catch (e) {
      onError?.call('Failed to start listening: $e');
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (result.finalResult) {
      onResult?.call(result.recognizedWords);
    } else {
      onPartialResult?.call(result.recognizedWords);
    }
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    await _speechToText.stop();
    _isListening = false;
    onListeningStopped?.call();
  }

  Future<void> cancelListening() async {
    await _speechToText.cancel();
    _isListening = false;
    onListeningStopped?.call();
  }

  // Audio Recording (separate from speech-to-text)
  Future<String?> startRecording() async {
    if (_isRecording) return null;

    try {
      if (!await _audioRecorder.hasPermission()) {
        onError?.call('Microphone permission denied');
        return null;
      }

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${directory.path}/recordings/voice_$timestamp.m4a';

      // Ensure directory exists
      await Directory('${directory.path}/recordings').create(recursive: true);

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentRecordingPath!,
      );

      _isRecording = true;
      return _currentRecordingPath;
    } catch (e) {
      onError?.call('Failed to start recording: $e');
      return null;
    }
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    try {
      final path = await _audioRecorder.stop();
      _isRecording = false;
      return path;
    } catch (e) {
      onError?.call('Failed to stop recording: $e');
      _isRecording = false;
      return null;
    }
  }

  Future<void> cancelRecording() async {
    if (!_isRecording) return;

    try {
      await _audioRecorder.stop();
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      onError?.call('Failed to cancel recording: $e');
    } finally {
      _isRecording = false;
      _currentRecordingPath = null;
    }
  }

  Future<List<LocaleName>> getAvailableLocales() => _speechToText.locales();

  void dispose() {
    _speechToText.cancel();
    _audioRecorder.dispose();
  }
}
