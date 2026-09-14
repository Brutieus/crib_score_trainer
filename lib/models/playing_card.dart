enum Suit {
  clubs,
  diamonds,
  hearts,
  spades;

  String get letter {
    switch (this) {
      case Suit.clubs:
        return 'c';
      case Suit.diamonds:
        return 'd';
      case Suit.hearts:
        return 'h';
      case Suit.spades:
        return 's';
    }
  }

  String get symbol {
    switch (this) {
      case Suit.clubs:
        return '♣';
      case Suit.diamonds:
        return '♦';
      case Suit.hearts:
        return '♥';
      case Suit.spades:
        return '♠';
    }
  }

  bool get isRed => this == Suit.hearts || this == Suit.diamonds;
}

enum Rank {
  ace,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten,
  jack,
  queen,
  king;

  String get short {
    switch (this) {
      case Rank.ace:
        return 'A';
      case Rank.jack:
        return 'J';
      case Rank.queen:
        return 'Q';
      case Rank.king:
        return 'K';
      case Rank.ten:
        return '10';
      case Rank.two:
        return '2';
      case Rank.three:
        return '3';
      case Rank.four:
        return '4';
      case Rank.five:
        return '5';
      case Rank.six:
        return '6';
      case Rank.seven:
        return '7';
      case Rank.eight:
        return '8';
      case Rank.nine:
        return '9';
    }
  }

  /// Ace = 1, face cards = 10, otherwise pip value.
  int get pip {
    switch (this) {
      case Rank.ace:
        return 1;
      case Rank.jack:
      case Rank.queen:
      case Rank.king:
        return 10;
      default:
        return index + 1;
    }
  }

  /// Ace-low order used for runs (Ace..King = 1..13).
  int get runValue => index + 1;
}

/// One standard playing card. Equality is rank+suit.
class PlayingCard implements Comparable<PlayingCard> {
  const PlayingCard(this.rank, this.suit);

  final Rank rank;
  final Suit suit;

  int get pip => rank.pip;
  int get runValue => rank.runValue;
  bool get isJack => rank == Rank.jack;

  /// Codes used by geaxgx / Roboflow-style YOLO card models: `Ah`, `10s`, `Kc`.
  String get className => '${rank.short}${suit.letter}';

  String get label => '${rank.short}${suit.symbol}';

  /// Parses `AS`, `Ah`, `10s`, `T♣`, `10C`, `jc`, etc.
  static PlayingCard parse(String raw) {
    final s = raw.trim();
    if (s.isEmpty) {
      throw FormatException('Empty card string', raw);
    }
    final lower = s.toLowerCase();
    Suit? suit;
    String rankPart;

    final last = lower[lower.length - 1];
    switch (last) {
      case 'c':
      case '♣':
        suit = Suit.clubs;
        rankPart = s.substring(0, s.length - 1);
      case 'd':
      case '♦':
        suit = Suit.diamonds;
        rankPart = s.substring(0, s.length - 1);
      case 'h':
      case '♥':
        suit = Suit.hearts;
        rankPart = s.substring(0, s.length - 1);
      case 's':
      case '♠':
        suit = Suit.spades;
        rankPart = s.substring(0, s.length - 1);
      default:
        throw FormatException('Card must end with a suit (c/d/h/s)', raw);
    }

    final rank = parseRank(rankPart);
    return PlayingCard(rank, suit);
  }

  static Rank parseRank(String raw) {
    switch (raw.trim().toUpperCase()) {
      case 'A':
      case '1':
      case 'ACE':
        return Rank.ace;
      case '2':
        return Rank.two;
      case '3':
        return Rank.three;
      case '4':
        return Rank.four;
      case '5':
        return Rank.five;
      case '6':
        return Rank.six;
      case '7':
        return Rank.seven;
      case '8':
        return Rank.eight;
      case '9':
        return Rank.nine;
      case '10':
      case 'T':
        return Rank.ten;
      case 'J':
      case 'JACK':
        return Rank.jack;
      case 'Q':
      case 'QUEEN':
        return Rank.queen;
      case 'K':
      case 'KING':
        return Rank.king;
      default:
        throw FormatException('Unknown rank "$raw"', raw);
    }
  }

  static Suit parseSuitLetter(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'c':
      case '♣':
      case 'clubs':
        return Suit.clubs;
      case 'd':
      case '♦':
      case 'diamonds':
        return Suit.diamonds;
      case 'h':
      case '♥':
      case 'hearts':
        return Suit.hearts;
      case 's':
      case '♠':
      case 'spades':
        return Suit.spades;
      default:
        throw FormatException('Unknown suit "$raw"', raw);
    }
  }

  static const List<PlayingCard> fullDeck = [
    PlayingCard(Rank.ace, Suit.clubs),
    PlayingCard(Rank.two, Suit.clubs),
    PlayingCard(Rank.three, Suit.clubs),
    PlayingCard(Rank.four, Suit.clubs),
    PlayingCard(Rank.five, Suit.clubs),
    PlayingCard(Rank.six, Suit.clubs),
    PlayingCard(Rank.seven, Suit.clubs),
    PlayingCard(Rank.eight, Suit.clubs),
    PlayingCard(Rank.nine, Suit.clubs),
    PlayingCard(Rank.ten, Suit.clubs),
    PlayingCard(Rank.jack, Suit.clubs),
    PlayingCard(Rank.queen, Suit.clubs),
    PlayingCard(Rank.king, Suit.clubs),
    PlayingCard(Rank.ace, Suit.diamonds),
    PlayingCard(Rank.two, Suit.diamonds),
    PlayingCard(Rank.three, Suit.diamonds),
    PlayingCard(Rank.four, Suit.diamonds),
    PlayingCard(Rank.five, Suit.diamonds),
    PlayingCard(Rank.six, Suit.diamonds),
    PlayingCard(Rank.seven, Suit.diamonds),
    PlayingCard(Rank.eight, Suit.diamonds),
    PlayingCard(Rank.nine, Suit.diamonds),
    PlayingCard(Rank.ten, Suit.diamonds),
    PlayingCard(Rank.jack, Suit.diamonds),
    PlayingCard(Rank.queen, Suit.diamonds),
    PlayingCard(Rank.king, Suit.diamonds),
    PlayingCard(Rank.ace, Suit.hearts),
    PlayingCard(Rank.two, Suit.hearts),
    PlayingCard(Rank.three, Suit.hearts),
    PlayingCard(Rank.four, Suit.hearts),
    PlayingCard(Rank.five, Suit.hearts),
    PlayingCard(Rank.six, Suit.hearts),
    PlayingCard(Rank.seven, Suit.hearts),
    PlayingCard(Rank.eight, Suit.hearts),
    PlayingCard(Rank.nine, Suit.hearts),
    PlayingCard(Rank.ten, Suit.hearts),
    PlayingCard(Rank.jack, Suit.hearts),
    PlayingCard(Rank.queen, Suit.hearts),
    PlayingCard(Rank.king, Suit.hearts),
    PlayingCard(Rank.ace, Suit.spades),
    PlayingCard(Rank.two, Suit.spades),
    PlayingCard(Rank.three, Suit.spades),
    PlayingCard(Rank.four, Suit.spades),
    PlayingCard(Rank.five, Suit.spades),
    PlayingCard(Rank.six, Suit.spades),
    PlayingCard(Rank.seven, Suit.spades),
    PlayingCard(Rank.eight, Suit.spades),
    PlayingCard(Rank.nine, Suit.spades),
    PlayingCard(Rank.ten, Suit.spades),
    PlayingCard(Rank.jack, Suit.spades),
    PlayingCard(Rank.queen, Suit.spades),
    PlayingCard(Rank.king, Suit.spades),
  ];

  @override
  int compareTo(PlayingCard other) {
    final r = rank.index.compareTo(other.rank.index);
    if (r != 0) return r;
    return suit.index.compareTo(other.suit.index);
  }

  @override
  bool operator ==(Object other) =>
      other is PlayingCard && other.rank == rank && other.suit == suit;

  @override
  int get hashCode => Object.hash(rank, suit);

  @override
  String toString() => className;
}
