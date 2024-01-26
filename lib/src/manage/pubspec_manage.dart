import 'package:cli_util/cli_logging.dart';
import 'package:collection/collection.dart';
import 'package:pubm/constants.dart';
import 'package:pubm/models/dependencies.dart';
import 'package:pubm/models/pubspec.dart';
import 'package:pubm/src/configuration.dart';
import 'package:pubm/src/extensions.dart';
import 'package:pubm/src/flutter_build.dart';
import 'package:pubm/src/helpers/pubspec_checker.dart';
import 'package:pubm/src/manage/manage_dependencies.dart';
import 'package:pubm/src/manage/manage_dependency_overrides.dart';
import 'package:pubm/src/manage/manage_dev_dependencies.dart';
import 'package:pubm/src/manage/manage_other_values.dart';
import 'package:pubm/src/manage/remove_values.dart';
import 'package:pubm/src/manage/sort_all_dependencies.dart';
import 'package:pubm/src/manage/update_actual_pubspec.dart';
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
    final dynamic pubspecOverridesYamlMap =
        config.pubspecOverridesFile.existsSync()
            ? loadYaml(config.pubspecOverridesFile.readAsStringSync())
            : null;

    if (checkIfItsOnlyRemove(Pubspec.fromMap(yamlMap).toMap())) {
      final RemovedPubspecsMap mapsAfterRemoving =
          await removeValuesFromPubspec(
        logger: logger,
        config: config,
      );

      /// Sort all the dependencies (dependencies, dev_dependencies, dependency_overrides)
      sortAllDependencies(
        mapsAfterRemoving.pubspecMap ?? {},
        logger,
      );

      sortAllDependencies(
        mapsAfterRemoving.pubspecOverridesMap ?? {},
        logger,
      );

      /// Update the actual pubspec.yaml file
      await updateActualPubspecFiles(
        finalPubspecMap: mapsAfterRemoving.pubspecMap ?? {},
        actualPubspec: Pubspec.fromMap(actualYamlMap),
        flavorPubspec: Pubspec.fromMap(yamlMap),
        nameChanged: nameChanged,
        config: config,
        logger: logger,
      );

      /// Update the actual pubspec.yaml file
      if (pubspecOverridesYamlMap != null) {
        await updateActualPubspecFiles(
          finalPubspecMap: mapsAfterRemoving.pubspecOverridesMap ?? {},
          actualPubspec: Pubspec.fromMap(pubspecOverridesYamlMap),
          flavorPubspec: Pubspec.fromMap(yamlMap),
          config: config,
          logger: logger,
          isForPubspecOverrides: true,
        );
      }

      await _performPubGet();

      return;
    }

    // Create a Pubspec object
    final Pubspec actualPubspec = Pubspec.fromMap(actualYamlMap);
    final Pubspec? pubspecOverrides = pubspecOverridesYamlMap == null
        ? null
        : Pubspec.fromMap(pubspecOverridesYamlMap);
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
    Map<String, dynamic>? finalMapPubspecOverrides = pubspecOverrides?.toMap();
    final Map<String, dynamic> flavorMap = flavorPubspec.toMap();

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
      flavorMap,
      logger,
    );

    /// Check and update the dev_dependencies
    checkAndUpdateDevDependencies(
      actualPubspec,
      flavorPubspec,
      finalMap,
      flavorMap,
      logger,
    );

    /// Check and update the dependency_overrides
    if (actualPubspec.dependenciesOverride != null) {
      checkAndUpdateDependencyOverrides(
        actualPubspec,
        flavorPubspec,
        finalMap,
        flavorMap,
        logger,
      );
    }

    /// Check and update the dependency_overrides in pubspec_overrides.yaml
    if (finalMapPubspecOverrides != null && pubspecOverrides != null) {
      checkAndUpdateDependencyOverrides(
        pubspecOverrides,
        flavorPubspec,
        finalMapPubspecOverrides,
        flavorMap,
        logger,
        isPubspecOverrides: true,
      );
    }

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
    if (checkIfItsContainsRemove(flavorMap)) {
      final RemovedPubspecsMap finalMapAfterRemoving =
          await removeValuesFromPubspec(
        logger: logger,
        config: config,
      );

      if (finalMapAfterRemoving.pubspecMap != null) {
        finalMap = finalMapAfterRemoving.pubspecMap ?? {};
      }

      if (finalMapAfterRemoving.pubspecOverridesMap != null) {
        finalMapPubspecOverrides =
            finalMapAfterRemoving.pubspecOverridesMap ?? {};
      }
    }

    /// Sort all the dependencies (dependencies, dev_dependencies, dependency_overrides)
    sortAllDependencies(
      finalMap,
      logger,
    );

    /// Sort all the  dependency_overrides in pubspec_overrides.yaml
    sortAllDependencies(
      finalMapPubspecOverrides ?? {},
      logger,
      isPubspecOverrides: true,
    );

    /// Update the actual pubspec.yaml file
    await updateActualPubspecFiles(
      finalPubspecMap: finalMap,
      actualPubspec: actualPubspec,
      flavorPubspec: flavorPubspec,
      nameChanged: nameChanged,
      config: config,
      logger: logger,
    );

    if (finalMapPubspecOverrides != null && pubspecOverrides != null) {
      await updateActualPubspecFiles(
        finalPubspecMap: finalMapPubspecOverrides,
        actualPubspec: pubspecOverrides,
        flavorPubspec: flavorPubspec,
        config: config,
        logger: logger,
        isForPubspecOverrides: true,
      );
    }

    await _performPubGet();
  }

  Future<void> _performPubGet() async {
    if (config.pubGetAfterDone) {
      final Pubspec actualPubspec =
          Pubspec.fromMap(loadYaml(config.pubspecFile.readAsStringSync()));
      final SdkDependency? hasFlutterSdkDependency =
          (actualPubspec.dependencies?.sdkDependencies ?? [])
              .firstWhereOrNull((element) => element.name == 'flutter');

      await FlutterBuild()
          .pubGet(isFlutterProject: hasFlutterSdkDependency != null);
    }
  }
}
