import 'package:cli_util/cli_logging.dart';
import 'package:pubm/constants.dart';
import 'package:pubm/models/flutter_data.dart';
import 'package:pubm/models/pubspec.dart';
import 'package:pubm/src/configuration.dart';
import 'package:pubm/src/extensions.dart';
import 'package:yaml/yaml.dart';

typedef RemovedPubspecsMap = ({
  Map<String, dynamic>? pubspecMap,
  Map<String, dynamic>? pubspecOverridesMap
});

/// Check if the pubspec_flavor.yaml file contains remove key
bool checkIfItsOnlyRemove(Map<String, dynamic> data) {
  return data.containsKey("remove") && data.keys.length == 1;
}

bool checkIfItsContainsRemove(Map<String, dynamic> data) {
  return data.containsKey("remove");
}

/// Remove the values mentioned in the remove section of the pubspec_flavor.yaml
Future<RemovedPubspecsMap> removeValuesFromPubspec({
  required Logger logger,
  required Configuration config,
}) async {
  if (!config.pubspecFlavorFile.existsSync()) {
    logger.stderr('File does not exist: ${config.flavor}'.red);

    return (pubspecMap: null, pubspecOverridesMap: null);
  }

  // Read the YAML file
  final String contents = config.pubspecFlavorFile.readAsStringSync();

  // Parse the YAML contents
  final dynamic yamlMap = loadYaml(contents);

  final dynamic actualYamlMap = loadYaml(config.pubspecFile.readAsStringSync());
  final dynamic pubspecOverridesYamlMap =
      config.pubspecOverridesFile.existsSync()
          ? loadYaml(config.pubspecOverridesFile.readAsStringSync())
          : null;

  // Create a Pubspec object
  final Pubspec actualPubspec = Pubspec.fromMap(actualYamlMap);
  final Pubspec flavorPubspec = Pubspec.fromMap(yamlMap[remove]);
  final Pubspec? pubspecOverridesPubspec = pubspecOverridesYamlMap != null
      ? Pubspec.fromMap(pubspecOverridesYamlMap)
      : null;

  // Update the Pubspec object
  final Map<String, dynamic> finalMap = actualPubspec.toMap();
  final Map<String, dynamic> map = flavorPubspec.toMap();
  final Map<String, dynamic>? pubspecOverridesMap =
      pubspecOverridesPubspec?.toMap();

  /// Check if the pubspec_flavor.yaml file contains remove key
  if (yamlMap is! Map ||
      !checkIfItsContainsRemove(yamlMap.cast<String, dynamic>())) {
    logger.stdout(
      'No remove key found in pubspec_${config.flavor}.yaml'.emphasized,
    );

    return (pubspecMap: finalMap, pubspecOverridesMap: pubspecOverridesMap);
  }

  //Remove name if name exists in flavor
  if (map.containsKey(name)) {
    logger.stderr(
        'Cannot remove $name: ${actualPubspec.name} from pubspec, as this will cause the project to break'
            .red);
    logger.stderr('Discarding removal of $name, and continuing ahead');
  }

  ///Remove description if description exists in flavor
  if (map.containsKey(description)) {
    logger.trace('Removing:0-7654` $description');
    finalMap.remove(description);
  }

  ///Remove version if version exists in flavor
  if (map.containsKey(version)) {
    logger.trace('Removing: $version');
    finalMap.remove(version);
  }

  ///Remove homepage if homepage exists in flavor
  if (map.containsKey(homepage)) {
    logger.trace('Removing: $homepage');
    finalMap.remove(homepage);
  }

  ///Remove repository if repository exists in flavor
  if (map.containsKey(repository)) {
    logger.trace('Removing: $repository');
    finalMap.remove(repository);
  }

  ///Remove issueTracker if issueTracker exists in flavor
  if (map.containsKey(issueTracker)) {
    logger.trace('Removing: $issueTracker');
    finalMap.remove(issueTracker);
  }

  ///Remove documentation if documentation exists in flavor
  if (map.containsKey(documentation)) {
    logger.trace('Removing: $documentation');
    finalMap.remove(documentation);
  }

  ///Remove publish_to if publish_to exists in flavor
  if (map.containsKey(publishTo)) {
    logger.trace('Removing: $publishTo');
    finalMap.remove(publishTo);
  }

  ///Remove environment if environment exists in flavor
  if (map.containsKey(environment)) {
    logger.trace('Removing: $environment');
    finalMap.remove(environment);
  }

  ///Check if dependencies key exists if so then
  ///Loop through all the dependencies and remove it.
  if (map.containsKey(dependencies)) {
    map[dependencies]?.forEach((key, value) {
      if (finalMap[dependencies]?.containsKey(key) ?? false) {
        logger.trace('Removing dependency: $key');
        finalMap[dependencies].remove(key);
      }
    });
    if (finalMap[dependencies] != null &&
        (finalMap[dependencies] as Map).isEmpty) {
      finalMap.remove(dependencies);
    }
  }

  ///Check if dev_dependencies key exists if so then
  ///Loop through all the dev_dependencies and remove it.
  if (map.containsKey(devDependencies)) {
    map[devDependencies]?.forEach((key, value) {
      if (finalMap[devDependencies]?.containsKey(key) ?? false) {
        logger.trace('Deleting dev_dependency: $key');
        finalMap[devDependencies].remove(key);
      }
    });
    if (finalMap[devDependencies] != null &&
        (finalMap[devDependencies] as Map).isEmpty) {
      finalMap.remove(devDependencies);
    }
  }

  ///Check if dependency_overrides key exists if so then
  ///Loop through all the dependency_overrides and remove it.
  if (map.containsKey(dependencyOverrides)) {
    map[dependencyOverrides]?.forEach((key, value) {
      if (finalMap[dependencyOverrides]?.containsKey(key) ?? false) {
        logger.trace('Deleting dependency_override: $key');
        finalMap[dependencyOverrides].remove(key);
      }
    });

    if (finalMap[dependencyOverrides] != null &&
        (finalMap[dependencyOverrides] as Map).isEmpty) {
      finalMap.remove(dependencyOverrides);
    }

    /// Removing the keys from pubspec_overrides.yaml
    if (pubspecOverridesMap != null &&
        pubspecOverridesMap[dependencyOverrides] != null) {
      map[dependencyOverrides]?.forEach(
        (key, value) {
          if (pubspecOverridesMap[dependencyOverrides]?.containsKey(key) ??
              false) {
            logger.trace(
                'Deleting dependency_override from pubspec_overrides.yaml: $key');
            pubspecOverridesMap[dependencyOverrides].remove(key);
          }
        },
      );

      if (pubspecOverridesMap[dependencyOverrides] != null &&
          (pubspecOverridesMap[dependencyOverrides] as Map).isEmpty) {
        pubspecOverridesMap.remove(dependencyOverrides);
      }
    }
  }

  /// Other values which are not checked and might be from other plugins
  if (flavorPubspec.others?.isNotEmpty ?? false) {
    logger.trace('Removing others values');

    if (flavorPubspec.others != null) {
      flavorPubspec.others!.forEach((key, value) {
        if (finalMap.containsKey(key)) {
          logger.trace('Removing $key');
          finalMap.remove(key);
        }
      });
    }
  }

  if (flavorPubspec.flutter != null) {
    logger.trace('Removing flutter values');

    final flutterValue = actualPubspec.flutter?.toMap() ?? {};
    final flavorFlutter = flavorPubspec.flutter?.toMap() ?? {};
    if (actualPubspec.flutter != null) {
      if (flavorFlutter.containsKey(useMaterialDesign)) {
        logger.trace('Removing flutter $useMaterialDesign');
        flutterValue.remove(useMaterialDesign);
      }
      if (flavorFlutter.containsKey(generate)) {
        logger.trace('Removing flutter $generate');
        flutterValue.remove(generate);
      }

      if (flavorFlutter.containsKey(assets)) {
        logger.trace('Removing flutter $assets');
        final flavourAssets = flavorPubspec.flutter?.assets ?? [];
        for (var item in flavourAssets) {
          logger.trace('Removing flutter asset $item');
          actualPubspec.flutter?.assets?.remove(item);
        }
        final assetsValue = actualPubspec.flutter?.assets ?? [];
        flutterValue[assets] = assetsValue.toList();
      }

      final finalFonts = actualPubspec.flutter?.fonts?.toList() ?? [];

      for (final Font finalFont in actualPubspec.flutter?.fonts ?? []) {
        for (final Font flavoredFont in flavorPubspec.flutter?.fonts ?? []) {
          if (flavoredFont.family == finalFont.family) {
            logger.trace(
                'Removing flutter font family: ${finalFont.family} and the associated fonts');
            finalFonts.removeWhere(
              (element) => element.family == finalFont.family,
            );
          }
        }
      }

      var fontsValue = <Font>{}..addAll(finalFonts);

      flutterValue[fonts] = fontsValue.toList().map((e) => e.toMap()).toList();

      if (finalFonts.isEmpty) {
        flutterValue.remove(fonts);
      }
    }

    finalMap[flutter] = flutterValue;
    if (flutterValue.isEmpty) {
      finalMap.remove(flutter);
    }
  }

  return (pubspecMap: finalMap, pubspecOverridesMap: pubspecOverridesMap);
}
