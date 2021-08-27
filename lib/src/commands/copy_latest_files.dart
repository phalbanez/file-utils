import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:args/command_runner.dart';
import 'package:file/local.dart';
import 'package:glob/glob.dart';

import '../filename_and_date.dart';

class CopyLatestFilesCommand extends Command {
  @override
  final name = 'copy-latest-files';

  @override
  final description = 'Copy the latest files';

  @override
  Future<void> run() async {
    final args = argResults!.rest;

    if ((args.isEmpty)) {
      throw UsageException('Source path not informed.', usage);
    }

    if (args.length < 2) {
      throw UsageException(
          'Source path or destination path not informed.', usage);
    }

    if (args.length > 3) {
      throw UsageException('Invalid number of parameters.', usage);
    }

    final sourcePath = args.first;
    final destPath = args[1];
    final numberFiles = (args.length == 3 ? (int.tryParse(args[2]) ?? -1) : 1);

    if (sourcePath.isEmpty) {
      throw UsageException('Invalid source parameter.', usage);
    }

    if (destPath.isEmpty) {
      throw UsageException('Invalid destination path parameter.', usage);
    }

    if (numberFiles < 1) {
      throw UsageException('Invalid file number parameter.', usage);
    }

    if (!await Directory(destPath).exists()) {
      throw UsageException(
          'Destination path "$destPath" does not exist.', usage);
    }

    return _execute(sourcePath, destPath, numberFiles);
  }

  @override
  String get usage {
    return super.usage.replaceFirst(
        '[arguments]', '<path> <destination path> [number of files=1]');
  }

  Future<void> _execute(final String sourcePath, final String destPath,
      final int numberFiles) async {
    final dartFiles = Glob(sourcePath);
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

    var numberFilesCopy = 0;
    for (var file in files) {
      numberFilesCopy++;

      var sourceFileName = file.fileName;
      var destFileName = path.join(destPath, path.basename(sourceFileName));
      var copied = await _copyFile(sourceFileName, destFileName);
      if (copied) print('${file.fileName} copied to $destFileName');

      if (numberFilesCopy >= numberFiles) break;
    }
  }

  Future<bool> _copyFile(
      final String sourceFileName, final String destFileName) async {
    try {
      final file = File(sourceFileName);
      await file.copy(destFileName);
      await _setLastModified(destFileName, await file.lastModified());
      return true;
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> _setLastModified(
      final String fileName, final DateTime lastModified) async {
    try {
      final file = File(fileName);
      await file.setLastModified(lastModified);
      return true;
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }
}
