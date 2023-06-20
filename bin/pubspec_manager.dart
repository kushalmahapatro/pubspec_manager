import 'dart:collection';
import 'dart:io';

import 'package:args/args.dart';
import 'package:json2yaml/json2yaml.dart';
import 'package:pubspec_manager/constants.dart';
import 'package:pubspec_manager/models/pubspec.dart';
import 'package:yaml/yaml.dart';

void main(List<String> arguments) {
  final parser = ArgParser();
  parser.addOption('flavor',
      abbr: 'f', help: 'flavor of YAML file (pubspec-/flavor/.yaml)');

  final args = parser.parse(arguments);

  final flavor = args['flavor'];

  if (flavor == null) {
    print('Usage: dart pubspec_manager.dart -f <flavor>');
    return;
  }

  final file = File('pubspec_$flavor.yaml');
  if (!file.existsSync()) {
    print('File does not exist: $flavor');
    return;
  }

  // Read the YAML file
  final contents = file.readAsStringSync();

  // Parse the YAML contents
  dynamic yamlMap = loadYaml(contents);
  dynamic actualYamlMap = loadYaml(File('pub.yaml').readAsStringSync());

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
      if (finalMap['dev_dependencies'] != null) ...finalMap['dev_dependencies'],
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

  var sortedDOKeys = finalMap['dependency_overrides']
      .keys
      .toList(growable: false)
    ..sort((k1, k2) => k1.toString().compareTo(k2.toString()));
  LinkedHashMap sortedDOMap = LinkedHashMap.fromIterable(sortedDOKeys,
      key: (k) => k, value: (k) => finalMap['dependency_overrides'][k]);
  finalMap['dependency_overrides'] = sortedDOMap;

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
  File('pubpsec.yaml').writeAsStringSync(replacedText);

  print('YAML file updated successfully.');
}
