import 'package:flavour/app_config.dart';

import 'main_common.dart';

void main() {
  final AppConfig config =
      AppConfig(envconfig: const String.fromEnvironment('ENV'));

  mainCommon(config);
}
