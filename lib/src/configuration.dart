import 'dart:io';

import 'package:args/args.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:get_it/get_it.dart';
import 'package:pubm/constants.dart';
import 'package:pubm/src/command_line_convertor.dart';
import 'package:pubm/src/extensions.dart';
import 'package:yaml/yaml.dart';

/// Handles loading and validating the configuration values
class Configuration {
  final List<String> _arguments;
  Configuration(this._arguments);

  final Logger _logger = GetIt.I<Logger>();
  late ArgResults _args;
  List<String>? buildArgs;
  String flavor = '';
  File backupPubspecFile = File('backup_${Constants.pubspecYamlPath}');
  File pubspecFile = File(Constants.pubspecYamlPath);
  File pubspecFlavorFile = File('');

  /// Gets the configuration values from from [_arguments] or pubspec.yaml file
  Future<void> getConfigValues() async {
    _parseCliArguments(_arguments);
    dynamic pubspec = await _getPubspec();
    dynamic yaml = pubspec['pubm_config'] ?? YamlMap();

    final String? buildArgsConfig =
        (_args['build-args'] ?? yaml['build_args'])?.toString();
    if (buildArgsConfig != null && buildArgsConfig.isNotEmpty) {
      CommandLineConverter commandLineConverter = CommandLineConverter();
      buildArgs = commandLineConverter.convert(buildArgsConfig);
    }
  }

  /// Validate the configuration values and set default values
  Future<bool> validateConfigValues() async {
    _logger.trace('validating config values');

    if (_args['help']) {
      _logger.stdout('Usage: dart run pubm:manage -f <flavor>');
      _logger.stdout(
          'Usage: dart run pubm:manage -f <flavor> -v (verbose) to enable verbose mode');
      _logger.stdout(
          'Usage: dart run pubm:manage -h to get the list of available commands and how to use');

      return false;
    }

    flavor = _args['flavor']?.toString() ?? '';
    if (flavor.isEmpty) {
      exitCode = 2;
      _logger.write('Usage: dart manage.dart -f <flavor>'.red);
      return false;
    }

    pubspecFlavorFile = File('pubspec_$flavor.yaml');
    return true;
  }

  /// Get pubspec.yaml content
  dynamic _getPubspec() async {
    String pubspecString = await File(Constants.pubspecYamlPath).readAsString();
    dynamic pubspec = loadYaml(pubspecString);
    return pubspec;
  }

  /// Declare and parse the cli arguments
  void _parseCliArguments(List<String> args) {
    _logger.trace('parsing cli arguments');

    ArgParser parser = ArgParser()
      ..addOption('flavor',
          abbr: 'f', help: 'flavor of YAML file (pubspec_/flavor/.yaml)')
      ..addOption('build-args')
      ..addFlag('help', negatable: false, abbr: 'h');

    // exclude -v (verbose) from the arguments
    _args = parser.parse(args.where((arg) => arg != '-v'));
  }
}
