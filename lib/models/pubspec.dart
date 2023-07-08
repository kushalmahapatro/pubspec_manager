import 'package:pubm/constants.dart';

import 'dependencies.dart';
import 'environment.dart';
import 'flutter_data.dart';
import 'helper.dart';

class Pubspec {
  final String name;
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

  const Pubspec(
      {required this.name,
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
      this.flutter});

  Map<String, dynamic> toMap({bool addComments = false}) {
    return {
      'name': name,
      if (description != null) 'description': description,
      if (homepage != null) 'homepage': homepage,
      if (repository != null) 'repository': repository,
      if (issueTracker != null) 'issue_tracker': issueTracker,
      if (documentation != null) 'documentation': documentation,
      if (publishTo != null) 'publish_to': publishTo,
      if (version != null) 'version': version,
      if (environment != null) 'environment': environment?.toMap(),
      if (dependencies != null)
        'dependencies': dependencies?.toMap(addComments: addComments),
      if (devDependencies != null)
        'dev_dependencies': devDependencies?.toMap(addComments: addComments),
      if (dependenciesOverride != null)
        'dependency_overrides':
            dependenciesOverride?.toMap(addComments: addComments),
      if (flutter != null) 'flutter': flutter?.toMap(),
    };
  }

  factory Pubspec.fromMap(Map map) {
    return Pubspec(
      name: map['name'] ?? '',
      description: map['description'],
      version: map['version'],
      homepage: map['homepage'],
      repository: map['repository'],
      issueTracker: map['issue_tracker'],
      documentation: map['documentation'],
      publishTo: map['publish_to'],
      environment: map['environment'] != null
          ? Environment.fromMap(map['environment'])
          : null,
      dependencies: getDependencies(map['dependencies']),
      devDependencies: getDependencies(map['dev_dependencies']),
      dependenciesOverride: getDependencies(map['dependency_overrides']),
      flutter:
          map['flutter'] != null ? FlutterData.fromMap(map['flutter']) : null,
    );
  }
}

class Dependencies {
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
        finalList.add({'${Constants.comment}1': 'git related dependencies'});
      }
      finalList += gitDependencies!.map((x) => x.toMap()).toList();
    }

    if (pathDependencies != null && pathDependencies!.isNotEmpty) {
      if (addComments) {
        finalList.add({'${Constants.comment}2': 'path related dependencies'});
      }
      finalList += pathDependencies!.map((x) => x.toMap()).toList();
    }
    if (normalDependencies != null && normalDependencies!.isNotEmpty) {
      if (addComments) {
        finalList.add({'${Constants.comment}3': 'normal dependencies'});
      }
      finalList += normalDependencies!.map((x) => x.toMap()).toList();
    }

    if (hostedDependencies != null && hostedDependencies!.isNotEmpty) {
      if (addComments) {
        finalList.add({'${Constants.comment}4': 'hosted dependencies'});
      }
      finalList += hostedDependencies!.map((x) => x.toMap()).toList();
    }

    if (sdkDependencies != null && sdkDependencies!.isNotEmpty) {
      if (addComments) {
        finalList.add({'${Constants.comment}5': 'sdk dependencies'});
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
}
