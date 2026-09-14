import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/quiz_bank.dart';
import '../scoring/cribbage_scorer.dart';
import '../theme.dart';
import '../widgets/playing_card_widget.dart';
import '../widgets/score_breakdown_list.dart';

class TrainerScreen extends StatefulWidget {
  const TrainerScreen({super.key, this.random});

  final Random? random;

  @override
  State<TrainerScreen> createState() => _TrainerScreenState();
}

class _TrainerScreenState extends State<TrainerScreen> {
  final _bank = const QuizBank();
  final _controller = TextEditingController();
  late Random _rng;
  late DealtShow _deal;
  bool _revealed = false;
  String? _feedback;
  var _streak = 0;
  var _answered = 0;
  var _correct = 0;

  @override
  void initState() {
    super.initState();
    _rng = widget.random ?? Random();
    _next();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    setState(() {
      _deal = _bank.deal(nextInt: _rng.nextInt);
      _revealed = false;
      _feedback = null;
      _controller.clear();
    });
  }

  void _submit() {
    final guess = int.tryParse(_controller.text.trim());
    if (guess == null) {
      setState(() => _feedback = 'Enter a whole number.');
      return;
    }
    final actual = const CribbageScorer()
        .score(hand: _deal.hand, starter: _deal.starter, isCrib: _deal.isCrib)
        .total;
    final ok = guess == actual;
    setState(() {
      _revealed = true;
      _answered += 1;
      if (ok) {
        _correct += 1;
        _streak += 1;
        _feedback = 'Correct — $actual.';
      } else {
        _streak = 0;
        _feedback = 'You said $guess. The show is $actual.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final breakdown = const CribbageScorer().score(
      hand: _deal.hand,
      starter: _deal.starter,
      isCrib: _deal.isCrib,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Practice scoring')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Streak $_streak  ·  $_correct / $_answered correct',
            style: const TextStyle(color: CribColors.gold),
          ),
          const SizedBox(height: 8),
          Text(
            _deal.isCrib ? 'Score this crib' : 'Score this hand',
            style: const TextStyle(
              color: CribColors.cream,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final card in _deal.hand) PlayingCardWidget(card: card),
              PlayingCardWidget(
                card: _deal.starter,
                selected: true,
                label: 'Starter',
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            enabled: !_revealed,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: CribColors.cream, fontSize: 24),
            decoration: const InputDecoration(
              labelText: 'Your score',
              labelStyle: TextStyle(color: CribColors.gold),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: CribColors.gold),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: CribColors.gold, width: 2),
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          if (!_revealed)
            FilledButton(onPressed: _submit, child: const Text('Check'))
          else
            FilledButton(onPressed: _next, child: const Text('Next hand')),
          if (_feedback != null) ...[
            const SizedBox(height: 16),
            Text(
              _feedback!,
              style: const TextStyle(color: CribColors.cream, fontSize: 16),
            ),
          ],
          if (_revealed) ...[
            const SizedBox(height: 16),
            ScoreBreakdownList(breakdown: breakdown),
          ],
        ],
      ),
    );
  }
}
