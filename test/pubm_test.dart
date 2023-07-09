import 'dart:io';

import 'package:cli_util/cli_logging.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:pubm/models/pubspec.dart';
import 'package:pubm/src/configuration.dart';
import 'package:pubm/src/helpers/pubspec_checker.dart';
import 'package:pubm/src/pubspec_manage.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import 'test_constants.dart';

const String flavor = 'test';
var tempFolderPath = p.join('test', 'configuration_temp');
var pubspecPath = p.join(tempFolderPath, 'pubspec.yaml');
var pubspecFlavorPath = p.join(tempFolderPath, 'pubspec_$flavor.yaml');
var backupPubspecFlavorPath = p.join(tempFolderPath, 'backup_pubspec.yaml');

void main() {
  late Configuration config;
  late TestClass testClass;
  const flavorYamlContent = '''

name: testAppName_flavor

  ''';

  setUp(() async {
    GetIt.I.registerSingleton<Logger>(Logger.verbose());

    config = Configuration(['-f', 'test'])
      ..pubspecFile = File(pubspecPath)
      ..pubspecFlavorFile = File(pubspecFlavorPath)
      ..backupPubspecFile = File(backupPubspecFlavorPath)
      ..flavor = 'test';

    GetIt.I.registerSingleton<Configuration>(config);

    await Directory(tempFolderPath).create(recursive: true);
    testClass = TestClass();
  });

  tearDown(() async {
    GetIt.I.reset();

    if (await Directory(tempFolderPath).exists()) {
      await Directory(tempFolderPath).delete(recursive: true);
    }
  });

  group('config check:', () {
    test('should return false if help is passed', () async {
      final config = Configuration(['-h']);
      config.getConfigValues();
      final bool result = await config.validateConfigValues();

      expect(result, false);
    });

    test('should return false if flavor is not passed', () async {
      final config = Configuration([]);
      config.getConfigValues();
      final bool result = await config.validateConfigValues();

      expect(result, false);
    });

    test('check the yaml files', () async {
      expect(config.pubspecFile.path, pubspecPath);
      expect(config.pubspecFlavorFile.path, pubspecFlavorPath);

      await File(pubspecPath).writeAsString(yamlContent);
      await File(pubspecFlavorPath).writeAsString(flavorYamlContent);

      expect(config.pubspecFile.existsSync(), true);
      expect(config.pubspecFlavorFile.existsSync(), true);
    });

    test('check if yaml(s) are same or not', () async {
      await File(pubspecPath).writeAsString(yamlContent);
      await File(pubspecFlavorPath).writeAsString(flavorYamlContent);

      final result = PubspecChecker.checkIfPubspecAlreadyMerged(
        actualPubspec:
            Pubspec.fromMap(loadYaml(config.pubspecFile.readAsStringSync())),
        flavorPubspec: Pubspec.fromMap(
            loadYaml(config.pubspecFlavorFile.readAsStringSync())),
      );

      expect(result, false);

      const content = '''

name: pubm

  ''';

      await File(pubspecFlavorPath).writeAsString(content);
      final result1 = PubspecChecker.checkIfPubspecAlreadyMerged(
        actualPubspec:
            Pubspec.fromMap(loadYaml(config.pubspecFile.readAsStringSync())),
        flavorPubspec: Pubspec.fromMap(
            loadYaml(config.pubspecFlavorFile.readAsStringSync())),
      );

      expect(result1, true);
    });

    test('flavor yaml with existing dependency', () async {
      const content2 = '''

name: pubm

dependencies:
  path_test2: 
   path: abc/xyz/2

  ''';
      await File(pubspecPath).writeAsString(yamlContent);
      await File(pubspecFlavorPath).writeAsString(content2);
      final result2 = PubspecChecker.checkIfPubspecAlreadyMerged(
        actualPubspec:
            Pubspec.fromMap(loadYaml(config.pubspecFile.readAsStringSync())),
        flavorPubspec: Pubspec.fromMap(
            loadYaml(config.pubspecFlavorFile.readAsStringSync())),
      );

      expect(result2, true);
    });

    test('flavor yaml with same fonts', () async {
      const content2 = '''

name: pubm

dependencies:
  path_test2: 
   path: abc/xyz/2

flutter:
  fonts:
    - family: test
      fonts:
        - asset: a/a/700.ttf
          weight: 700
        - asset: a/a/600.ttf
          weight: 600
        - asset: a/a/500.ttf
          weight: 500
        - asset: a/a/400.ttf
          weight: 400
    - family: test2
      fonts:
        - asset: a/b/700.ttf
          weight: 700
        - asset: a/b/600.ttf
          weight: 600
        - asset: a/b/500.ttf
          weight: 500
        - asset: a/b/400.ttf
          weight: 400

  ''';
      await File(pubspecPath).writeAsString(yamlContent);
      await File(pubspecFlavorPath).writeAsString(content2);
      final result2 = PubspecChecker.checkIfPubspecAlreadyMerged(
        actualPubspec:
            Pubspec.fromMap(loadYaml(config.pubspecFile.readAsStringSync())),
        flavorPubspec: Pubspec.fromMap(
            loadYaml(config.pubspecFlavorFile.readAsStringSync())),
      );

      expect(result2, true);
    });

    test('flavor yaml with new fonts', () async {
      const content2 = '''

name: pubm

dependencies:
  path_test2: 
   path: abc/xyz/2

flutter:
  fonts:
    - family: test
      fonts:
        - asset: b/a/700.ttf
          weight: 700
        - asset: b/a/600.ttf
          weight: 600
        - asset: b/a/500.ttf
          weight: 500
        - asset: b/a/400.ttf
          weight: 400
    - family: test2
      fonts:
        - asset: b/b/700.ttf
          weight: 700
        - asset: b/b/600.ttf
          weight: 600
        - asset: b/b/500.ttf
          weight: 500
        - asset: b/b/400.ttf
          weight: 400

  ''';
      await File(pubspecPath).writeAsString(yamlContent);
      await File(pubspecFlavorPath).writeAsString(content2);
      final result2 = PubspecChecker.checkIfPubspecAlreadyMerged(
        actualPubspec:
            Pubspec.fromMap(loadYaml(config.pubspecFile.readAsStringSync())),
        flavorPubspec: Pubspec.fromMap(
            loadYaml(config.pubspecFlavorFile.readAsStringSync())),
      );

      expect(result2, false);
    });

    test('merge flavor pubspec to pubspec', () async {
      const content2 = '''

name: pubm_merge
version: 0.0.1

dependencies:
  path_test2: 
   path: abc/def/2
  a: 1.0.0
  b: 
    git:
      url: git://github.com/flutter/packages.git
      ref: 1.0.0
  c: 
   sdk: flutter
  e:
    hosted: https://some-package-server.com
    version: ^1.0.0
  f:
    hosted: 
      name: some-package
      url: https://some-package-server.com
    version: ^1.0.0

flutter:
  fonts:
    - family: test
      fonts:
        - asset: b/a/700.ttf
          weight: 700
        - asset: b/a/600.ttf
          weight: 600
        - asset: b/a/500.ttf
          weight: 500
        - asset: b/a/400.ttf
          weight: 400
    - family: test2
      fonts:
        - asset: b/b/700.ttf
          weight: 700
        - asset: b/b/600.ttf
          weight: 600
        - asset: b/b/500.ttf
          weight: 500
        - asset: b/b/400.ttf
          weight: 400
        - asset: b/b/300.ttf
          weight: 300

  ''';
      await File(pubspecPath).writeAsString(yamlContent);
      await File(pubspecFlavorPath).writeAsString(content2);
      await testClass.mergePubspec();
      final result2 = PubspecChecker.checkIfPubspecAlreadyMerged(
        actualPubspec:
            Pubspec.fromMap(loadYaml(config.pubspecFile.readAsStringSync())),
        flavorPubspec: Pubspec.fromMap(
            loadYaml(config.pubspecFlavorFile.readAsStringSync())),
      );

      expect(result2, true);
    });
  });
}

class TestClass with PubspecManager {
  @override
  Configuration get config => GetIt.I<Configuration>();

  @override
  Logger get logger => GetIt.I<Logger>();
}
