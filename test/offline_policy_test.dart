import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _banned = [
  'package:http/',
  'package:dio/',
  'package:chopper/',
  'package:graphql',
  'package:firebase_',
  'package:supabase',
  'package:openai',
  'package:googleapis',
];

void main() {
  test('lib has no network client imports', () {
    final hits = <String>[];
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      final text = file.readAsStringSync();
      for (final ban in _banned) {
        if (text.contains(ban)) {
          hits.add('${file.path}: $ban');
        }
      }
    }
    expect(hits, isEmpty, reason: hits.join('\n'));
  });

  test('pubspec does not add HTTP or AI API packages', () {
    final yaml = File('pubspec.yaml').readAsStringSync();
    final deps = yaml.split('dev_dependencies:').first;
    for (final name in [
      'http:',
      'dio:',
      'chopper:',
      'firebase_core:',
      'supabase:',
      'openai:',
    ]) {
      expect(deps.contains('\n  $name'), isFalse, reason: name);
    }
  });
}
