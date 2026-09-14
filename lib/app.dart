import 'package:flutter/material.dart';

import 'detection/card_detector.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

class CribScoreApp extends StatelessWidget {
  const CribScoreApp({super.key, required this.detector});

  final CardDetector detector;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crib Score Trainer',
      debugShowCheckedModeBanner: false,
      theme: cribTheme(),
      home: HomeScreen(detector: detector),
    );
  }
}
