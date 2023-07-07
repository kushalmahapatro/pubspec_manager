import 'dart:collection';
import 'dart:io';

import 'package:args/args.dart';
import 'package:json2yaml/json2yaml.dart';
import 'package:pubm/constants.dart';
import 'package:pubm/models/pubspec.dart';
import 'package:yaml/yaml.dart';

void main(List<String> arguments) {
  exitCode = 0;
  final parser = ArgParser();
  parser.addOption('flavor',
      abbr: 'f', help: 'flavor of YAML file (pubspec_/flavor/.yaml)');
  parser.addFlag('verbose', negatable: false, abbr: 'v');
  parser.addFlag('help', negatable: false, abbr: 'h');
  ArgResults args;
  try {
    args = parser.parse(arguments);

    final flavor = args['flavor']?.toString();
    final bool verbose = args['verbose'];
    final bool help = args['help'];

    if (help) {
      print('Usage: dart run pubm:manage -f <flavor>');
      print(
          'Usage: dart run pubm:manage -f <flavor> -v (verbose) to enable verbose mode');
      print(
          'Usage: dart run pubm:manage -h to get the list of available commands and how to use');
      return;
    }

    if (flavor == null || flavor.isEmpty) {
      exitCode = 2;
      stderr.writeln('Usage: dart manage.dart -f <flavor>');
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
    File('pubspec.yaml').writeAsStringSync(replacedText);

    stdout.writeln('YAML file updated successfully.');
  } catch (e) {
    exitCode = 2;
    stderr.writeln('Usage: dart manage.dart -f <flavor>');
    stderr.writeln(e);
  }
}
