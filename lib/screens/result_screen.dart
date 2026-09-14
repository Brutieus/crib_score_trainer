import 'package:flutter/material.dart';

import '../models/playing_card.dart';
import '../scoring/cribbage_scorer.dart';
import '../theme.dart';
import '../widgets/playing_card_widget.dart';
import '../widgets/score_breakdown_list.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.hand,
    required this.starter,
    required this.isCrib,
    this.includeHeels = false,
  });

  final List<PlayingCard> hand;
  final PlayingCard starter;
  final bool isCrib;
  final bool includeHeels;

  @override
  Widget build(BuildContext context) {
    final breakdown = const CribbageScorer().score(
      hand: hand,
      starter: starter,
      isCrib: isCrib,
    );
    final heels = includeHeels && starter.isJack ? 2 : 0;
    final total = breakdown.total + heels;
    return Scaffold(
      appBar: AppBar(title: const Text('Crib Score Trainer')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            isCrib ? 'Crib show' : 'Hand show',
            style: const TextStyle(color: CribColors.gold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final card in hand) PlayingCardWidget(card: card),
              PlayingCardWidget(
                  card: starter, selected: true, label: 'Starter'),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '$total',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: CribColors.gold,
              fontSize: 72,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const Text(
            'points',
            textAlign: TextAlign.center,
            style: TextStyle(color: CribColors.cream, fontSize: 18),
          ),
          if (heels > 0) ...[
            const SizedBox(height: 8),
            const Text(
              'Includes 2 for his heels (jack starter).',
              textAlign: TextAlign.center,
              style: TextStyle(color: CribColors.cream),
            ),
          ],
          const SizedBox(height: 24),
          ScoreBreakdownList(breakdown: breakdown),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: const Text('Back to home'),
          ),
        ],
      ),
    );
  }
}
