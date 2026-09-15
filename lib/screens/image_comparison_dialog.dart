import 'dart:io';
import 'package:flutter/material.dart';

import '../constants.dart';

class ImageComparisonResult {
  final String selectedPath;
  final bool isEnhanced;

  const ImageComparisonResult({
    required this.selectedPath,
    required this.isEnhanced,
  });
}

class ImageComparisonDialog extends StatefulWidget {
  final String originalPath;
  final String enhancedPath;
  final bool isAiEnhanced;
  final List<String> enhancements;

  const ImageComparisonDialog({
    super.key,
    required this.originalPath,
    required this.enhancedPath,
    required this.isAiEnhanced,
    this.enhancements = const <String>[],
  });

  @override
  State<ImageComparisonDialog> createState() => _ImageComparisonDialogState();
}

class _ImageComparisonDialogState extends State<ImageComparisonDialog> {
  int _selectedView = 1; // 0 = Original, 1 = Enhanced

  @override
  Widget build(BuildContext context) {
    final String currentPath =
        _selectedView == 1 ? widget.enhancedPath : widget.originalPath;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const CircleAvatar(
                    backgroundColor: kGreen,
                    radius: 18,
                    child: Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'AI Marketplace Transformation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: kDarkGreen,
                          ),
                        ),
                        Text(
                          'Authentic craft preserved • Studio presentation',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    iconSize: 20,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              SegmentedButton<int>(
                segments: const <ButtonSegment<int>>[
                  ButtonSegment<int>(
                    value: 0,
                    label: Text('Original Photo'),
                    icon: Icon(Icons.photo_outlined, size: 16),
                  ),
                  ButtonSegment<int>(
                    value: 1,
                    label: Text('Marketplace Image'),
                    icon: Icon(Icons.storefront, size: 16),
                  ),
                ],
                selected: <int>{_selectedView},
                onSelectionChanged: (Set<int> newSelection) {
                  setState(() {
                    _selectedView = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 14),

              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F4EC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.file(
                    File(currentPath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Center(
                child: Text(
                  _selectedView == 1
                      ? '✨ Professional Marketplace View (Clean Studio)'
                      : '📷 Raw Artisan Capture',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _selectedView == 1 ? kGreen : Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              if (widget.enhancements.isNotEmpty) ...<Widget>[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F7F4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Authentic AI Enhancements:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: kDarkGreen,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...widget.enhancements.take(4).map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Icon(Icons.check_circle, size: 14, color: kGreen),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    e,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(
                    context,
                    ImageComparisonResult(
                      selectedPath: widget.enhancedPath,
                      isEnhanced: true,
                    ),
                  );
                },
                icon: const Icon(Icons.auto_awesome),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Use Enhanced Image'),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(
                    context,
                    ImageComparisonResult(
                      selectedPath: widget.originalPath,
                      isEnhanced: false,
                    ),
                  );
                },
                icon: const Icon(Icons.image),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Use Original Image'),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Try Again (Retake Photo)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
