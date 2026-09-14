import 'package:flutter/material.dart';

import 'app.dart';
import 'detection/detector_factory.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(CribScoreApp(detector: createCardDetector()));
}
