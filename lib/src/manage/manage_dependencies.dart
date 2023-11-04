import 'package:cli_util/cli_logging.dart';
import 'package:pubm/constants.dart';
import 'package:pubm/models/pubspec.dart';
import 'package:pubm/src/helpers/pubspec_checker.dart';

/// Check and update the dependencies
void checkAndUpdateDependencies(
  Pubspec actualPubspec,
  Pubspec flavorPubspec,
  Map<String, dynamic> finalMap,
  Map<String, dynamic> map,
  Logger logger,
) {
  var dependencyCheck = PubspecChecker.checkDependencies(
    actualPubspec,
    flavorPubspec,
    checkAll: true,
  );

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

    /// Combine the dependencies from both pubspec.yaml and pubspec_flavor.yaml files
    finalMap[dependencies] = <String, dynamic>{
      if (finalMap[dependencies] != null) ...finalMap[dependencies],
      if (map[dependencies] != null) ...map[dependencies],
    };
  }
}
