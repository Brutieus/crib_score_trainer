class RuleSection {
  const RuleSection({required this.title, required this.body});
  final String title;
  final String body;
}

const rulesIntro =
    'Crib Score Trainer scores the show: four cards in a hand or the crib, '
    'plus the starter (cut). Pegging during the play is a separate count and '
    'is summarized at the bottom. Scoring is computed on-device from the '
    'cards you confirm — never from a network API.';

const ruleSections = <RuleSection>[
  RuleSection(
    title: 'The show',
    body:
        'Each player scores their four-card hand with the starter. The dealer '
        'then scores the crib with the same starter. Combinations use all five '
        'cards together except for flush (see below) and nobs (jack in the four '
        'cards, not the starter).',
  ),
  RuleSection(
    title: 'Fifteens',
    body: 'Every distinct subset of the five cards whose pip values add to 15 '
        'scores 2. Ace = 1, 2–10 face value, J/Q/K = 10. Count every way: '
        'two cards, three cards, four, or all five.',
  ),
  RuleSection(
    title: 'Pairs',
    body:
        'A pair scores 2. Three of a kind is a pair royal (three pairs) for 6. '
        'Four of a kind is a double pair royal (six pairs) for 12.',
  ),
  RuleSection(
    title: 'Runs',
    body: 'A run is three or more consecutive ranks (Ace is always low: A-2-3 '
        'counts, Q-K-A does not). Score the longest run only — do not also '
        'count the shorter runs inside it. Duplicates multiply the run: two '
        '7s with 8-9 is two runs of three for 6.',
  ),
  RuleSection(
    title: 'Flush',
    body:
        'In a hand, four cards of one suit score 4; if the starter is the same '
        'suit, 5. In the crib a flush scores only if all five cards are the '
        'same suit (5 points). A four-card crib flush does not count.',
  ),
  RuleSection(
    title: 'Nobs (his nobs)',
    body: 'A jack in the four-card hand or crib that matches the starter suit '
        'scores 1. The starter itself is never nobs.',
  ),
  RuleSection(
    title: 'His heels (nibs)',
    body: 'If the starter is a jack, the dealer pegs 2 immediately when it is '
        'turned. That 2 is not part of the show total this app prints. Turn '
        'on “include heels” only if you want the cut jack added for practice.',
  ),
  RuleSection(
    title: 'The 29 hand',
    body: 'The highest show is 29: three 5s and the jack of the starter suit, '
        'with the fourth 5 as the starter. Fifteens 16 + double pair royal 12 '
        '+ nobs 1. There is no 19-point hand — “19” is the table’s joke for a '
        'zero.',
  ),
  RuleSection(
    title: 'Pegging (play of the cards)',
    body: 'Players alternate laying cards, adding pips toward 31. Score 2 for '
        'hitting 15 or 31, pairs and runs on the consecutive cards of the '
        'play, and 1 for a go (or last card). This trainer does not auto-score '
        'pegging from a photo; use it as a rules reference.',
  ),
  RuleSection(
    title: 'Detection limits',
    body: 'On-device YOLO/TFLite can misread overlapping cards, glare, or odd '
        'backs. Always review the five cards and tap any wrong one to fix it '
        'before you trust the total. Scoring is exact for the cards you confirm.',
  ),
];
