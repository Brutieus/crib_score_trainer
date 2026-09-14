import 'package:flutter/material.dart';

import '../models/score_breakdown.dart';
import '../theme.dart';

class ScoreBreakdownList extends StatelessWidget {
  const ScoreBreakdownList({super.key, required this.breakdown});

  final ScoreBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    if (breakdown.combos.isEmpty) {
      return const Text(
        'Nineteen. (That is the joke: this show scores 0.)',
        style: TextStyle(color: CribColors.cream, fontSize: 16),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          breakdown.spoken,
          style: const TextStyle(
            color: CribColors.gold,
            fontSize: 16,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        for (final combo in breakdown.combos)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Text(
                    '+${combo.points}',
                    style: const TextStyle(
                      color: CribColors.gold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${combo.label}  ·  ${combo.cards.map((c) => c.label).join(' ')}',
                    style: const TextStyle(color: CribColors.cream),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
