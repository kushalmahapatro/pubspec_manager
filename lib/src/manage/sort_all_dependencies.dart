import 'dart:collection';

import 'package:cli_util/cli_logging.dart';
import 'package:pubm/constants.dart';

/// Sort all the dependencies (dependencies, dev_dependencies, dependency_overrides)
void sortAllDependencies(
  Map<String, dynamic> finalMap,
  Logger logger, {
  bool isPubspecOverrides = false,
}) {
  if (finalMap.containsKey(dependencies)) {
    logger.trace(
      'Sorting $dependencies ${isPubspecOverrides ? 'in pubspec_overrides' : 'in pubspec.yaml'}',
    );

    var sortedKeys = finalMap[dependencies].keys.toList(growable: false)
      ..sort((k1, k2) => k1.toString().compareTo(k2.toString()));
    LinkedHashMap sortedMap = LinkedHashMap.fromIterable(sortedKeys,
        key: (k) => k, value: (k) => finalMap[dependencies][k]);
    finalMap[dependencies] = sortedMap;
  }

  if (finalMap.containsKey(devDependencies)) {
    logger.trace('Sorting $devDependencies');
    var sortedDDKeys = finalMap[devDependencies].keys.toList(growable: false)
      ..sort((k1, k2) => k1.toString().compareTo(k2.toString()));
    LinkedHashMap sortedDDMap = LinkedHashMap.fromIterable(sortedDDKeys,
        key: (k) => k, value: (k) => finalMap[devDependencies][k]);
    finalMap[devDependencies] = sortedDDMap;
  }

  if (finalMap.containsKey(dependencyOverrides)) {
    logger.trace('Sorting $dependencyOverrides');
    var sortedDOKeys = finalMap[dependencyOverrides]
        .keys
        .toList(growable: false)
      ..sort((k1, k2) => k1.toString().compareTo(k2.toString()));
    LinkedHashMap sortedDOMap = LinkedHashMap.fromIterable(sortedDOKeys,
        key: (k) => k, value: (k) => finalMap[dependencyOverrides][k]);
    finalMap[dependencyOverrides] = sortedDOMap;
  }
}
