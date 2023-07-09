[PUBM] is a Dart-Command Line tool created to manage multiple versions of pubspec.yaml files in a single project.
This tools helps in merging of multiple pubspec.yaml files into a single pubspec.yaml file as per the flavor selected.

## 📋 Installation

In your `pubspec.yaml`, add the `pubm` package as a new [dev dependency] with
the following command:

```console
PS c:\src\flutter_project> flutter pub add --dev pubm
```

## 📋 Usage

Sometimes situations occurs when we need to manage multiple versions of pubspec.yaml files in a single project.
This tools helps in merging of multiple pubspec.yaml files into a single pubspec.yaml file as per the flavor selected.

So here a new version of file (almost similar to pubspec.yaml) is created with the name pubspec_<flavor>.yaml.
And when the below command is executed, the pubspec.yaml file is updated with the contents of pubspec_<flavor>.yaml file.

This is be used to update/change/add the dependencies and there respective version and also the flutter fonts.

```console  
PS c:\src\flutter_project> dart run pubm:manage -f <flavor>
```
The -v flag can be used to print the detail logs (verbose logs) in the console.
```console  
PS c:\src\flutter_project> dart run pubm:manage -f <flavor> -v
```
### 📋 Example: pubpsec_dev.yaml

```console
description: dev version of pubspec.yaml
version: 0.0.1-dev

dependencies:
  example_dependency: 
   path: example/dependency

dev_dependencies:
  lints: ^2.1.1
  

flutter:
  fonts:
    - family: font1
      fonts:
        - asset: dev/font1/700.ttf
          weight: 700
        - asset: dev/font1/600.ttf
          weight: 600
        - asset: dev/font1/500.ttf
          weight: 500
        - asset: dev/font1/400.ttf
          weight: 400
    - family: font2
      fonts:
        - asset: dev/font2/700.ttf
          weight: 700
        - asset: dev/font2/600.ttf
          weight: 600
        - asset: dev/font2/500.ttf
          weight: 500
        - asset: dev/font2/400.ttf
          weight: 400
```

The above values present in the pubspec_<flavor>.yaml file will be updated in the pubspec.yaml file, if the same present, else will be added to the pubspec.yaml file.

### 📋 Example: pubspec.yaml

```console
name: pubm
description: Actual description
version: 0.0.1

environment:
  sdk: ^3.0.0

dependencies:
  cupertino_icons: ^1.0.2

flutter:
  uses-material-design: true
  generate: true
  fonts:
    - family: font1
      fonts:
        - asset: actual/font1/700.ttf
          weight: 700
        - asset: actual/font1/600.ttf
          weight: 600
        - asset: actual/font1/500.ttf
          weight: 500
        - asset: actual/font1/400.ttf
          weight: 400
    - family: font2
      fonts:
        - asset: actual/font2/700.ttf
          weight: 700
        - asset: actual/font2/600.ttf
          weight: 600
        - asset: actual/font2/500.ttf
          weight: 500
        - asset: actual/font2/400.ttf
          weight: 400
```

After running the command
```console
dart run pubm:manage -f dev
```
The output pubspec.yaml file will be as below:

```console
name: pubm
description: dev version of pubspec.yaml
version: 0.0.1-dev

environment:
  sdk: ^3.0.0

dependencies:
  # normal dependencies
  cupertino_icons: ^1.0.2
  # path related dependencies
  example_dependency: 
   path: example/dependency

dev_dependencies:
  # normal dev_dependencies
  lints: ^2.1.1

flutter:
  uses-material-design: true
  generate: true
  fonts:
    - family: font1
      fonts:
        - asset: dev/font1/700.ttf
          weight: 700
        - asset: dev/font1/600.ttf
          weight: 600
        - asset: dev/font1/500.ttf
          weight: 500
        - asset: dev/font1/400.ttf
          weight: 400
    - family: font2
      fonts:
        - asset: dev/font2/700.ttf
          weight: 700
        - asset: dev/font2/600.ttf
          weight: 600
        - asset: dev/font2/500.ttf
          weight: 500
        - asset: dev/font2/400.ttf
          weight: 400
```

By default this also sorts the dependencies and dev_dependencies in alphabetical order (but according to category).
the category are as follows:
1. git related dependencies
2. path related dependencies
3. normal dependencies
4. hosted dependencies
5. sdk dependencies

## Support
This plugin is free to use and in very early stage, lots of more things will be added up soon (Please visit the [Github Project](https://github.com/users/kushalmahapatro/projects/1) to know more), if you find any issues or want additional features, please raise an issue in the [GitHub repository](https://github.com/kushalmahapatro/pubspec_manager/issues).
Please feel free to contribute to this project by creating a pull request with a clear description of your changes.

If this plugin was useful to you, helped you in any way, saved you a lot of time, or you just want to support the project, I would be very grateful if you buy me a cup of coffee.

<a href="https://www.buymeacoffee.com/kushalm" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/purple_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>


