const yamlContent = '''

$name
$description
$version
$environmentContent
$dependencyContent
$devDependencies
$dependencyOverride
$flutterContent
  ''';

const name = '''
name: pubm
  ''';

const description = '''
description: A command-line application to manage pubspec dependencies.
  ''';

const version = '''
version: 1.0.0
  ''';

const environmentContent = '''

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '3.10.0'
 
  ''';

const dependencyContent = '''

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  path_test: 
   path: abc/xyz
  path_test2: 
   path: abc/xyz/2
  git_test:
    git:
      url: https://github.com/aa/aa.git
      ref: 1232131231231dependency
      path: path
  git_test2:
    git:
      url: https://github.com/aa/aa2.git
      ref: 00000000000000dependency
      path: path2
  args: ^2.4.2
  cupertino_icons: ^1.0.2

  ''';

const devDependencies = '''

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_driver:
    sdk: flutter
  git_test_dev:
    git:
      url: https://github.com/aa/dev.git
      ref: 00000000000000dev
      path: path_dev
  test: any
  lints: ^2.1.1
  
  ''';

const dependencyOverride = '''
 
dependency_overrides:
  git_test_override:
    git:
      url: https://github.com/aa/override.git
      ref: 00000000000000override
      path: path_override


  ''';

const flutterContent = '''

flutter:
  uses-material-design: true
  generate: true
  
  fonts:
    - family: test
      fonts:
        - asset: a/a/700.ttf
          weight: 700
        - asset: a/a/600.ttf
          weight: 600
        - asset: a/a/500.ttf
          weight: 500
        - asset: a/a/400.ttf
          weight: 400
    - family: test2
      fonts:
        - asset: a/b/700.ttf
          weight: 700
        - asset: a/b/600.ttf
          weight: 600
        - asset: a/b/500.ttf
          weight: 500
        - asset: a/b/400.ttf
          weight: 400

  ''';
