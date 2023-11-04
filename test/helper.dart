import 'dart:io';

import 'package:cli_util/cli_logging.dart';
import 'package:get_it/get_it.dart';
import 'package:pubm/src/configuration.dart';

import 'pubm_test.dart';

Future<Configuration> testSetUp() async {
  GetIt.I.registerSingleton<Logger>(Logger.verbose());

  final Configuration config = Configuration(['-f', 'test'])
    ..pubspecFile = File(pubspecPath)
    ..pubspecFlavorFile = File(pubspecFlavorPath)
    ..backupPubspecFile = File(backupPubspecFlavorPath)
    ..flavor = 'test';

  GetIt.I.registerSingleton<Configuration>(config);

  await Directory(tempFolderPath).create(recursive: true);
  return config;
}

Future<void> tearDownSetup() async {
  GetIt.I.reset();

  if (await Directory(tempFolderPath).exists()) {
    await Directory(tempFolderPath).delete(recursive: true);
  }
}
