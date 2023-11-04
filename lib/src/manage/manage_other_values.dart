import 'dart:convert';

import 'package:cli_util/cli_logging.dart';
import 'package:collection/collection.dart';
import 'package:pubm/models/pubspec.dart';

/// Check and update the other values in the pubspec.yaml file.
void checkAndUpdateOtherValues(
  Pubspec flavorPubspec,
  Pubspec actualPubspec,
  Map<String, dynamic> finalMap,
  Logger logger,
) {
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
}
