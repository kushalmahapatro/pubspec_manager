import 'dart:io';

import 'package:cli_util/cli_logging.dart';
import 'package:get_it/get_it.dart';

extension ProcessResultExtensions on ProcessResult {
  void exitOnError() {
    if (this.exitCode != 0) {
      GetIt.I<Logger>().stderr(this.stdout);
      throw this.stderr;
    }
  }
}

/// Used for colored logs
extension StringExtensions on String {
  String get emphasized => '${Ansi(true).bold}$this${Ansi(true).none}';
  String get green => '${Ansi(true).green}$this${Ansi(true).none}';
  String get blue => '${Ansi(true).blue}$this${Ansi(true).none}';
  String get red => '${Ansi(true).red}$this${Ansi(true).none}';
  String get gray => '${Ansi(true).gray}$this${Ansi(true).none}';
}
