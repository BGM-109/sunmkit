import 'dart:async';
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';
import 'package:sunmkit/src/templates/counter/counter_bundle.dart';
import 'package:sunmkit/src/templates/post_generate_action.dart';

class CreateCommand extends Command<int> {
  CreateCommand({
    required this.logger,
  }) {
    argParser
      ..addOption(
        'name',
        abbr: 'n',
        help: 'The name of the project',
      )
      ..addFlag('org', abbr: 'o', help: 'The name of the organization');
  }

  final Logger logger;
  @override
  String get description => 'Create a new project from a template';

  @override
  String get name => 'create';

// Define a custom `LogStyle`
  String? completeLogStyle(String? m) {
    return backgroundDefault.wrap(styleBold.wrap(green.wrap(m)));
  }

  @override
  Future<int> run() async {
    final proejctName = argResults?['name'] as String;
    final org =
        argResults?['org'] ?? 'com.example.${proejctName.toLowerCase()}';
    if (proejctName.isEmpty) {
      logger.err('project name is empty');
      return ExitCode.noInput.code;
    }

    final path = '${Directory.current.path}/$proejctName';
    final runner = logger.progress('start create project...');
    final p = await Process.run(
      'flutter',
      ['create', proejctName, '--org', org.toString()],
    );
    final dir = Directory(path);
    if (p.exitCode != 0) {
      logger.err(p.stderr.toString());
      return ExitCode.software.code;
    }
    runner.complete('create project success!');
    final generator = await MasonGenerator.fromBundle(counterBundle);

    // Generate code based on the bundled brick.
    await generator.generate(
      DirectoryGeneratorTarget(
        dir,
      ),
      vars: {
        'name': proejctName,
      },
      fileConflictResolution: FileConflictResolution.overwrite,
    );
    await installFlutterPackages(logger, dir);
    await applyDartFixes(logger, dir);

    logger
      ..info('\n')
      ..info(
        'create project success! 🐱',
        //   style
        style: completeLogStyle,
      )
      ..info('\n');

    return ExitCode.success.code;
  }
}
