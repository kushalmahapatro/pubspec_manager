import 'package:cli_util/cli_logging.dart';
import 'package:get_it/get_it.dart';
import 'package:pubm/src/configuration.dart';
import 'package:pubm/src/manage/pubspec_manage.dart';

class MockPubspecManager with PubspecManager {
  @override
  Configuration get config => GetIt.I<Configuration>();

  @override
  Logger get logger => GetIt.I<Logger>();
}
