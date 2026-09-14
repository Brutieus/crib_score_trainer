import 'dart:typed_data';

import 'package:crib_score_trainer/app.dart';
import 'package:crib_score_trainer/detection/card_detector.dart';
import 'package:crib_score_trainer/models/detected_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDetector implements CardDetector {
  @override
  ModelStatus status = const ModelStatus(
    kind: ModelKind.placeholder,
    detail: 'test',
  );

  @override
  Future<void> load() async {}

  @override
  Future<DetectionResult> detect(Uint8List imageBytes) async {
    return DetectionResult.emptyPlaceholder;
  }
}

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(CribScoreApp(detector: _FakeDetector()));
    await tester.pumpAndSettle();
  }

  testWidgets('home shows app name and core actions', (tester) async {
    await pumpApp(tester);
    expect(find.text('Crib Score Trainer'), findsOneWidget);
    expect(find.text('Score a hand'), findsOneWidget);
    expect(find.text('Score the crib'), findsOneWidget);
    expect(find.text('Enter cards'), findsOneWidget);
    expect(find.text('Practice scoring'), findsOneWidget);
    expect(find.text('Rules'), findsOneWidget);
    expect(find.textContaining('airplane mode'), findsOneWidget);
  });

  testWidgets('rules screen explains crib flush', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Rules'));
    await tester.pumpAndSettle();
    expect(find.text('Flush'), findsOneWidget);
    expect(find.textContaining('four-card crib flush does not count'),
        findsOneWidget);
  });

  testWidgets('enter cards can score a 29 hand', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Enter cards'));
    await tester.pumpAndSettle();
    expect(find.text('Score this show'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
  });
}
