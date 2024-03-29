import 'dart:io';

import 'package:cli_util/cli_logging.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:pubm/src/extensions.dart';

import 'configuration.dart';

/// Handles windows files build steps
class FlutterBuild {
  final Logger _logger = GetIt.I<Logger>();
  final Configuration _config = GetIt.I<Configuration>();

  /// Run "flutter build windows" command
  Future<void> build() async {
    final flutterBuildArgs = [
      ...?_config.buildArgs,
    ];

    var flutterPath = await _getFlutterPath();

    final Progress loggerProgress =
        _logger.progress('running "flutter ${flutterBuildArgs.join(' ')}"');

    _logger.trace('build windows files with the command: '
        '"$flutterPath ${flutterBuildArgs.join(' ')}"');

    final ProcessResult buildProcess =
        await Process.run(flutterPath, flutterBuildArgs, runInShell: true);

    buildProcess.exitOnError();

    loggerProgress.finish(showTiming: true);
  }

  Future<void> pubGet({required bool isFlutterProject}) async {
    var flutterPath = await _getFlutterPath();
    var dartPath = await _getDartPath();

    final Progress loggerProgress = _logger
        .progress('running "${isFlutterProject ? 'flutter' : 'dart'} pub get"');

    final ProcessResult pubGetProgress = await Process.run(
      isFlutterProject ? flutterPath : dartPath,
      ['pub', 'get'],
      runInShell: true,
    );

    pubGetProgress.exitOnError();

    loggerProgress.finish(showTiming: true);
  }
}

Future<String> _getFlutterPath() async {
  // use environment-variable 'flutter' by default
  var flutterPath = 'flutter';

  // e.g. C:\Users\MyUser\fvm\versions\3.10.5\bin\cache\dart-sdk\bin\dart
  final dartPath = p.split(Platform.executable);

  // if contains 'cache\dart-sdk' we can know where is the 'flutter' located
  if (dartPath.contains('dart-sdk') && dartPath.length > 4) {
    // e.g. C:\Users\MyUser\fvm\versions\3.10.5\bin\flutter
    final flutterRelativePath = p.joinAll([
      ...dartPath.sublist(0, dartPath.length - 4),
      flutterPath,
    ]);

    if (await File(flutterRelativePath).exists()) {
      flutterPath = flutterRelativePath;
    }
  }

  return flutterPath;
}

Future<String> _getDartPath() async {
  // e.g. C:\Users\MyUser\fvm\versions\3.10.5\bin\cache\dart-sdk\bin\dart
  final dartPath = p.split(Platform.executable);

  // e.g. C:\Users\MyUser\fvm\versions\3.10.5\bin\flutter
  final dartRelativePath = p.joinAll(dartPath);

  return dartRelativePath;
}
