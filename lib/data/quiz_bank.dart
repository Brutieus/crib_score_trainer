import '../models/playing_card.dart';
import '../scoring/cribbage_scorer.dart';

class DealtShow {
  const DealtShow({
    required this.hand,
    required this.starter,
    required this.isCrib,
  });

  final List<PlayingCard> hand;
  final PlayingCard starter;
  final bool isCrib;
}

class QuizBank {
  const QuizBank({this.scorer = const CribbageScorer()});

  final CribbageScorer scorer;

  /// Shuffles a 52-card deck and deals 4 + starter. Optional [random] for tests.
  DealtShow deal({required int Function(int max) nextInt, bool? isCrib}) {
    final deck = List<PlayingCard>.from(PlayingCard.fullDeck);
    for (var i = deck.length - 1; i > 0; i--) {
      final j = nextInt(i + 1);
      final tmp = deck[i];
      deck[i] = deck[j];
      deck[j] = tmp;
    }
    return DealtShow(
      hand: deck.sublist(0, 4),
      starter: deck[4],
      isCrib: isCrib ?? (nextInt(2) == 1),
    );
  }
}
