import 'package:cli_util/cli_logging.dart';
import 'package:json2yaml/json2yaml.dart';
import 'package:pubm/constants.dart';
import 'package:pubm/models/pubspec.dart';
import 'package:pubm/src/configuration.dart';
import 'package:pubm/src/extensions.dart';
import 'package:pubm/src/flutter_build.dart';

Future<void> updateActualPubspec(
  Map<String, dynamic> finalMap,
  bool nameChanged,
  Pubspec actualPubspec,
  Pubspec flavorPubspec,
  Configuration config,
  Logger logger,
) async {
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
  replacedText = replacedText
      .replaceAllMapped(RegExp("$comment\\d+: (.*?)(?=\\s|\$)"), (Match m) {
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
        'The $name is changed from ${actualPubspec.name} to ${flavorPubspec.name} (as the the one mentioned in the pubspec_${config.flavor}.yaml');
    logger.stderr('This would cause errors in the project.');
    logger.stderr(
        'Fix for this would to refactor the places where the package name was used');
    logger.stderr(
        "Refactor: import 'package:${actualPubspec.name}/ to import 'package:${flavorPubspec.name}/ ");
  }

  await FlutterBuild().pubGet();
}
