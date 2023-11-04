import 'package:cli_util/cli_logging.dart';
import 'package:pubm/constants.dart';
import 'package:pubm/models/pubspec.dart';
import 'package:pubm/src/helpers/pubspec_checker.dart';

/// Check and update the dev_dependencies
void checkAndUpdateDevDependencies(
  Pubspec actualPubspec,
  Pubspec flavorPubspec,
  Map<String, dynamic> finalMap,
  Map<String, dynamic> map,
  Logger logger,
) {
  var devDependencyCheck = PubspecChecker.checkDevDependencies(
    actualPubspec,
    flavorPubspec,
    checkAll: true,
  );

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

    /// Combine the dev_dependencies from both pubspec.yaml and pubspec_flavor.yaml files
    finalMap[devDependencies] = <String, dynamic>{
      if (finalMap[devDependencies] != null) ...finalMap[devDependencies],
      if (map[devDependencies] != null) ...map[devDependencies],
    };
  }
}
