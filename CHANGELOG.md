### 0.3.0+1 (2024-01-25)
#### Added
- Added support to mange overridden dependencies in pubspec_overrides.yaml file.
- Added support to avoid running pub get after managing the dependencies, can be called by `pubm -f <flavor> -b no-pub-get` or `dart run pub:manage -f <flavor> -b no-pub-get`, -b is abbreviation for `--build-args`
- Added support to both `flutter pub get` and `dart pub get` commands (If the pubspec.yaml file contains flutter sdk dependency then it will run flutter pub get else dart pub get).

#### Fixed
- Fixed the issue of of removing and managing dependencies when clubbed together. 

### 0.2.0 (2023-11-04)
#### Added
- Added support to remove values from pubspec.yaml file.

### 0.1.1 (2023-09-19)
#### Fixed
- Deep check for other dependencies  to avoid changes to pubspec.yaml file if the dependencies are same.

### 0.1.0 (2023-09-05)
#### Added
- Added 'pubm' executable, can be activated by `dart pub global activate pubm`.

### 0.0.3-alpha (2023-07-11)
#### Added
- Added support for Addition/Others params in pubspec.yaml file. (like msix_config, flutter_launcher_icons)
- Added warning message if the name in pubspec.yaml file got changed with the one provided in `pubspec_<flavor>.yaml` file.
- Unit test cases for the added features.

#### Fixed
- Fixed the issue when name was not provided in `pubspec_<flavor>.yaml` and the name in pubspec.yaml file was changed to empty string.
- Fixed the issue with the git dependencies without ref

### 0.0.2-alpha (2023-07-10)
#### Updated
- Updated the README.md file to include the new features and also the usage of the package.

### 0.0.1-alpha (2023-07-09)

#### Initial version.
##### Added
- New feature to automatically sort dependencies alphabetically and also as per the type of the dependency.
- Feature to automatically add the new dependency to the correct section of the pubspec.yaml file.
- Feature to update dependencies to the desired version (as mentioned in the respective `pubspec_<flavor>.yaml` file).
- Feature to change the name, version, description and also assets and fonts in pubspec.yaml file as per the `pubspec_<flavor>.yaml`.
