import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../constants.dart';
import '../services/backend_config.dart';

class VoiceResult {
  final String text;
  final String language;
  final double? confidence;

  const VoiceResult({
    required this.text,
    required this.language,
    this.confidence,
  });
}

class VoiceCaptureDialog extends StatefulWidget {
  final String title;
  final String instruction;

  const VoiceCaptureDialog({
    super.key,
    required this.title,
    required this.instruction,
  });

  @override
  State<VoiceCaptureDialog> createState() => _VoiceCaptureDialogState();
}

class _VoiceCaptureDialogState extends State<VoiceCaptureDialog> {
  final AudioRecorder _recorder = AudioRecorder();

  bool _isRecording = false;
  bool _isProcessing = false;
  String _transcript = '';
  String _detectedLanguage = '';
  double? _confidence;
  String _status = 'Tap the microphone and speak naturally.';

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
      return;
    }

    final bool hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      setState(() {
        _status = 'Microphone permission is required.';
      });
      return;
    }

    final Directory temp = await getTemporaryDirectory();
    final String path =
        '${temp.path}/shilpi_voice_${DateTime.now().millisecondsSinceEpoch}.wav';

    try {
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
          autoGain: true,
          echoCancel: true,
          noiseSuppress: true,
        ),
        path: path,
      );

      setState(() {
        _isRecording = true;
        _transcript = '';
        _detectedLanguage = '';
        _confidence = null;
        _status = 'Listening… speak now';
      });
    } catch (e) {
      setState(() {
        _status = 'Could not start microphone: $e';
      });
    }
  }

  Future<void> _stopRecording() async {
    final String? path = await _recorder.stop();

    setState(() {
      _isRecording = false;
      _isProcessing = true;
      _status = 'AI is recognizing your speech…';
    });

    if (path == null) {
      setState(() {
        _isProcessing = false;
        _status = 'No recording was captured.';
      });
      return;
    }

    try {
      final http.MultipartRequest request = http.MultipartRequest(
        'POST',
        Uri.parse(BackendConfig.speechToTextUrl),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          path,
          filename: 'voice.wav',
        ),
      );

      final http.StreamedResponse streamed = await request.send().timeout(
        const Duration(seconds: 45),
      );
      final String body = await streamed.stream.bytesToString();

      if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
        throw Exception('Backend returned ${streamed.statusCode}: $body');
      }

      final dynamic decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid response format.');
      }

      if (decoded['success'] == false) {
        throw Exception(decoded['error']?.toString() ?? 'Recognition failed.');
      }

      final String text = decoded['text']?.toString().trim() ?? '';
      final String lang = decoded['language']?.toString().trim() ?? '';
      final double? prob = (decoded['language_probability'] as num?)?.toDouble();

      if (text.isEmpty) {
        throw Exception('No speech recognized. Please speak closer to the mic.');
      }

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
        _transcript = text;
        _detectedLanguage = languageName(lang);
        _confidence = prob;
        _status = 'Speech recognized successfully.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _status = 'Recognition notice: $e';
      });
    } finally {
      try {
        final f = File(path);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w900)),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              widget.instruction,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black87, fontSize: 13),
            ),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: _isProcessing ? null : _toggleRecording,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: _isRecording ? Colors.red : kGreen,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: (_isRecording ? Colors.red : kGreen).withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            if (_isProcessing) ...<Widget>[
              const SizedBox(height: 12),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: kGreen),
              ),
            ],
            if (_transcript.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F7F4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kGreen.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text(
                          'Recognized Speech:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: kGreen,
                          ),
                        ),
                        if (_confidence != null)
                          Text(
                            'Confidence: ${(_confidence! * 100).toInt()}%',
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _transcript,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: kGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Detected Language: $_detectedLanguage',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: kDarkGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _isRecording || _isProcessing ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (_transcript.isNotEmpty)
          FilledButton(
            onPressed: _isProcessing
                ? null
                : () => Navigator.pop(
                      context,
                      VoiceResult(
                        text: _transcript,
                        language: detectedLanguageCodeFromName(_detectedLanguage),
                        confidence: _confidence,
                      ),
                    ),
            child: const Text('Use This / Continue'),
          ),
      ],
    );
  }
}
