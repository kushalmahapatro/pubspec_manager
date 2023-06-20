import 'dependencies.dart';
import 'pubspec.dart';

Dependencies? getDependencies(Map? map) {
  if (map == null && map is! Map) return null;

  List<GitDependency> gitDependencies = [];
  List<PathDependency> pathDependencies = [];
  List<HostedDependency> hostedDependencies = [];
  List<NormalDependency> normalDependencies = [];
  List<SdkDependency> sdkDependencies = [];

  map.forEach((key, value) {
    switch (value) {
      case {'git': Map git}:
        gitDependencies.add(
          GitDependency(
            name: key,
            url: git['url'],
            ref: git['ref'],
            path: git['path'],
          ),
        );
        break;

      case {'git': String git}:
        gitDependencies.add(
          GitDependency(
            name: key,
            url: git,
          ),
        );
        break;

      case {'path': String path}:
        pathDependencies.add(
          PathDependency(
            name: key,
            path: path,
          ),
        );
      case {'hosted': String hosted, 'version': String version}:
        hostedDependencies.add(
          HostedDependency(
            name: key,
            hosted: hosted,
            version: version,
          ),
        );
        break;
      case {'hosted': Map hosted}:
        hostedDependencies.add(
          HostedDependency(
            name: key,
            hosted: hosted['hosted'],
            version: hosted['version'],
          ),
        );
        break;

      case {'sdk': String sdk}:
        sdkDependencies.add(
          SdkDependency(
            name: key,
            sdk: sdk,
          ),
        );
        break;

      default:
        normalDependencies.add(
          NormalDependency(
            name: key,
            version: value.toString(),
          ),
        );
        break;
    }
  });

  return Dependencies(
    gitDependencies: gitDependencies,
    pathDependencies: pathDependencies,
    hostedDependencies: hostedDependencies,
    normalDependencies: normalDependencies,
  );
}
