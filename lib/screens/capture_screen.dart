import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../detection/card_detector.dart';
import '../theme.dart';
import 'manual_entry_screen.dart';
import 'review_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({
    super.key,
    required this.isCrib,
    required this.detector,
  });

  final bool isCrib;
  final CardDetector detector;

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  bool _busy = false;
  String? _error;
  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final title = widget.isCrib ? 'Score the crib' : 'Score a hand';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.isCrib
                  ? 'Photograph the four crib cards and the starter. You can tap any wrong card on the next screen.'
                  : 'Photograph the four-card hand and the starter. Detection may need tap-to-fix.',
              style: const TextStyle(
                  color: CribColors.cream, height: 1.4, fontSize: 16),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _busy ? null : () => _pick(ImageSource.camera),
              icon: const Icon(Icons.photo_camera),
              label: const Text('Take photo'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _busy ? null : () => _pick(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Choose from gallery'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _busy
                  ? null
                  : () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              ManualEntryScreen(isCrib: widget.isCrib),
                        ),
                      ),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Enter cards instead'),
            ),
            if (_busy) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Color(0xFFE57373))),
            ],
          ],
        ),
      ),
    );
  }

  Future<bool> _ensurePermission(ImageSource source) async {
    try {
      final permission =
          source == ImageSource.camera ? Permission.camera : Permission.photos;
      final status = await permission.request();
      return status.isGranted || status.isLimited || status.isRestricted;
    } catch (_) {
      // Desktop / missing plugin: image_picker still prompts at the OS level.
      return true;
    }
  }

  Future<void> _pick(ImageSource source) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final allowed = await _ensurePermission(source);
      if (!allowed) {
        if (mounted) {
          setState(() {
            _busy = false;
            _error =
                'Camera or photo permission was denied. Enable it in system settings, or enter cards by hand.';
          });
        }
        return;
      }
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        imageQuality: 90,
      );
      if (file == null) {
        if (mounted) setState(() => _busy = false);
        return;
      }
      final bytes = Uint8List.fromList(await file.readAsBytes());
      final result = await widget.detector.detect(bytes);
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ReviewScreen(
            isCrib: widget.isCrib,
            imageBytes: bytes,
            detection: result,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _error =
              'Could not open the camera or photo library ($e). Check permissions, or enter cards by hand.';
          _busy = false;
        });
      }
    }
  }
}
