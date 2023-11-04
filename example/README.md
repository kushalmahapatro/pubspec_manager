# Overview
PUBM, short for Pubspec Manager, is a Dart-Command Line tool created to manage multiple versions of `pubspec.yaml` files in a single project. This tool helps in merging multiple `pubspec.yaml` files into a single `pubspec.yaml` file as per the selected flavor.

## 📋 Installation

To install the `pubm` package, add it as a new dev dependency in your `pubspec.yaml` file. Run the following command in your terminal:

```console
PS c:\src\flutter_project> dart pub add --dev pubm
```
For Flutter projects, use:
```console
PS c:\src\flutter_project> flutter pub add --dev pubm
```

###### 🎯 Activate from https://pub.dev
to use the executable, run the following command in your terminal:

```console
dart pub global activate pubm
```

## 📋 Usage

To manage different versions of pubspec.yaml files, create a new file for each flavor with the name `pubspec_<flavor>.yaml`. When the following command is executed, the pubspec.yaml file is updated with the contents of the `pubspec_<flavor>.yaml` file. This can be used to update, change, or add dependencies and their respective versions, as well as Flutter fonts.

```console  
# if activated from https://pub.dev
pubm -f <flavor>

# else
dart run pubm:manage -f <flavor>
```
Use the -v flag to print detailed logs (verbose logs) in the console.console.
```console  
# if activated from https://pub.dev
pubm -f <flavor> -v

# else
dart run pubm:manage -f <flavor> -v
```
### 📋 Example: pubspec_dev.yaml
Here's an example of a flavor-specific pubspec.yaml file for a 'dev' flavor:
```yaml
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
Here's an example of the main pubspec.yaml file:
```yaml
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

After running the below command, the output pubspec.yaml file will be as follows:
##### Command:
```console
# if activated from https://pub.dev
pubm -f dev

# else
dart run pubm:manage -f dev
```
##### Output

```yaml
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

### 📋 Example: Removing values from pubspec.yaml
To remove a dependency from the pubspec.yaml file, add the following line to the pubspec_<flavor>.yaml file:
The dependency name is only required, its respective version is not mandatory.

To remove dependency from dependencies section:
add it to the dependencies section of the pubspec_<flavor>.yaml file.

the same with dev_dependencies and dependency_overrides section.

Remove section should have the same format of the yaml file.

After going through all the updating values, it will look for the remove section,
if found it will look into the data and remove respective form the actual pubspec.yaml file.

### Actual pubspec.yaml file:
```yaml
name: pubm
description: test version of pubspec.yaml
version: 0.0.1

environment:
  sdk: ^3.0.0

dependencies:
  # normal dependencies
  cupertino_icons: ^1.0.2
  example_dependency: ^0.0.1

dev_dependencies:
  # normal dev_dependencies
  lints: ^2.1.1
  example_dependency_dev: ^0.0.1

dependency_overrides:
  # normal dependency_overrides
  example_dependency_overrides: ^0.0.1

flutter:
  uses-material-design: true
  generate: true
  
  assets:
    - assets/images/
    - assets/1.png
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
any_other_section:
  name: Name
  version: 0.0.1
```

### Example of pubspec_dev.yaml file:
```yaml
description: dev version of pubspec.yaml
version: 0.0.1-dev

remove:
  home_page:
    
  dependencies:
    example_dependency:
  
  dev_dependencies:
    example_dependency_dev:
  
  dependency_overrides:
    example_dependency_overrides:
  
  flutter:
    assets:
      - assets/1.png
    
    fonts:
      - family: font1
        
  any_other_section:
```

### Output
```yaml
name: pubm
description: dev version of pubspec.yaml
version: 0.0.1-dev

environment:
  sdk: ^3.0.0

dependencies:
  # normal dependencies
  cupertino_icons: ^1.0.2

dev_dependencies:
  # normal dev_dependencies
  lints: ^2.1.1

flutter:
  uses-material-design: true
  generate: true
  
  assets:
    - assets/images/
    
  fonts:
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

By default, this tool also sorts the dependencies and dev_dependencies in alphabetical order by category. The categories are as follows:
1. git related dependencies
2. path related dependencies
3. normal dependencies
4. hosted dependencies
5. sdk dependencies

## Contributors
<a href="https://github.com/kushalmahapatro/pubspec_manager/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=kushalmahapatro/pubspec_manager" />
</a>

Made with [contrib.rocks](https://contrib.rocks).

## Support
This plugin is free to use and currently in its early stages of development. We plan to add many more features soon. Please visit the [Github Project](https://github.com/users/kushalmahapatro/projects/1) to know about the upcoming feature and fixes. If you encounter any issues or would like additional features, please raise an issue in the [GitHub repository](https://github.com/kushalmahapatro/pubspec_manager/issues).
Feel free to contribute to this project by creating a pull request with a clear description of your changes.
If this plugin was useful to you, helped you in any way, saved you a lot of time, or you just want to support the project, I would be very grateful if you buy me a cup of coffee. Your support helps maintain and improve this project.

<a href="https://www.buymeacoffee.com/kushalm" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/purple_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>


