import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pubm/models/pubspec.dart';
import 'package:pubm/src/configuration.dart';
import 'package:pubm/src/helpers/pubspec_checker.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import 'helper.dart';
import 'mock_pubspec_manager.dart';
import 'test_constants.dart';
import 'yaml_check.dart';

const String flavor = 'test';
var tempFolderPath = p.join('test', 'configuration_temp');
var pubspecPath = p.join(tempFolderPath, 'pubspec.yaml');
var pubspecFlavorPath = p.join(tempFolderPath, 'pubspec_$flavor.yaml');
var backupPubspecFlavorPath = p.join(tempFolderPath, 'backup_pubspec.yaml');
late Configuration config;
late MockPubspecManager testClass;
late YamlTest yamlTest;

void main() {
  const flavorYamlContent = '''
    name: testAppName_flavor
    ''';

  setUp(() async {
    config = await testSetUp();
    testClass = MockPubspecManager();
    yamlTest = YamlTest(
      yamlContent,
      flavorYamlContent,
      config,
    );
  });

  tearDown(() => tearDownSetup());

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

    test(
      'Check if yaml are same or not',
      () => yamlTest.checkSameYaml(),
    );

    test(
      'flavor yaml with existing dependency',
      () => yamlTest.checkExistingDependencies(),
    );

    test(
      'flavor yaml with same fonts',
      () => yamlTest.sameFontsCheck(),
    );

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

    test('merge flavor pubspec to pubspec with git dependency with url',
        () async {
      const content2 = '''
        dependencies:
          b: 
            git:
              url: git://github.com/flutter/packages.git
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

    test(
      'merge flavor pubspec to pubspec with other dependencies',
      () => yamlTest.otherDependenciesCheck(),
    );

    test(
      'remove name',
      () => yamlTest.removeName(),
    );

    test(
      'remove dependencies',
      () => yamlTest.removeDependency(),
    );

    test(
      'remove flutter values',
      () => yamlTest.removeFlutterValues(),
    );

    test(
      'remove other values',
      () => yamlTest.removeOtherValues(),
    );
  });
}
