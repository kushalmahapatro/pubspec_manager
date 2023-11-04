import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:pubm/constants.dart';

import 'dependencies.dart';
import 'environment.dart';
import 'flutter_data.dart';
import 'helper.dart';

class Pubspec extends Equatable {
  final String? name;
  final String? description;
  final String? version;
  final String? homepage;
  final String? repository;
  final String? issueTracker;
  final String? documentation;
  final String? publishTo;
  final Environment? environment;
  final Dependencies? dependencies;
  final Dependencies? devDependencies;
  final Dependencies? dependenciesOverride;
  final FlutterData? flutter;
  final Map<String, dynamic>? others;

  const Pubspec({
    this.name,
    this.description,
    this.version,
    this.homepage,
    this.repository,
    this.issueTracker,
    this.documentation,
    this.publishTo,
    this.environment,
    this.dependencies,
    this.devDependencies,
    this.dependenciesOverride,
    this.flutter,
    this.others,
  });

  Map<String, dynamic> toMap({bool addComments = false}) {
    return {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (version != null) 'version': version,
      if (homepage != null) 'homepage': homepage,
      if (repository != null) 'repository': repository,
      if (issueTracker != null) 'issue_tracker': issueTracker,
      if (documentation != null) 'documentation': documentation,
      if (publishTo != null) 'publish_to': publishTo,
      if (environment != null) 'environment': environment?.toMap(),
      if (dependencies != null)
        'dependencies': dependencies?.toMap(addComments: addComments),
      if (devDependencies != null)
        'dev_dependencies': devDependencies?.toMap(addComments: addComments),
      if (dependenciesOverride != null)
        'dependency_overrides':
            dependenciesOverride?.toMap(addComments: addComments),
      if (flutter != null) 'flutter': flutter?.toMap(),
      if (others != null) ...others!
    };
  }

  factory Pubspec.fromMap(Map map) {
    Pubspec pubspec = Pubspec();
    Map<String, dynamic> others = {};
    map.forEach((key, value) {
      if (key == 'name') {
        pubspec = pubspec.copyWith(name: value);
      } else if (key == 'description') {
        pubspec = pubspec.copyWith(description: value);
      } else if (key == 'version') {
        pubspec = pubspec.copyWith(version: value);
      } else if (key == 'homepage') {
        pubspec = pubspec.copyWith(homepage: value);
      } else if (key == 'repository') {
        pubspec = pubspec.copyWith(repository: value);
      } else if (key == 'issue_tracker') {
        pubspec = pubspec.copyWith(issueTracker: value);
      } else if (key == 'documentation') {
        pubspec = pubspec.copyWith(documentation: value);
      } else if (key == 'publish_to') {
        pubspec = pubspec.copyWith(publishTo: value);
      } else if (key == 'environment') {
        pubspec = pubspec.copyWith(
            environment: Environment.fromMap(value.cast<String, dynamic>()));
      } else if (key == 'dependencies') {
        pubspec = pubspec.copyWith(
            dependencies: getDependencies(value.cast<String, dynamic>()));
      } else if (key == 'dev_dependencies') {
        pubspec = pubspec.copyWith(
            devDependencies: getDependencies(value.cast<String, dynamic>()));
      } else if (key == 'dependency_overrides') {
        pubspec = pubspec.copyWith(
            dependenciesOverride:
                getDependencies(value.cast<String, dynamic>()));
      } else if (key == 'flutter') {
        pubspec = pubspec.copyWith(
            flutter: FlutterData.fromMap(value.cast<String, dynamic>()));
      } else {
        if (value is Map || value is List) {
          others[key] = jsonDecode(jsonEncode(value));
        } else {
          others[key] = value;
        }
      }
    });
    pubspec = pubspec.copyWith(others: others);
    return pubspec;
  }

  @override
  List<Object?> get props => [
        name,
        description,
        version,
        homepage,
        repository,
        issueTracker,
        documentation,
        publishTo,
        environment,
        dependencies,
        devDependencies,
        dependenciesOverride,
        flutter,
        others
      ];

  Pubspec copyWith({
    String? name,
    String? description,
    String? version,
    String? homepage,
    String? repository,
    String? issueTracker,
    String? documentation,
    String? publishTo,
    Environment? environment,
    Dependencies? dependencies,
    Dependencies? devDependencies,
    Dependencies? dependenciesOverride,
    FlutterData? flutter,
    Map<String, dynamic>? others,
  }) {
    return Pubspec(
      name: name ?? this.name,
      description: description ?? this.description,
      version: version ?? this.version,
      homepage: homepage ?? this.homepage,
      repository: repository ?? this.repository,
      issueTracker: issueTracker ?? this.issueTracker,
      documentation: documentation ?? this.documentation,
      publishTo: publishTo ?? this.publishTo,
      environment: environment ?? this.environment,
      dependencies: dependencies ?? this.dependencies,
      devDependencies: devDependencies ?? this.devDependencies,
      dependenciesOverride: dependenciesOverride ?? this.dependenciesOverride,
      flutter: flutter ?? this.flutter,
      others: others ?? this.others,
    );
  }
}

class Dependencies extends Equatable {
  final List<GitDependency>? gitDependencies;
  final List<PathDependency>? pathDependencies;
  final List<NormalDependency>? normalDependencies;
  final List<HostedDependency>? hostedDependencies;
  final List<SdkDependency>? sdkDependencies;

  const Dependencies({
    this.gitDependencies,
    this.pathDependencies,
    this.hostedDependencies,
    this.normalDependencies,
    this.sdkDependencies,
  });

  Map<String, dynamic> toMap({bool addComments = false}) {
    Map<String, dynamic> result = {};
    List<Map<String, dynamic>> finalList = [];
    if (gitDependencies != null && gitDependencies!.isNotEmpty) {
      if (addComments) {
        finalList.add({'${comment}1': 'git related dependencies'});
      }
      finalList += gitDependencies!.map((x) => x.toMap()).toList();
    }

    if (pathDependencies != null && pathDependencies!.isNotEmpty) {
      if (addComments) {
        finalList.add({'${comment}2': 'path related dependencies'});
      }
      finalList += pathDependencies!.map((x) => x.toMap()).toList();
    }
    if (normalDependencies != null && normalDependencies!.isNotEmpty) {
      if (addComments) {
        finalList.add({'${comment}3': 'normal dependencies'});
      }
      finalList += normalDependencies!.map((x) => x.toMap()).toList();
    }

    if (hostedDependencies != null && hostedDependencies!.isNotEmpty) {
      if (addComments) {
        finalList.add({'${comment}4': 'hosted dependencies'});
      }
      finalList += hostedDependencies!.map((x) => x.toMap()).toList();
    }

    if (sdkDependencies != null && sdkDependencies!.isNotEmpty) {
      if (addComments) {
        finalList.add({'${comment}5': 'sdk dependencies'});
      }
      finalList += sdkDependencies!.map((x) => x.toMap()).toList();
    }

    for (var map in finalList) {
      result.addAll(map);
    }

    return result;
  }

  factory Dependencies.fromMap(Map<String, dynamic> map) {
    return Dependencies(
      gitDependencies: map['gitDependencies'] as List<GitDependency>,
      pathDependencies: map['pathDependencies'] as List<PathDependency>,
      normalDependencies: map['normalDependencies'] as List<NormalDependency>,
      hostedDependencies: map['hostedDependencies'] as List<HostedDependency>,
      sdkDependencies: map['sdkDependencies'] as List<SdkDependency>,
    );
  }

  @override
  List<Object?> get props => [
        ...gitDependencies ?? [],
        ...pathDependencies ?? [],
        ...normalDependencies ?? [],
        ...hostedDependencies ?? [],
        ...sdkDependencies ?? []
      ];
}
