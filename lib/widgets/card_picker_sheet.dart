import 'package:flutter/material.dart';

import '../models/playing_card.dart';
import '../theme.dart';
import 'playing_card_widget.dart';

Future<PlayingCard?> showCardPicker(
  BuildContext context, {
  PlayingCard? selected,
  Set<PlayingCard> taken = const {},
}) {
  return showModalBottomSheet<PlayingCard>(
    context: context,
    isScrollControlled: true,
    backgroundColor: CribColors.feltLight,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: CribColors.gold.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Tap a card to fix detection or fill a slot',
              style: TextStyle(color: CribColors.cream),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 420,
              child: GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.72,
                children: [
                  for (final card in PlayingCard.fullDeck)
                    Opacity(
                      opacity:
                          taken.contains(card) && card != selected ? 0.35 : 1,
                      child: PlayingCardWidget(
                        card: card,
                        selected: card == selected,
                        width: 64,
                        height: 90,
                        onTap: () => Navigator.pop(context, card),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
