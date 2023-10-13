import 'dart:collection';
import 'dart:convert';

import 'package:cli_util/cli_logging.dart';
import 'package:collection/collection.dart';
import 'package:json2yaml/json2yaml.dart';
import 'package:pubm/constants.dart';
import 'package:pubm/models/flutter_data.dart';
import 'package:pubm/models/pubspec.dart';
import 'package:pubm/src/configuration.dart';
import 'package:pubm/src/extensions.dart';
import 'package:pubm/src/flutter_build.dart';
import 'package:pubm/src/helpers/pubspec_checker.dart';
import 'package:yaml/yaml.dart';

mixin PubspecManager {
  Logger get logger;

  Configuration get config;

  Future<void> mergePubspec() async {
    bool nameChanged = false;
    if (!config.pubspecFlavorFile.existsSync()) {
      logger.stderr('File does not exist: ${config.flavor}'.red);
      return;
    }

    // Read the YAML file
    final String contents = config.pubspecFlavorFile.readAsStringSync();

    // Parse the YAML contents
    final dynamic yamlMap = loadYaml(contents);
    final dynamic actualYamlMap =
        loadYaml(config.pubspecFile.readAsStringSync());

    // Create a Pubspec object
    final Pubspec actualPubspec = Pubspec.fromMap(actualYamlMap);
    final Pubspec flavorPubspec = Pubspec.fromMap(yamlMap);

    final bool alreadyMerged = PubspecChecker.checkIfPubspecAlreadyMerged(
      actualPubspec: actualPubspec,
      flavorPubspec: flavorPubspec,
    );

    if (alreadyMerged) {
      logger.stdout('Pubspec already merged.'.green);
      return;
    }

    // Update the Pubspec object
    final Map<String, dynamic> finalMap = actualPubspec.toMap();
    final Map<String, dynamic> map = flavorPubspec.toMap();

    if (!PubspecChecker.checkName(actualPubspec, flavorPubspec)) {
      logger.trace('Updating name from ${actualPubspec.name} to '
          '${flavorPubspec.name}');
      nameChanged = true;
      finalMap['name'] = flavorPubspec.name;
    }

    if (!PubspecChecker.checkDescription(actualPubspec, flavorPubspec)) {
      logger.trace('Updating description from ${actualPubspec.description} to '
          '${flavorPubspec.description}');
      finalMap['description'] = flavorPubspec.description;
    }

    if (!PubspecChecker.checkVersion(actualPubspec, flavorPubspec)) {
      logger.trace('Updating version from ${actualPubspec.version} to '
          '${flavorPubspec.version}');
      finalMap['version'] = flavorPubspec.version;
    }

    if (!PubspecChecker.checkHomepage(actualPubspec, flavorPubspec)) {
      logger.trace('Updating homepage from ${actualPubspec.homepage} to '
          '${flavorPubspec.homepage}');
      finalMap['homepage'] = flavorPubspec.homepage;
    }

    if (!PubspecChecker.checkRepository(actualPubspec, flavorPubspec)) {
      logger.trace('Updating repository from ${actualPubspec.repository} to '
          '${flavorPubspec.repository}');
      finalMap['repository'] = flavorPubspec.repository;
    }

    if (!PubspecChecker.checkIssueTracker(actualPubspec, flavorPubspec)) {
      logger
          .trace('Updating issueTracker from ${actualPubspec.issueTracker} to '
              '${flavorPubspec.issueTracker}');
      finalMap['issueTracker'] = flavorPubspec.issueTracker;
    }

    if (!PubspecChecker.checkDocumentation(actualPubspec, flavorPubspec)) {
      logger.trace(
          'Updating documentation from ${actualPubspec.documentation} to '
          '${flavorPubspec.documentation}');
      finalMap['documentation'] = flavorPubspec.documentation;
    }

    if (!PubspecChecker.checkPublishTo(actualPubspec, flavorPubspec)) {
      logger.trace('Updating publishTo from ${actualPubspec.publishTo} to '
          '${flavorPubspec.publishTo}');
      finalMap['publishTo'] = flavorPubspec.publishTo;
    }

    if (!PubspecChecker.checkEnvironment(actualPubspec, flavorPubspec)) {
      logger.trace('Updating environment from ${actualPubspec.environment} to '
          '${flavorPubspec.environment}');
      final env = actualPubspec.environment?.toMap() ?? {};

      env.addAll(flavorPubspec.environment!.toMap());
      finalMap['environment'] = env;
    }

    var dependencyCheck = PubspecChecker.checkDependencies(
        actualPubspec, flavorPubspec,
        checkAll: true);
    if (!dependencyCheck.hasMatch) {
      if (dependencyCheck.update.isNotEmpty) {
        for (var element in dependencyCheck.update) {
          logger.trace('Updating dependency $element');
        }
      }

      if (dependencyCheck.addition.isNotEmpty) {
        for (var element in dependencyCheck.addition) {
          logger.trace('Adding dependency $element');
        }
      }

      finalMap['dependencies'] = <String, dynamic>{
        if (finalMap['dependencies'] != null) ...finalMap['dependencies'],
        if (map['dependencies'] != null) ...map['dependencies'],
      };
    }

    var devDependencyCheck = PubspecChecker.checkDevDependencies(
        actualPubspec, flavorPubspec,
        checkAll: true);

    if (!devDependencyCheck.hasMatch) {
      if (devDependencyCheck.update.isNotEmpty) {
        for (var element in devDependencyCheck.update) {
          logger.trace('Updating dev_dependency $element');
        }
      }

      if (devDependencyCheck.addition.isNotEmpty) {
        for (var element in devDependencyCheck.addition) {
          logger.trace('Adding dev_dependency $element');
        }
      }

      finalMap['dev_dependencies'] = <String, dynamic>{
        if (finalMap['dev_dependencies'] != null)
          ...finalMap['dev_dependencies'],
        if (map['dev_dependencies'] != null) ...map['dev_dependencies'],
      };
    }

    var dependencyOverrideCheck = PubspecChecker.checkDependencyOverride(
        actualPubspec, flavorPubspec,
        checkAll: true);

    if (!dependencyOverrideCheck.hasMatch) {
      if (dependencyOverrideCheck.update.isNotEmpty) {
        for (var element in dependencyOverrideCheck.update) {
          logger.trace('Updating dependency_overrides $element');
        }
      }

      if (dependencyOverrideCheck.addition.isNotEmpty) {
        for (var element in dependencyOverrideCheck.addition) {
          logger.trace('Adding dependency_overrides $element');
        }
      }

      finalMap['dependency_overrides'] = <String, dynamic>{
        if (finalMap['dependency_overrides'] != null)
          ...finalMap['dependency_overrides'],
        if (map['dependency_overrides'] != null) ...map['dependency_overrides'],
      };
    }

    if (finalMap.containsKey('dependencies')) {
      logger.trace('Sorting dependencies');
      var sortedKeys = finalMap['dependencies'].keys.toList(growable: false)
        ..sort((k1, k2) => k1.toString().compareTo(k2.toString()));
      LinkedHashMap sortedMap = LinkedHashMap.fromIterable(sortedKeys,
          key: (k) => k, value: (k) => finalMap['dependencies'][k]);
      finalMap['dependencies'] = sortedMap;
    }

    if (finalMap.containsKey('dev_dependencies')) {
      logger.trace('Sorting dev_dependencies');
      var sortedDDKeys = finalMap['dev_dependencies']
          .keys
          .toList(growable: false)
        ..sort((k1, k2) => k1.toString().compareTo(k2.toString()));
      LinkedHashMap sortedDDMap = LinkedHashMap.fromIterable(sortedDDKeys,
          key: (k) => k, value: (k) => finalMap['dev_dependencies'][k]);
      finalMap['dev_dependencies'] = sortedDDMap;
    }

    if (finalMap.containsKey('dependency_overrides')) {
      logger.trace('Sorting dependency_overrides');
      var sortedDOKeys = finalMap['dependency_overrides']
          .keys
          .toList(growable: false)
        ..sort((k1, k2) => k1.toString().compareTo(k2.toString()));
      LinkedHashMap sortedDOMap = LinkedHashMap.fromIterable(sortedDOKeys,
          key: (k) => k, value: (k) => finalMap['dependency_overrides'][k]);
      finalMap['dependency_overrides'] = sortedDOMap;
    }

    /// Other values which are not checked and might be from other plugins
    if (!DeepCollectionEquality()
        .equals(flavorPubspec.others, actualPubspec.others)) {
      logger.trace('Updating others values');
      Map<String, dynamic> others = {};
      if (actualPubspec.others != null) {
        actualPubspec.others!.forEach((key, value) {
          logger.trace('Updating $key');

          if (value is Map || value is List) {
            others[key] = jsonDecode(jsonEncode(value));
          } else {
            others[key] = value;
          }
        });
      }
      if (flavorPubspec.others != null) {
        flavorPubspec.others!.forEach((key, value) {
          logger.trace('Updating $key');

          if (value is Map || value is List) {
            others[key] = jsonDecode(jsonEncode(value));
          } else {
            others[key] = value;
          }
        });
      }

      finalMap.addAll(others);
    }

    if (flavorPubspec.flutter != null) {
      logger.trace('Updating flutter values');

      final flutter = actualPubspec.flutter?.toMap() ?? {};
      finalMap['flutter'] = flavorPubspec.flutter?.toMap();
      if (actualPubspec.flutter != null) {
        if (actualPubspec.flutter?.usesMaterialDesign !=
            flavorPubspec.flutter?.usesMaterialDesign) {
          logger.trace('Updating uses-material-design from '
              '${actualPubspec.flutter?.usesMaterialDesign} to '
              '${flavorPubspec.flutter?.usesMaterialDesign}');

          flutter['uses-material-design'] =
              flavorPubspec.flutter?.usesMaterialDesign ??
                  actualPubspec.flutter?.usesMaterialDesign;
        }

        if (actualPubspec.flutter?.generate !=
            flavorPubspec.flutter?.generate) {
          logger.trace('Updating generate from '
              '${actualPubspec.flutter?.generate} to '
              '${flavorPubspec.flutter?.generate}');
          flutter['generate'] = flavorPubspec.flutter?.generate ??
              actualPubspec.flutter?.generate;
        }

        final assets = actualPubspec.flutter?.assets ?? [];
        assets.addAll(flavorPubspec.flutter?.assets ?? []);
        flutter['assets'] = assets.toSet();

        final finalFonts = <Font>{};
        for (final Font data in actualPubspec.flutter?.fonts ?? []) {
          finalFonts.add(Font(family: data.family));
        }
        for (final Font data in flavorPubspec.flutter?.fonts ?? []) {
          finalFonts.add(Font(family: data.family));
        }

        var fonts = <Font>{}..addAll(finalFonts);

        for (final data in finalFonts) {
          final actualFont = actualPubspec.flutter?.fonts
              ?.firstWhereOrNull((element) => element.family == data.family);

          final flavorFont = flavorPubspec.flutter?.fonts
              ?.firstWhereOrNull((element) => element.family == data.family);

          if (actualFont != null && flavorFont != null) {
            final map = {};
            map['family'] = actualFont.family;
            final f = <FontsData>{};

            for (final FontsData data in [
              ...actualFont.fonts ?? [],
              ...flavorFont.fonts ?? []
            ]) {
              final d = flavorFont.fonts?.firstWhereOrNull(
                  (element) => element.weight == data.weight);
              if (d != null) {
                f.add(d);
              } else {
                f.add(data);
              }
            }
            map['fonts'] = f.toList().map((e) => e.toMap()).toList();
            fonts.remove(data);
            fonts.add(Font.fromMap(map));
          } else if (actualFont != null && flavorFont == null) {
            fonts.remove(data);
            fonts.add(actualFont);
          } else if (actualFont == null && flavorFont != null) {
            fonts.remove(data);
            fonts.add(flavorFont);
          }

          flutter['fonts'] = fonts.toList().map((e) => e.toMap()).toList();
        }
        finalFonts.clear();
      }
      finalMap['flutter'] = flutter;
    }

    final finalPubspec = Pubspec.fromMap(finalMap);

    /// Convert the `finalMap` to String with pubspec.yaml format
    final String string = json2yaml(
      finalPubspec.toMap(addComments: true),
      yamlStyle: YamlStyle.pubspecYaml,
    );

    /// If any of the value contains # then it will be converted to "#"
    /// ex: hexCode #FFFFFF will be converted to "#FFFFFF"
    String replacedText =
        string.replaceAllMapped(RegExp("#(.*?)(?=\\s|\$)"), (Match m) {
      return '"#${m.group(1)}"';
    });

    /// This will replace the temp added comment string with #
    /// [Constants.comment] -> "Pubspec Manager Comment:" will be replaced with "#" in the final pubspec.yaml
    replacedText = replacedText.replaceAllMapped(
        RegExp("${Constants.comment}\\d+: (.*?)(?=\\s|\$)"), (Match m) {
      return '# ${m.group(1)}';
    });

    /// Save the updated YAML to the file
    logger.trace('Creating a backup of pubspec.yaml to backup_pubspec.yaml');
    config.backupPubspecFile
        .writeAsStringSync(config.pubspecFile.readAsStringSync());
    config.pubspecFile.writeAsStringSync(replacedText);

    logger.stdout('Merging of pubspec.yaml files completed successfully'.green);

    /// Error message when name is changed in the main pubspec.yaml from the flavor pubspec.yaml
    if (nameChanged) {
      logger.stderr(
          'The name is changed from ${actualPubspec.name} to ${flavorPubspec.name} (as the the one mentioned in the pubspec_${config.flavor}.yaml');
      logger.stderr('This would cause errors in the project.');
      logger.stderr(
          'Fix for this would to refactor the places where the package name was used');
      logger.stderr(
          "Refactor: import 'package:${actualPubspec.name}/ to import 'package:${flavorPubspec.name}/ ");
    }

    await FlutterBuild().pubGet();
  }
}
