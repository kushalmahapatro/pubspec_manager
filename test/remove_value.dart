import 'dart:io';

import 'package:pubm/constants.dart';
import 'package:pubm/models/pubspec.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import 'pubm_test.dart';

void removeNameFromPubspec(String yamlContent) async {
  const content2 = '''
  remove:
    name: pubm_new
    ''';
  final actualPubspecFile = await File(pubspecPath).writeAsString(yamlContent);
  final flavorPubspecFile =
      await File(pubspecFlavorPath).writeAsString(content2);
  await testClass.mergePubspec();

  final dynamic yamlMap = loadYaml(actualPubspecFile.readAsStringSync());
  final dynamic yamlMap1 = loadYaml(flavorPubspecFile.readAsStringSync());
  expect(yamlMap[name] == yamlMap1[name], false);
}

void removeDependencyFromPubspec(String yamlContent) async {
  const content2 = '''
  remove:
    dependencies:
      cupertino_icons: ^1.0.2
      git_test2:
      path_test:
    
    dev_dependencies:
      test:
      flutter_driver:
      git_test_dev:
    
    dependency_overrides:
      git_test_override:
    ''';
  final actualPubspecFile = await File(pubspecPath).writeAsString(yamlContent);
  await File(pubspecFlavorPath).writeAsString(content2);
  await testClass.mergePubspec();

  final dynamic yamlMap = loadYaml(actualPubspecFile.readAsStringSync());

  expect(((yamlMap[devDependencies] ?? {}) as Map).containsKey('git_test2'),
      false);
  expect(yamlMap[dependencies]?['git_test2'], null);

  expect(((yamlMap[devDependencies] ?? {}) as Map).containsKey('git_test2'),
      false);
  expect(yamlMap[dependencies]?['git_test2'], null);

  expect(((yamlMap[devDependencies] ?? {}) as Map).containsKey('path_test'),
      false);
  expect(yamlMap[dependencies]?['path_test'], null);

  expect(((yamlMap[devDependencies] ?? {}) as Map).containsKey('test'), false);
  expect(yamlMap[devDependencies]?['test'], null);

  expect(
      ((yamlMap[devDependencies] ?? {}) as Map).containsKey('flutter_driver'),
      false);
  expect(yamlMap[devDependencies]?['flutter_driver'], null);

  expect(((yamlMap[devDependencies] ?? {}) as Map).containsKey('git_test_dev'),
      false);
  expect(yamlMap[devDependencies]?['git_test_dev'], null);

  expect(
      ((yamlMap[dependencyOverrides] ?? {}) as Map)
          .containsKey('git_test_override'),
      false);
  expect(yamlMap[dependencyOverrides]?['git_test_override'], null);
}

void removeFlutterValuesFromPubspec(String yamlContent) async {
  const content2 = '''
  remove:
    flutter:
      fonts:
        - family: test
      assets:
        - assets/my_icon.png
    ''';
  final actualPubspecFile = await File(pubspecPath).writeAsString(yamlContent);
  await File(pubspecFlavorPath).writeAsString(content2);
  await testClass.mergePubspec();
  final dynamic yamlMap = loadYaml(actualPubspecFile.readAsStringSync());

  final finalPubspec = Pubspec.fromMap(yamlMap);

  expect(
    finalPubspec.flutter?.fonts
        ?.indexWhere((element) => element.family == 'test'),
    -1,
  );

  expect(finalPubspec.flutter?.assets?.contains('assets/my_icon.png') ?? false,
      false);
}

void removeOtherValuesFromPubspec(String yamlContent) async {
  const content2 = '''
  remove:
    msix_config:
    ''';
  final actualPubspecFile = await File(pubspecPath).writeAsString(yamlContent);
  await File(pubspecFlavorPath).writeAsString(content2);
  await testClass.mergePubspec();
  final dynamic yamlMap = loadYaml(actualPubspecFile.readAsStringSync());

  final finalPubspec = Pubspec.fromMap(yamlMap);
  expect(finalPubspec.others?.containsKey('msix_config:') ?? false, false);
}
