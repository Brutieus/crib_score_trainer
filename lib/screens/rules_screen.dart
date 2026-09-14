import 'package:flutter/material.dart';

import '../data/rules_content.dart';
import '../theme.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rules')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            rulesIntro,
            style:
                TextStyle(color: CribColors.cream, height: 1.45, fontSize: 16),
          ),
          const SizedBox(height: 16),
          for (final section in ruleSections) ...[
            Text(
              section.title,
              style: const TextStyle(
                color: CribColors.gold,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              section.body,
              style: const TextStyle(
                color: CribColors.cream,
                height: 1.45,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }
}
