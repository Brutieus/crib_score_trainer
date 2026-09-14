import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/detected_card.dart';
import '../models/playing_card.dart';
import '../theme.dart';
import '../widgets/card_picker_sheet.dart';
import '../widgets/playing_card_widget.dart';
import 'result_screen.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({
    super.key,
    required this.isCrib,
    this.imageBytes,
    this.detection,
    this.initialHand,
    this.initialStarter,
  });

  final bool isCrib;
  final Uint8List? imageBytes;
  final DetectionResult? detection;
  final List<PlayingCard?>? initialHand;
  final PlayingCard? initialStarter;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late List<PlayingCard?> _hand;
  PlayingCard? _starter;

  @override
  void initState() {
    super.initState();
    _hand = widget.initialHand ?? List<PlayingCard?>.filled(4, null);
    _starter = widget.initialStarter;
    final detected = widget.detection?.cards ?? const [];
    if (widget.initialHand == null && detected.isNotEmpty) {
      final cards = [for (final d in detected) d.card];
      if (cards.length >= 5) {
        _hand = cards.take(4).toList();
        _starter = cards[4];
      } else {
        for (var i = 0; i < cards.length && i < 4; i++) {
          _hand[i] = cards[i];
        }
      }
    }
  }

  Set<PlayingCard> get _taken => {
        for (final c in _hand)
          if (c != null) c,
        if (_starter != null) _starter!,
      };

  bool get _ready => _hand.every((c) => c != null) && _starter != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCrib ? 'Review crib' : 'Review hand'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (widget.detection?.message != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                widget.detection!.message!,
                style: const TextStyle(color: CribColors.gold, height: 1.35),
              ),
            ),
          const Text(
            'Tap any card to fix a bad detection. Mark the starter (cut).',
            style: TextStyle(color: CribColors.cream, height: 1.4),
          ),
          if (widget.imageBytes != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(widget.imageBytes!, fit: BoxFit.cover),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            widget.isCrib ? 'Crib (4)' : 'Hand (4)',
            style: const TextStyle(
              color: CribColors.gold,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < 4; i++)
                PlayingCardWidget(
                  card: _hand[i],
                  label: 'Card ${i + 1}',
                  onTap: () => _pickHand(i),
                ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Starter',
            style: TextStyle(
              color: CribColors.gold,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          PlayingCardWidget(
            card: _starter,
            label: 'Cut',
            selected: true,
            onTap: _pickStarter,
          ),
          if (widget.detection != null &&
              widget.detection!.cards.length > 5) ...[
            const SizedBox(height: 16),
            Text(
              'Detector found ${widget.detection!.cards.length} cards. Extra boxes were ignored — tap-to-fix if the wrong four were kept.',
              style: TextStyle(color: CribColors.cream.withValues(alpha: 0.85)),
            ),
          ],
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _ready ? _score : null,
            child: const Text('Score this show'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickHand(int index) async {
    final chosen = await showCardPicker(
      context,
      selected: _hand[index],
      taken: _taken,
    );
    if (chosen != null) {
      setState(() => _hand[index] = chosen);
    }
  }

  Future<void> _pickStarter() async {
    final chosen = await showCardPicker(
      context,
      selected: _starter,
      taken: _taken,
    );
    if (chosen != null) {
      setState(() => _starter = chosen);
    }
  }

  void _score() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(
          hand: List<PlayingCard>.from(_hand.cast<PlayingCard>()),
          starter: _starter!,
          isCrib: widget.isCrib,
        ),
      ),
    );
  }
}
