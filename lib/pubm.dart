import 'package:cli_util/cli_logging.dart';
import 'package:get_it/get_it.dart';
import 'package:pubm/src/configuration.dart';
import 'package:pubm/src/pubspec_manage.dart';

class Pubm with PubspecManage {
  Pubm(List<String> args) {
    _setupSingletonServices(args);
  }

  /// Execute with the `pubm:manage` command
  Future<void> manage() async {
    final bool continueAhead = await _initConfig();
    if (!continueAhead) return;
    logger.stdout('Merging of pubspec.yaml files started...');
    mergePubspec();
  }

  Future<bool> _initConfig() async {
    await config.getConfigValues();
    return await config.validateConfigValues();
  }

  @override
  Configuration get config => GetIt.I<Configuration>();

  @override
  Logger get logger => GetIt.I<Logger>();
}

/// Register [Logger] and [Configuration] as singleton services
void _setupSingletonServices(List<String> args) {
  GetIt.I.registerSingleton<Logger>(args.contains('-v')
      ? Logger.verbose()
      : Logger.standard(ansi: Ansi(true)));

  GetIt.I.registerSingleton<Configuration>(Configuration(args));
}
