import 'yaml_check.dart';

class OverridesYamlTest extends YamlTest {
  const OverridesYamlTest(
    this.overridesYamlContent,
    super.yamlContent,
    super.flavorYamlContent,
    super.config,
  );

  final String overridesYamlContent;

  mergeValues() {}
}
