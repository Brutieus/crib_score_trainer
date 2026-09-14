import 'package:crib_score_trainer/models/playing_card.dart';
import 'package:crib_score_trainer/models/score_breakdown.dart';
import 'package:crib_score_trainer/scoring/cribbage_scorer.dart';
import 'package:flutter_test/flutter_test.dart';

PlayingCard c(String s) => PlayingCard.parse(s);

ScoreBreakdown show(
  List<String> hand,
  String starter, {
  bool crib = false,
}) {
  return const CribbageScorer().score(
    hand: hand.map(c).toList(),
    starter: c(starter),
    isCrib: crib,
  );
}

void main() {
  test('29-point hand: three 5s, nobs jack, 5 starter', () {
    final r = show(['5h', '5c', '5d', 'js'], '5s');
    expect(r.total, 29);
    expect(r.pointsFor(ScoreKind.fifteen), 16);
    expect(r.pointsFor(ScoreKind.pair), 12);
    expect(r.pointsFor(ScoreKind.nobs), 1);
  });

  test('28-point hand: four 5s and a ten (no nobs)', () {
    expect(show(['5h', '5c', '5d', '5s'], 'th').total, 28);
  });

  test('crib flush needs all five; hand flush can be four', () {
    final cards = ['2h', '4h', '9h', 'kh'];
    expect(show(cards, '3c').pointsFor(ScoreKind.flush), 4);
    expect(show(cards, '3h').pointsFor(ScoreKind.flush), 5);
    expect(show(cards, '3c', crib: true).pointsFor(ScoreKind.flush), 0);
    expect(show(cards, '3h', crib: true).pointsFor(ScoreKind.flush), 5);
  });

  test('ace is low in runs; Q-K-A is not a run', () {
    expect(show(['ah', '2c', '3d', '9s'], 'kh').pointsFor(ScoreKind.run), 3);
    expect(show(['qh', 'kc', 'ad', '2s'], '9h').pointsFor(ScoreKind.run), 0);
  });

  test('double run of three with extra fifteens', () {
    final r = show(['7h', '8c', '8d', '9s'], '6h');
    // 6-7-8-9 doubled on the 8s = two runs of 4 = 8
    // fifteens: 6+9, 7+8, 7+8 = 6; pair of 8s = 2; total 16
    expect(r.pointsFor(ScoreKind.run), 8);
    expect(r.pointsFor(ScoreKind.fifteen), 6);
    expect(r.pointsFor(ScoreKind.pair), 2);
    expect(r.total, 16);
  });

  test('pair royal and nobs', () {
    final r = show(['jh', '5c', '5d', '5s'], '9h');
    expect(r.pointsFor(ScoreKind.nobs), 1);
    expect(r.pointsFor(ScoreKind.pair), 6);
    // fifteens: 5+5+5, j+5 (×3) = 8; total 15
    expect(r.pointsFor(ScoreKind.fifteen), 8);
    expect(r.total, 15);
  });

  test('starter jack is not nobs', () {
    final r = show(['ah', '2c', '9d', 'ks'], 'jh');
    expect(r.pointsFor(ScoreKind.nobs), 0);
  });

  test('zero-point show (the "19")', () {
    final r = show(['kh', 'qc', '9d', '2s'], 'ah');
    expect(r.total, 0);
  });

  test('requires four hand cards', () {
    expect(
      () => const CribbageScorer().score(
        hand: [c('ah'), c('2c'), c('3d')],
        starter: c('4s'),
        isCrib: false,
      ),
      throwsArgumentError,
    );
  });

  test('spoken count includes fifteens then pairs', () {
    final r = show(['5h', '5c', '10d', 'ks'], 'ah');
    expect(r.spoken, contains('15-'));
    // 5+10 ×2, 5+K ×2, pair of 5s = 10
    expect(r.total, 10);
  });
}
