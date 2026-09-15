import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'backend_config.dart';

class SpeechResult {
  final bool success;
  final String text;
  final String? language;
  final double? languageProbability;
  final String? error;

  SpeechResult({
    required this.success,
    required this.text,
    this.language,
    this.languageProbability,
    this.error,
  });

  factory SpeechResult.fromJson(Map<String, dynamic> json) {
    return SpeechResult(
      success: json['success'] == true,
      text: json['text']?.toString() ?? '',
      language: json['language']?.toString(),
      languageProbability: (json['language_probability'] as num?)?.toDouble(),
      error: json['error']?.toString(),
    );
  }
}

class SpeechService {
  final AudioRecorder _recorder = AudioRecorder();

  bool _isRecording = false;
  String? _recordingPath;

  bool get isRecording => _isRecording;

  Future<bool> startRecording() async {
    try {
      final bool hasPermission = await _recorder.hasPermission();

      if (!hasPermission) {
        return false;
      }

      final Directory directory = await getTemporaryDirectory();
      final String filePath =
          '${directory.path}/shilpi_voice_${DateTime.now().millisecondsSinceEpoch}.wav';

      const RecordConfig config = RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
        autoGain: true,
        echoCancel: true,
        noiseSuppress: true,
      );

      await _recorder.start(
        config,
        path: filePath,
      );

      _recordingPath = filePath;
      _isRecording = true;

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String?> stopRecording() async {
    try {
      if (!_isRecording) {
        return null;
      }

      final String? path = await _recorder.stop();
      _isRecording = false;

      if (path != null && path.isNotEmpty) {
        _recordingPath = path;
        return path;
      }

      return _recordingPath;
    } catch (_) {
      _isRecording = false;
      return null;
    }
  }

  Future<SpeechResult> transcribeAudio(String audioPath) async {
    try {
      final File file = File(audioPath);

      if (!await file.exists()) {
        return SpeechResult(
          success: false,
          text: '',
          error: 'Audio file not found.',
        );
      }

      final http.MultipartRequest request = http.MultipartRequest(
        'POST',
        Uri.parse(BackendConfig.speechToTextUrl),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          audioPath,
          filename: 'shilpi_voice.wav',
        ),
      );

      final http.StreamedResponse streamedResponse = await request.send().timeout(
        const Duration(seconds: 40),
      );
      final http.Response response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        return SpeechResult(
          success: false,
          text: '',
          error: 'Backend error: ${response.statusCode}',
        );
      }

      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      return SpeechResult.fromJson(json);
    } catch (e) {
      return SpeechResult(
        success: false,
        text: '',
        error: e.toString(),
      );
    }
  }

  Future<SpeechResult> finishAndTranscribe() async {
    final String? audioPath = await stopRecording();

    if (audioPath == null) {
      return SpeechResult(
        success: false,
        text: '',
        error: 'Could not save recording.',
      );
    }

    final SpeechResult result = await transcribeAudio(audioPath);

    try {
      final File file = File(audioPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}

    return result;
  }

  Future<void> dispose() async {
    try {
      if (_isRecording) {
        await _recorder.stop();
      }
    } catch (_) {}

    await _recorder.dispose();
  }
}
