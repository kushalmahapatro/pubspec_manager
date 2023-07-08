import 'package:collection/collection.dart';
import 'package:pubm/models/dependencies.dart';
import 'package:pubm/models/flutter_data.dart';
import 'package:pubm/models/pubspec.dart';

abstract class PubspecChecker {
  static bool _checkStringValue(String? actual, String? flavor) {
    return !(flavor != null && actual != flavor);
  }

  static ({bool hasMatch, List<String>? update, List<String>? addition})
      _checkDependency(Dependencies? flavor, Dependencies? actual,
          {bool checkAll = false}) {
    final List<String> updates = [];
    final List<String> newAddition = [];
    bool hasMatch = true;

    void getUpdate<T extends Dependency>(List<T>? actual, T element) {
      T? item = actual?.firstWhereOrNull((e) => element.name == e.name);
      if (item != null) {
        if (item.reference != element.reference) {
          updates.add(element.reference);
          if (hasMatch) hasMatch = false;
        }
      } else {
        newAddition.add(element.reference);
        if (hasMatch) hasMatch = false;
      }
    }

    for (final GitDependency element in flavor?.gitDependencies ?? []) {
      if (checkAll) {
        getUpdate<GitDependency>(actual?.gitDependencies, element);
      } else {
        return (
          hasMatch: (actual?.gitDependencies?.contains(element) ?? false),
          update: updates,
          addition: newAddition,
        );
      }
    }

    for (var element in flavor?.hostedDependencies ?? []) {
      if (checkAll) {
        getUpdate<HostedDependency>(actual?.hostedDependencies, element);
      } else {
        return (
          hasMatch: (actual?.hostedDependencies?.contains(element) ?? false),
          update: updates,
          addition: newAddition,
        );
      }
    }

    for (var element in flavor?.normalDependencies ?? []) {
      if (checkAll) {
        getUpdate<NormalDependency>(actual?.normalDependencies, element);
      } else {
        return (
          hasMatch: (actual?.normalDependencies?.contains(element) ?? false),
          update: updates,
          addition: newAddition,
        );
      }
    }

    for (var element in flavor?.pathDependencies ?? []) {
      if (checkAll) {
        getUpdate<PathDependency>(actual?.pathDependencies, element);
      } else {
        return (
          hasMatch: (actual?.pathDependencies?.contains(element) ?? false),
          update: updates,
          addition: newAddition,
        );
      }
    }

    for (var element in flavor?.sdkDependencies ?? []) {
      if (checkAll) {
        getUpdate<SdkDependency>(actual?.sdkDependencies, element);
      } else {
        return (
          hasMatch: (actual?.sdkDependencies?.contains(element) ?? false),
          update: updates,
          addition: newAddition,
        );
      }
    }

    return (hasMatch: hasMatch, update: updates, addition: newAddition);
  }

  static bool checkIfPubspecAlreadyMerged(
      {required Pubspec actualPubspec, required Pubspec flavorPubspec}) {
    if (!checkName(actualPubspec, flavorPubspec)) {
      return false;
    }

    if (!checkDescription(actualPubspec, flavorPubspec)) {
      return false;
    }

    if (!checkVersion(actualPubspec, flavorPubspec)) {
      return false;
    }

    if (!checkHomepage(actualPubspec, flavorPubspec)) {
      return false;
    }

    if (!checkRepository(actualPubspec, flavorPubspec)) {
      return false;
    }

    if (!checkIssueTracker(actualPubspec, flavorPubspec)) {
      return false;
    }

    if (!checkDocumentation(actualPubspec, flavorPubspec)) {
      return false;
    }

    if (!checkPublishTo(actualPubspec, flavorPubspec)) {
      return false;
    }

    if (!checkEnvironment(actualPubspec, flavorPubspec)) {
      return false;
    }

    if (!checkDependencies(actualPubspec, flavorPubspec).hasMatch) {
      return false;
    }

    if (!checkDevDependencies(actualPubspec, flavorPubspec).hasMatch) {
      return false;
    }

    if (!checkDependencyOverride(actualPubspec, flavorPubspec).hasMatch) {
      return false;
    }

    if (!checkFlutter(actualPubspec, flavorPubspec)) {
      return false;
    }

    return true;
  }

  static bool checkName(Pubspec actualPubspec, Pubspec flavorPubspec) {
    return _checkStringValue(actualPubspec.name, flavorPubspec.name);
  }

  static bool checkDescription(Pubspec actualPubspec, Pubspec flavorPubspec) {
    return _checkStringValue(
        actualPubspec.description, flavorPubspec.description);
  }

  static bool checkVersion(Pubspec actualPubspec, Pubspec flavorPubspec) {
    return _checkStringValue(actualPubspec.version, flavorPubspec.version);
  }

  static bool checkHomepage(Pubspec actualPubspec, Pubspec flavorPubspec) {
    return _checkStringValue(actualPubspec.homepage, flavorPubspec.homepage);
  }

  static bool checkRepository(Pubspec actualPubspec, Pubspec flavorPubspec) {
    return _checkStringValue(
        actualPubspec.repository, flavorPubspec.repository);
  }

  static bool checkIssueTracker(Pubspec actualPubspec, Pubspec flavorPubspec) {
    return _checkStringValue(
        actualPubspec.issueTracker, flavorPubspec.issueTracker);
  }

  static bool checkDocumentation(Pubspec actualPubspec, Pubspec flavorPubspec) {
    return _checkStringValue(
        actualPubspec.documentation, flavorPubspec.documentation);
  }

  static bool checkPublishTo(Pubspec actualPubspec, Pubspec flavorPubspec) {
    return _checkStringValue(actualPubspec.publishTo, flavorPubspec.publishTo);
  }

  static bool checkEnvironment(Pubspec actualPubspec, Pubspec flavorPubspec) {
    if (flavorPubspec.environment != null &&
        actualPubspec.environment != flavorPubspec.environment) {
      return false;
    }
    return true;
  }

  static ({bool hasMatch, List<String> update, List<String> addition})
      checkDependencies(Pubspec actualPubspec, Pubspec flavorPubspec,
          {bool checkAll = false}) {
    if (flavorPubspec.dependencies != null) {
      var check = _checkDependency(
        flavorPubspec.dependencies,
        actualPubspec.dependencies,
        checkAll: checkAll,
      );
      return (
        hasMatch: check.hasMatch,
        update: check.update ?? [],
        addition: check.addition ?? []
      );
    }
    return (hasMatch: true, update: [], addition: []);
  }

  static ({bool hasMatch, List<String> update, List<String> addition})
      checkDevDependencies(Pubspec actualPubspec, Pubspec flavorPubspec,
          {bool checkAll = false}) {
    if (flavorPubspec.devDependencies != null) {
      var check = _checkDependency(
        flavorPubspec.devDependencies,
        actualPubspec.devDependencies,
        checkAll: checkAll,
      );

      return (
        hasMatch: check.hasMatch,
        update: check.update ?? [],
        addition: check.addition ?? []
      );
    }
    return (hasMatch: true, update: [], addition: []);
  }

  static ({bool hasMatch, List<String> update, List<String> addition})
      checkDependencyOverride(Pubspec actualPubspec, Pubspec flavorPubspec,
          {bool checkAll = false}) {
    if (flavorPubspec.dependenciesOverride != null) {
      var check = _checkDependency(
        flavorPubspec.dependenciesOverride,
        actualPubspec.dependenciesOverride,
        checkAll: checkAll,
      );
      return (
        hasMatch: check.hasMatch,
        update: check.update ?? [],
        addition: check.addition ?? []
      );
    }
    return (hasMatch: true, update: [], addition: []);
  }

  static bool checkFlutter(Pubspec actualPubspec, Pubspec flavorPubspec) {
    if (flavorPubspec.flutter != null) {
      if (flavorPubspec.flutter!.usesMaterialDesign != null &&
          actualPubspec.flutter?.usesMaterialDesign !=
              flavorPubspec.flutter?.usesMaterialDesign) {
        return false;
      }

      if (flavorPubspec.flutter!.generate != null &&
          actualPubspec.flutter?.generate != flavorPubspec.flutter?.generate) {
        return false;
      }

      if (flavorPubspec.flutter!.assets != null) {
        if (flavorPubspec.flutter!.assets?.join('') !=
            actualPubspec.flutter?.assets?.join('')) {
          return false;
        }
      }

      if (flavorPubspec.flutter!.fonts != null) {
        for (final font in flavorPubspec.flutter!.fonts!) {
          final Font? matchedFont =
              actualPubspec.flutter!.fonts!.firstWhereOrNull((element) {
            return element.family == font.family;
          });

          if (matchedFont == null) {
            return false;
          } else {
            for (final data in matchedFont.fonts ?? []) {
              if (!(font.fonts?.contains(data) ?? false)) {
                return false;
              }
            }
          }
        }
      }
    }
    return true;
  }
}
