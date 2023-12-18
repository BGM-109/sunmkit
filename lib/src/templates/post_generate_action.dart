import 'dart:io';

import 'package:mason/mason.dart';

Future<void> installFlutterPackages(
  Logger logger,
  Directory outputDir,
) async {
  final process = logger.progress('pub get...');

  final pubResult = await Process.run(
    'flutter',
    [
      'pub',
      'get',
    ],
    workingDirectory: outputDir.path,
    // runInShell: true,
  );

  if (pubResult.exitCode != 0) {
    logger.err(pubResult.stderr.toString());

    throw Exception('pub get failed');
  }

  process.complete('pub get success!');
}

/// Runs `dart fix --apply` in the [outputDir].
Future<void> applyDartFixes(
  Logger logger,
  Directory outputDir, {
  bool recursive = false,
}) async {
  final process = logger.progress('fixing...');
  // dart fix --apply
  final fixingResult = await Process.run(
    'dart',
    ['fix', '--apply'],
    workingDirectory: outputDir.path,
    runInShell: true,
  );
  if (fixingResult.exitCode != 0) {
    logger.err(fixingResult.stderr.toString());
    throw Exception('dart fix failed');
  }
  process.complete('fixing success!');
}
