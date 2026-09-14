import 'playing_card.dart';

enum ScoreKind { fifteen, pair, run, flush, nobs }

class ScoreCombo {
  const ScoreCombo({
    required this.kind,
    required this.points,
    required this.cards,
    required this.label,
  });

  final ScoreKind kind;
  final int points;
  final List<PlayingCard> cards;
  final String label;
}

class ScoreBreakdown {
  const ScoreBreakdown({
    required this.total,
    required this.combos,
    required this.hand,
    required this.starter,
    required this.isCrib,
  });

  final int total;
  final List<ScoreCombo> combos;
  final List<PlayingCard> hand;
  final PlayingCard starter;
  final bool isCrib;

  int pointsFor(ScoreKind kind) => combos
      .where((c) => c.kind == kind)
      .fold<int>(0, (sum, c) => sum + c.points);

  /// Pegging-style running count: "15-2, 15-4, pair 2, run of 3 for 3, nobs 1".
  String get spoken {
    if (combos.isEmpty) return '0';
    final parts = <String>[];
    var running = 0;
    for (final combo in combos) {
      running += combo.points;
      switch (combo.kind) {
        case ScoreKind.fifteen:
          parts.add('15-$running');
        case ScoreKind.pair:
          parts.add('${combo.label} $running');
        case ScoreKind.run:
          parts.add('${combo.label} for $running');
        case ScoreKind.flush:
          parts.add('flush $running');
        case ScoreKind.nobs:
          parts.add('nobs $running');
      }
    }
    return parts.join(', ');
  }
}
