import 'package:equatable/equatable.dart';

class Environment extends Equatable {
  final String sdk;
  final String? flutter;

  const Environment({
    required this.sdk,
    this.flutter,
  });

  Map<String, dynamic> toMap() {
    return {
      'sdk': sdk,
      if (flutter != null) 'flutter': flutter,
    };
  }

  factory Environment.fromMap(Map map) {
    return Environment(
      sdk: map['sdk'],
      flutter: map['flutter'],
    );
  }

  @override
  List<Object?> get props => [sdk, flutter];
}
