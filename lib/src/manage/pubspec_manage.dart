import 'package:cli_util/cli_logging.dart';
import 'package:pubm/constants.dart';
import 'package:pubm/models/pubspec.dart';
import 'package:pubm/src/configuration.dart';
import 'package:pubm/src/extensions.dart';
import 'package:pubm/src/helpers/pubspec_checker.dart';
import 'package:pubm/src/manage/manage_dependencies.dart';
import 'package:pubm/src/manage/manage_dependency_overrides.dart';
import 'package:pubm/src/manage/manage_dev_dependencies.dart';
import 'package:pubm/src/manage/manage_other_values.dart';
import 'package:pubm/src/manage/remove_values.dart';
import 'package:pubm/src/manage/sort_all_dependencies.dart';
import 'package:pubm/src/manage/update_actuap_pubspec.dart';
import 'package:yaml/yaml.dart';

import 'manage_flutter_values.dart';

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

    if (checkIfItsOnlyRemove(yamlMap)) {
      final Map<String, dynamic>? finalMap = await removeValuesFromPubspec(
        logger: logger,
        config: config,
      );
      if (finalMap != null) {
        /// Sort all the dependencies (dependencies, dev_dependencies, dependency_overrides)
        sortAllDependencies(
          finalMap,
          logger,
        );

        /// Update the actual pubspec.yaml file
        await updateActualPubspec(
          finalMap,
          nameChanged,
          Pubspec.fromMap(actualYamlMap),
          Pubspec.fromMap(yamlMap),
          config,
          logger,
        );
        return;
      }
    }

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
    Map<String, dynamic> finalMap = actualPubspec.toMap();
    final Map<String, dynamic> map = flavorPubspec.toMap();

    if (!PubspecChecker.checkName(actualPubspec, flavorPubspec)) {
      logger.trace('Updating $name from ${actualPubspec.name} to '
          '${flavorPubspec.name}');
      nameChanged = true;
      finalMap[name] = flavorPubspec.name;
    }

    if (!PubspecChecker.checkDescription(actualPubspec, flavorPubspec)) {
      logger.trace('Updating $description from ${actualPubspec.description} to '
          '${flavorPubspec.description}');
      finalMap[description] = flavorPubspec.description;
    }

    if (!PubspecChecker.checkVersion(actualPubspec, flavorPubspec)) {
      logger.trace('Updating $version from ${actualPubspec.version} to '
          '${flavorPubspec.version}');
      finalMap[version] = flavorPubspec.version;
    }

    if (!PubspecChecker.checkHomepage(actualPubspec, flavorPubspec)) {
      logger.trace('Updating $homepage from ${actualPubspec.homepage} to '
          '${flavorPubspec.homepage}');
      finalMap[homepage] = flavorPubspec.homepage;
    }

    if (!PubspecChecker.checkRepository(actualPubspec, flavorPubspec)) {
      logger.trace('Updating $repository from ${actualPubspec.repository} to '
          '${flavorPubspec.repository}');
      finalMap[repository] = flavorPubspec.repository;
    }

    if (!PubspecChecker.checkIssueTracker(actualPubspec, flavorPubspec)) {
      logger
          .trace('Updating $issueTracker from ${actualPubspec.issueTracker} to '
              '${flavorPubspec.issueTracker}');
      finalMap[issueTracker] = flavorPubspec.issueTracker;
    }

    if (!PubspecChecker.checkDocumentation(actualPubspec, flavorPubspec)) {
      logger.trace(
          'Updating $documentation from ${actualPubspec.documentation} to '
          '${flavorPubspec.documentation}');
      finalMap[documentation] = flavorPubspec.documentation;
    }

    if (!PubspecChecker.checkPublishTo(actualPubspec, flavorPubspec)) {
      logger.trace('Updating $publishTo from ${actualPubspec.publishTo} to '
          '${flavorPubspec.publishTo}');
      finalMap[publishTo] = flavorPubspec.publishTo;
    }

    if (!PubspecChecker.checkEnvironment(actualPubspec, flavorPubspec)) {
      logger.trace('Updating $environment from ${actualPubspec.environment} to '
          '${flavorPubspec.environment}');
      final env = actualPubspec.environment?.toMap() ?? {};

      env.addAll(flavorPubspec.environment!.toMap());
      finalMap[environment] = env;
    }

    /// Check and update the dependencies
    checkAndUpdateDependencies(
      actualPubspec,
      flavorPubspec,
      finalMap,
      map,
      logger,
    );

    /// Check and update the dev_dependencies
    checkAndUpdateDevDependencies(
      actualPubspec,
      flavorPubspec,
      finalMap,
      map,
      logger,
    );

    /// Check and update the dependency_overrides
    checkAndUpdateDependencyOverrides(
      actualPubspec,
      flavorPubspec,
      finalMap,
      map,
      logger,
    );

    /// Other values which are not checked and might be from other plugins
    checkAndUpdateOtherValues(
      flavorPubspec,
      actualPubspec,
      finalMap,
      logger,
    );

    /// Check and update the flutter related values
    checkAndUpdateFlutterRelatedValues(
      flavorPubspec,
      actualPubspec,
      finalMap,
      logger,
    );

    /// Get the final map after removing the values mentioned in the pubspec_flavor.yaml
    final Map<String, dynamic>? finalMapAfterRemoving =
        await removeValuesFromPubspec(
      logger: logger,
      config: config,
    );

    if (finalMapAfterRemoving != null) {
      finalMap = finalMapAfterRemoving;
    }

    /// Sort all the dependencies (dependencies, dev_dependencies, dependency_overrides)
    sortAllDependencies(
      finalMap,
      logger,
    );

    /// Update the actual pubspec.yaml file
    await updateActualPubspec(
      finalMap,
      nameChanged,
      actualPubspec,
      flavorPubspec,
      config,
      logger,
    );
  }
}
