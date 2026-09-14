import 'package:flutter/material.dart';

import '../models/playing_card.dart';
import '../theme.dart';

class PlayingCardWidget extends StatelessWidget {
  const PlayingCardWidget({
    super.key,
    this.card,
    this.label,
    this.selected = false,
    this.onTap,
    this.width = 72,
    this.height = 100,
  });

  final PlayingCard? card;
  final String? label;
  final bool selected;
  final VoidCallback? onTap;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = card;
    final suitColor = c == null
        ? CribColors.ink
        : (c.suit.isRed ? CribColors.redSuit : CribColors.blackSuit);
    return Semantics(
      button: onTap != null,
      label: c?.label ?? label ?? 'Empty card slot',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: CribColors.cream,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? CribColors.gold : const Color(0xFFB9A57A),
              width: selected ? 3 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: c == null
              ? Center(
                  child: Text(
                    label ?? '+',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: CribColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.rank.short,
                        style: TextStyle(
                          color: suitColor,
                          fontWeight: FontWeight.w800,
                          fontSize: width > 80 ? 22 : 16,
                          height: 1,
                        ),
                      ),
                      Text(
                        c.suit.symbol,
                        style: TextStyle(
                          color: suitColor,
                          fontSize: width > 80 ? 22 : 18,
                          height: 1.1,
                        ),
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          c.suit.symbol,
                          style: TextStyle(color: suitColor, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
