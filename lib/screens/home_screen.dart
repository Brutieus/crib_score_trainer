import 'package:flutter/material.dart';

import '../detection/card_detector.dart';
import '../models/detected_card.dart';
import '../theme.dart';
import 'capture_screen.dart';
import 'manual_entry_screen.dart';
import 'rules_screen.dart';
import 'trainer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.detector});

  final CardDetector detector;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<void> _loaded;

  @override
  void initState() {
    super.initState();
    _loaded = widget.detector.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crib Score Trainer')),
      body: FutureBuilder<void>(
        future: _loaded,
        builder: (context, snapshot) {
          final status = widget.detector.status;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Offline cribbage hand & crib scorer, plus a rules trainer. '
                'Works in airplane mode. No accounts, no API keys, no network calls.',
                style: TextStyle(
                    color: CribColors.cream, height: 1.4, fontSize: 16),
              ),
              const SizedBox(height: 16),
              _Banner(status: status),
              const SizedBox(height: 20),
              _ModeButton(
                icon: Icons.photo_camera_outlined,
                title: 'Score a hand',
                subtitle: 'Photograph or enter four cards + starter',
                onTap: () => _openCapture(isCrib: false),
              ),
              const SizedBox(height: 12),
              _ModeButton(
                icon: Icons.style_outlined,
                title: 'Score the crib',
                subtitle: 'Same show, with crib flush rules',
                onTap: () => _openCapture(isCrib: true),
              ),
              const SizedBox(height: 12),
              _ModeButton(
                icon: Icons.edit_outlined,
                title: 'Enter cards',
                subtitle: 'Skip the camera — tap ranks and suits',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ManualEntryScreen(isCrib: false),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _ModeButton(
                icon: Icons.school_outlined,
                title: 'Practice scoring',
                subtitle: 'Guess the show, then see the breakdown',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const TrainerScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _ModeButton(
                icon: Icons.menu_book_outlined,
                title: 'Rules',
                subtitle: 'Fifteens, pairs, runs, flush, nobs, heels',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const RulesScreen(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openCapture({required bool isCrib}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CaptureScreen(
          isCrib: isCrib,
          detector: widget.detector,
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.status});
  final ModelStatus status;

  @override
  Widget build(BuildContext context) {
    final color =
        status.isUsable ? const Color(0xFF2E7D32) : const Color(0xFF5D4A1F);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.banner,
        style: const TextStyle(color: CribColors.cream, height: 1.35),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CribColors.feltLight,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: CribColors.gold, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: CribColors.cream,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: CribColors.cream.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: CribColors.gold),
            ],
          ),
        ),
      ),
    );
  }
}
