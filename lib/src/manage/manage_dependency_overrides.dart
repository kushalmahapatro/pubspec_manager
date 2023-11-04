import 'package:cli_util/cli_logging.dart';
import 'package:pubm/constants.dart';
import 'package:pubm/models/pubspec.dart';
import 'package:pubm/src/helpers/pubspec_checker.dart';

/// Check and update the dependency_overrides
void checkAndUpdateDependencyOverrides(
  Pubspec actualPubspec,
  Pubspec flavorPubspec,
  Map<String, dynamic> finalMap,
  Map<String, dynamic> map,
  Logger logger,
) {
  var dependencyOverrideCheck = PubspecChecker.checkDependencyOverride(
    actualPubspec,
    flavorPubspec,
    checkAll: true,
  );

  if (!dependencyOverrideCheck.hasMatch) {
    if (dependencyOverrideCheck.update.isNotEmpty) {
      for (var element in dependencyOverrideCheck.update) {
        logger.trace('Updating dependency_override $element');
      }
    }

    if (dependencyOverrideCheck.addition.isNotEmpty) {
      for (var element in dependencyOverrideCheck.addition) {
        logger.trace('Adding dependency_override $element');
      }
    }

    finalMap[dependencyOverrides] = <String, dynamic>{
      if (finalMap[dependencyOverrides] != null)
        ...finalMap[dependencyOverrides],
      if (map[dependencyOverrides] != null) ...map[dependencyOverrides],
    };
  }
}
