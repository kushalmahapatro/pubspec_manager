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
