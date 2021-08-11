import 'dart:io';

import 'package:io/io.dart';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import 'src/commands/copy_latest_files.dart';
import 'src/commands/keeps_latest_files.dart';

void run(final List<String> arguments) async {
  final runner = configureCommand(arguments);

  final hasCommand = runner.commands.keys.any((x) => arguments.contains(x));

  if (hasCommand) {
    try {
      await executeCommand(runner, arguments);
      exit(ExitCode.success.code);
    } on UsageException catch (error) {
      print(error);
      exit(ExitCode.usage.code);
    } on Exception catch (error) {
      print(error);
      exit(ExitCode.ioError.code);
    }
  } else {
    final parser = runner.argParser;
    try {
      final results = parser.parse(arguments);
      executeOptions(results, arguments, runner);
    } on Exception catch (error) {
      print(error);
      exit(ExitCode.ioError.code);
    }
  }
}

void executeOptions(final ArgResults results, final List<String> arguments,
    final CommandRunner runner) {
  if (results.wasParsed('help') || arguments.isEmpty) {
    print(runner.usage);
  } else if (results.wasParsed('version')) {
    version();
  } else {
    print('Command not found!\n');
    print(runner.usage);
  }
}

Future executeCommand(
    final CommandRunner runner, final List<String> arguments) {
  return runner.run(arguments);
}

CommandRunner configureCommand(final List<String> arguments) {
  var runner =
      CommandRunner('file_utils', 'Some useful functions for handling files.')
        ..addCommand(KeepsLatestFilesCommand())
        ..addCommand(CopyLatestFilesCommand());

  runner.argParser.addFlag('version', abbr: 'v', negatable: false);

  return runner;
}

void version({final String version = '1.0.0'}) {
  print(' version: $version');
}
