import 'dart:collection';
import 'dart:io';

import 'package:cli_util/cli_logging.dart';
import 'package:json2yaml/json2yaml.dart';
import 'package:pubm/constants.dart';
import 'package:pubm/models/pubspec.dart';
import 'package:pubm/src/configuration.dart';
import 'package:pubm/src/extensions.dart';
import 'package:yaml/yaml.dart';

mixin PubspecManage {
  Logger get logger;
  Configuration get config;
  void mergePubspec() {
    final file = File('pubspec_${config.flavor}.yaml');
    if (!file.existsSync()) {
      logger.stderr('File does not exist: ${config.flavor}'.red);
      return;
    }

    // Read the YAML file
    final contents = file.readAsStringSync();

    // Parse the YAML contents
    dynamic yamlMap = loadYaml(contents);
    dynamic actualYamlMap =
        loadYaml(File(Constants.pubspecYamlPath).readAsStringSync());

    // Create a Pubspec object
    final actualPubspec = Pubspec.fromMap(actualYamlMap);
    final flavorPubspec = Pubspec.fromMap(yamlMap);

    // Update the Pubspec object
    Map<String, dynamic> finalMap = actualPubspec.toMap();
    if (finalMap['dependencies'] != null && finalMap['dependencies'] is Map) {
      final map = flavorPubspec.toMap();

      finalMap['dependencies'] = <String, dynamic>{
        if (finalMap['dependencies'] != null) ...finalMap['dependencies'],
        if (map['dependencies'] != null) ...map['dependencies'],
      };
    }

    if (finalMap['dev_dependencies'] != null &&
        finalMap['dev_dependencies'] is Map) {
      final map = flavorPubspec.toMap();

      finalMap['dev_dependencies'] = <String, dynamic>{
        if (finalMap['dev_dependencies'] != null)
          ...finalMap['dev_dependencies'],
        if (map['dev_dependencies'] != null) ...map['dev_dependencies'],
      };
    }

    if (finalMap['dependency_overrides'] != null &&
        finalMap['dependency_overrides'] is Map) {
      final map = flavorPubspec.toMap();
      finalMap['dependency_overrides'] = <String, dynamic>{
        if (finalMap['dependency_overrides'] != null)
          ...finalMap['dependency_overrides'],
        if (map['dependency_overrides'] != null) ...map['dependency_overrides'],
      };
    }

    var sortedKeys = finalMap['dependencies'].keys.toList(growable: false)
      ..sort((k1, k2) => k1.toString().compareTo(k2.toString()));
    LinkedHashMap sortedMap = LinkedHashMap.fromIterable(sortedKeys,
        key: (k) => k, value: (k) => finalMap['dependencies'][k]);
    finalMap['dependencies'] = sortedMap;

    var sortedDDKeys = finalMap['dev_dependencies'].keys.toList(growable: false)
      ..sort((k1, k2) => k1.toString().compareTo(k2.toString()));
    LinkedHashMap sortedDDMap = LinkedHashMap.fromIterable(sortedDDKeys,
        key: (k) => k, value: (k) => finalMap['dev_dependencies'][k]);
    finalMap['dev_dependencies'] = sortedDDMap;

    if (finalMap.containsKey('dependency_overrides')) {
      var sortedDOKeys = finalMap['dependency_overrides']
          .keys
          .toList(growable: false)
        ..sort((k1, k2) => k1.toString().compareTo(k2.toString()));
      LinkedHashMap sortedDOMap = LinkedHashMap.fromIterable(sortedDOKeys,
          key: (k) => k, value: (k) => finalMap['dependency_overrides'][k]);
      finalMap['dependency_overrides'] = sortedDOMap;
    }

    final finalPubspec = Pubspec.fromMap(finalMap);

    final string = json2yaml(
      finalPubspec.toMap(addComments: true),
      yamlStyle: YamlStyle.pubspecYaml,
    );

    RegExp exp = RegExp("${Constants.comment}\\d+: (.*?)(?=\\s|\$)");
    String replacedText = string.replaceAllMapped(exp, (Match m) {
      return '# ${m.group(1)}';
    });

    // Save the updated YAML to the file
    File('_pubspec.yaml')
        .writeAsStringSync(File('pubspec.yaml').readAsStringSync());
    File('pubspec.yaml').writeAsStringSync(replacedText);

    logger.stdout('Merging of pubspec.yaml files completed successfully'.green);
  }
}
