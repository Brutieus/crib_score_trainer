import 'package:flutter/material.dart';

import '../models/playing_card.dart';
import 'review_screen.dart';

class ManualEntryScreen extends StatelessWidget {
  const ManualEntryScreen({super.key, required this.isCrib});

  final bool isCrib;

  @override
  Widget build(BuildContext context) {
    return ReviewScreen(
      isCrib: isCrib,
      initialHand: List<PlayingCard?>.filled(4, null),
    );
  }
}
