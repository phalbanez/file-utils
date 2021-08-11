import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:file/local.dart';
import 'package:glob/glob.dart';

import '../filename_and_date.dart';

class KeepsLatestFilesCommand extends Command {
  @override
  final name = 'keeps-latest-files';

  @override
  final description = 'Keeps the latest files';

  @override
  Future<void> run() async {
    final args = argResults!.rest;

    if ((args.isEmpty)) {
      throw UsageException('Path not informed.', usage);
    }
    ;

    if (args.length < 2) {
      throw UsageException(
          'Path or number of files to be kept not informed.', usage);
    }

    if (args.length > 3) {
      throw UsageException('Invalid number of parameters.', usage);
    }

    final path = args.first;
    final numberFiles = int.tryParse(args[1]) ?? -1;
    final minimumDays = (args.length == 3 ? (int.tryParse(args[2]) ?? -1) : 15);

    if (path.isEmpty) {
      throw UsageException('Invalid path parameter.', usage);
    }

    if (numberFiles <= 0) {
      throw UsageException('Invalid file number parameter.', usage);
    }

    if (minimumDays < 0) {
      throw UsageException('Invalid minimum days parameter.', usage);
    }

    return _execute(path, numberFiles, minimumDays);
  }

  @override
  String get usage {
    return super.usage.replaceFirst(
        '[arguments]', '<path> <number of files> [minimum days=15]');
  }

  Future<void> _execute(
      final String path, final int numberFiles, final int minimumDays) async {
    final dartFiles = Glob(path);
    final files = <FilenameAndDate>[];

    await for (var entity
        in dartFiles.listFileSystem(LocalFileSystem(), root: '')) {
      if (entity is File) {
        var dateFile = DateTime.now();
        await entity.stat().then((value) => dateFile = value.modified);
        files.add(FilenameAndDate(entity.path, dateFile));
      }
    }

    files.sort((a, b) => b.date.compareTo(a.date));

    var numberFilesKept = 0;
    var now = DateTime.now();
    for (var file in files) {
      var days = now.difference(file.date).inDays;
      numberFilesKept++;

      if ((numberFilesKept <= numberFiles) || (days <= minimumDays)) {
        print('${file.fileName} : ${file.date} - kept');
      }

      if ((numberFilesKept > numberFiles) && (days > minimumDays)) {
        var deleted = await _deleteFile(file.fileName);
        if (deleted) print('${file.fileName} : ${file.date} - file deleted');
      }
    }
  }

  Future<bool> _deleteFile(final String fileName) async {
    try {
      final file = File(fileName);
      await file.delete();
      return true;
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }
}
