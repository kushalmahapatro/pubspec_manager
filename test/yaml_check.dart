import 'dart:io';

import 'package:pubm/models/pubspec.dart';
import 'package:pubm/src/configuration.dart';
import 'package:pubm/src/helpers/pubspec_checker.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import 'pubm_test.dart';
import 'remove_value.dart';

class YamlTest {
  const YamlTest(this.yamlContent, this.flavorYamlContent, this.config);

  final Configuration config;
  final String yamlContent;
  final String flavorYamlContent;

  void checkSameYaml() async {
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
  }

  void checkExistingDependencies() async {
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
  }

  void sameFontsCheck() async {
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
  }

  void otherDependenciesCheck() async {
    const content2 = '''
    msix_config:
      display_name: Flutter App
      publisher_display_name: Company Name
      identity_name: company.suite.flutterapp
      msix_version: 1.0.0.0
      logo_path: C:\\path\\to\\logo.png
      capabilities: internetClient, location, microphone, webcam
    
    flutter_launcher_icons:
      android: "launcher_icon"
      ios: true
      image_path: "assets/icon/icon.png"
      min_sdk_android: 21 # android min sdk min:16, default 21
      web:
        generate: true
        image_path: "path/to/image.png"
        background_color: "#hexcode"
        theme_color: "#hexcode"
      windows:
        generate: true
        image_path: "path/to/image.png"
        icon_size: 48 # min:48, max:256, default: 48
      macos:
        generate: true
        image_path: "path/to/image.png"
      ''';
    await File(pubspecPath).writeAsString(yamlContent);
    await File(pubspecFlavorPath).writeAsString(content2);
    await testClass.mergePubspec();
    final result = PubspecChecker.checkIfPubspecAlreadyMerged(
      actualPubspec: Pubspec.fromMap(
        loadYaml(config.pubspecFile.readAsStringSync()),
      ),
      flavorPubspec: Pubspec.fromMap(
        loadYaml(config.pubspecFlavorFile.readAsStringSync()),
      ),
    );

    expect(true, result);
  }

  void removeName() => removeNameFromPubspec(yamlContent);

  void removeDependency() => removeDependencyFromPubspec(yamlContent);
  void removeFlutterValues() => removeFlutterValuesFromPubspec(yamlContent);
  void removeOtherValues() => removeOtherValuesFromPubspec(yamlContent);
}
