import 'dart:io';

import 'package:crib_score_trainer/models/playing_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses geaxgx-style class names', () {
    expect(PlayingCard.parse('Ah'), const PlayingCard(Rank.ace, Suit.hearts));
    expect(PlayingCard.parse('10s'), const PlayingCard(Rank.ten, Suit.spades));
    expect(PlayingCard.parse('Kc'), const PlayingCard(Rank.king, Suit.clubs));
    expect(
        PlayingCard.parse('jd'), const PlayingCard(Rank.jack, Suit.diamonds));
    expect(PlayingCard.parse('T♣').rank, Rank.ten);
  });

  test('round-trips className', () {
    for (final card in PlayingCard.fullDeck) {
      expect(PlayingCard.parse(card.className), card);
    }
    expect(PlayingCard.fullDeck.length, 52);
  });

  test('assets/models/class_names.txt is 52 parseable cards', () {
    final names = File('assets/models/class_names.txt')
        .readAsStringSync()
        .split(RegExp(r'\r?\n'))
        .where((l) => l.trim().isNotEmpty)
        .toList();
    expect(names, hasLength(52));
    expect(
      names.map(PlayingCard.parse).toSet(),
      unorderedEquals(PlayingCard.fullDeck),
    );
  });

  test('pip values', () {
    expect(PlayingCard.parse('Ah').pip, 1);
    expect(PlayingCard.parse('9c').pip, 9);
    expect(PlayingCard.parse('10d').pip, 10);
    expect(PlayingCard.parse('Js').pip, 10);
    expect(PlayingCard.parse('Qh').pip, 10);
    expect(PlayingCard.parse('Kd').pip, 10);
  });
}
