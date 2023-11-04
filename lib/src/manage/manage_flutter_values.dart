import 'package:cli_util/cli_logging.dart';
import 'package:collection/collection.dart';
import 'package:pubm/constants.dart';
import 'package:pubm/models/flutter_data.dart';
import 'package:pubm/models/pubspec.dart';

/// Check and update the flutter related values
void checkAndUpdateFlutterRelatedValues(
  Pubspec flavorPubspec,
  Pubspec actualPubspec,
  Map<String, dynamic> finalMap,
  Logger logger,
) {
  if (flavorPubspec.flutter != null) {
    logger.trace('Updating $flutter values');

    final flutterValues = actualPubspec.flutter?.toMap() ?? {};
    finalMap[flutter] = flavorPubspec.flutter?.toMap();
    if (actualPubspec.flutter != null) {
      if (actualPubspec.flutter?.usesMaterialDesign !=
          flavorPubspec.flutter?.usesMaterialDesign) {
        logger.trace('Updating $useMaterialDesign from '
            '${actualPubspec.flutter?.usesMaterialDesign} to '
            '${flavorPubspec.flutter?.usesMaterialDesign}');

        flutterValues[useMaterialDesign] =
            flavorPubspec.flutter?.usesMaterialDesign ??
                actualPubspec.flutter?.usesMaterialDesign;
      }

      if (actualPubspec.flutter?.generate != flavorPubspec.flutter?.generate) {
        logger.trace('Updating $generate from '
            '${actualPubspec.flutter?.generate} to '
            '${flavorPubspec.flutter?.generate}');
        flutterValues[generate] =
            flavorPubspec.flutter?.generate ?? actualPubspec.flutter?.generate;
      }

      final assetsValue = actualPubspec.flutter?.assets ?? [];
      assetsValue.addAll(flavorPubspec.flutter?.assets ?? []);
      flutterValues[assets] = assetsValue.toSet();

      final finalFonts = <Font>{};
      for (final Font data in actualPubspec.flutter?.fonts ?? []) {
        finalFonts.add(Font(family: data.family));
      }
      for (final Font data in flavorPubspec.flutter?.fonts ?? []) {
        finalFonts.add(Font(family: data.family));
      }

      var fontsSet = <Font>{}..addAll(finalFonts);

      for (final data in finalFonts) {
        final actualFont = actualPubspec.flutter?.fonts
            ?.firstWhereOrNull((element) => element.family == data.family);

        final flavorFont = flavorPubspec.flutter?.fonts
            ?.firstWhereOrNull((element) => element.family == data.family);

        if (actualFont != null && flavorFont != null) {
          final map = {};
          map[family] = actualFont.family;
          final f = <FontsData>{};

          for (final FontsData data in [
            ...actualFont.fonts ?? [],
            ...flavorFont.fonts ?? []
          ]) {
            final d = flavorFont.fonts
                ?.firstWhereOrNull((element) => element.weight == data.weight);
            if (d != null) {
              f.add(d);
            } else {
              f.add(data);
            }
          }
          map[fonts] = f.toList().map((e) => e.toMap()).toList();
          fontsSet.remove(data);

          logger.trace(
              'Updating $fonts from ${actualFont.family} to ${flavorFont.family} and associated fonts');
          fontsSet.add(Font.fromMap(map));
        } else if (actualFont != null && flavorFont == null) {
          fontsSet.remove(data);
          fontsSet.add(actualFont);
        } else if (actualFont == null && flavorFont != null) {
          fontsSet.remove(data);

          logger
              .trace('Adding $fonts ${flavorFont.family} and associated fonts');
          fontsSet.add(flavorFont);
        }

        flutterValues[fonts] = fontsSet.toList().map((e) => e.toMap()).toList();
      }
      finalFonts.clear();
    }
    finalMap[flutter] = flutterValues;
  }
}
