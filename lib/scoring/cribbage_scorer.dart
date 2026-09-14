import '../models/playing_card.dart';
import '../models/score_breakdown.dart';

/// Official show scoring for a 4-card hand or crib plus the starter.
///
/// His heels (a jack turned as the starter) is *not* included; that 2 is
/// pegged when the starter is cut, before the show.
class CribbageScorer {
  const CribbageScorer();

  ScoreBreakdown score({
    required List<PlayingCard> hand,
    required PlayingCard starter,
    required bool isCrib,
  }) {
    if (hand.length != 4) {
      throw ArgumentError.value(
        hand,
        'hand',
        'Cribbage show uses exactly 4 cards plus a starter',
      );
    }
    final all = <PlayingCard>[...hand, starter];
    final combos = <ScoreCombo>[
      ..._fifteens(all),
      ..._pairs(all),
      ..._runs(all),
      ..._flush(hand: hand, starter: starter, isCrib: isCrib),
      ..._nobs(hand: hand, starter: starter),
    ];
    final total = combos.fold<int>(0, (sum, c) => sum + c.points);
    return ScoreBreakdown(
      total: total,
      combos: combos,
      hand: List<PlayingCard>.unmodifiable(hand),
      starter: starter,
      isCrib: isCrib,
    );
  }

  List<ScoreCombo> _fifteens(List<PlayingCard> cards) {
    final out = <ScoreCombo>[];
    final n = cards.length;
    final limit = 1 << n;
    for (var mask = 1; mask < limit; mask++) {
      var sum = 0;
      final subset = <PlayingCard>[];
      for (var i = 0; i < n; i++) {
        if ((mask & (1 << i)) != 0) {
          sum += cards[i].pip;
          subset.add(cards[i]);
        }
      }
      if (sum == 15) {
        out.add(
          ScoreCombo(
            kind: ScoreKind.fifteen,
            points: 2,
            cards: subset,
            label: 'Fifteen',
          ),
        );
      }
    }
    return out;
  }

  List<ScoreCombo> _pairs(List<PlayingCard> cards) {
    final byRank = <Rank, List<PlayingCard>>{};
    for (final card in cards) {
      byRank.putIfAbsent(card.rank, () => []).add(card);
    }
    final out = <ScoreCombo>[];
    for (final group in byRank.values) {
      final n = group.length;
      if (n < 2) continue;
      final pairCount = n * (n - 1) ~/ 2;
      final points = pairCount * 2;
      final label = switch (n) {
        2 => 'Pair',
        3 => 'Pair royal',
        4 => 'Double pair royal',
        _ => 'Pairs',
      };
      out.add(
        ScoreCombo(
          kind: ScoreKind.pair,
          points: points,
          cards: group,
          label: label,
        ),
      );
    }
    return out;
  }

  List<ScoreCombo> _runs(List<PlayingCard> cards) {
    final byValue = <int, List<PlayingCard>>{};
    for (final card in cards) {
      byValue.putIfAbsent(card.runValue, () => []).add(card);
    }
    final ranks = byValue.keys.toList()..sort();
    var bestLen = 0;
    final best = <List<int>>[];
    var i = 0;
    while (i < ranks.length) {
      var j = i;
      while (j + 1 < ranks.length && ranks[j + 1] == ranks[j] + 1) {
        j++;
      }
      final segment = ranks.sublist(i, j + 1);
      if (segment.length > bestLen) {
        bestLen = segment.length;
        best
          ..clear()
          ..add(segment);
      } else if (segment.length == bestLen) {
        best.add(segment);
      }
      i = j + 1;
    }
    if (bestLen < 3) return const [];

    final out = <ScoreCombo>[];
    for (final segment in best) {
      final groups = [for (final r in segment) byValue[r]!];
      final combinations = _cartesian(groups);
      for (final combo in combinations) {
        out.add(
          ScoreCombo(
            kind: ScoreKind.run,
            points: bestLen,
            cards: combo,
            label: 'Run of $bestLen',
          ),
        );
      }
    }
    return out;
  }

  List<ScoreCombo> _flush({
    required List<PlayingCard> hand,
    required PlayingCard starter,
    required bool isCrib,
  }) {
    final suit = hand.first.suit;
    final fourMatch = hand.every((c) => c.suit == suit);
    if (!fourMatch) return const [];
    if (isCrib) {
      if (starter.suit != suit) return const [];
      return [
        ScoreCombo(
          kind: ScoreKind.flush,
          points: 5,
          cards: [...hand, starter],
          label: 'Flush',
        ),
      ];
    }
    if (starter.suit == suit) {
      return [
        ScoreCombo(
          kind: ScoreKind.flush,
          points: 5,
          cards: [...hand, starter],
          label: 'Flush',
        ),
      ];
    }
    return [
      ScoreCombo(
        kind: ScoreKind.flush,
        points: 4,
        cards: hand,
        label: 'Flush',
      ),
    ];
  }

  List<ScoreCombo> _nobs({
    required List<PlayingCard> hand,
    required PlayingCard starter,
  }) {
    final jacks = [
      for (final card in hand)
        if (card.isJack && card.suit == starter.suit) card,
    ];
    if (jacks.isEmpty) return const [];
    return [
      ScoreCombo(
        kind: ScoreKind.nobs,
        points: 1,
        cards: jacks,
        label: 'Nobs',
      ),
    ];
  }

  List<List<PlayingCard>> _cartesian(List<List<PlayingCard>> groups) {
    var acc = <List<PlayingCard>>[<PlayingCard>[]];
    for (final group in groups) {
      final next = <List<PlayingCard>>[];
      for (final prefix in acc) {
        for (final card in group) {
          next.add([...prefix, card]);
        }
      }
      acc = next;
    }
    return acc;
  }
}
