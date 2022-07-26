import 'string_constants.dart';

enum AppEnvironments { dev, stable, prod }

class AppConfig {
  static final AppConfig _instance = AppConfig._internal();

  late String host;
  late AppEnvironments env;

  AppConfig._internal();

  factory AppConfig({required String envconfig}) {
    switch (envconfig) {
      case "stable":
        _instance.host = baseurl_stable;
        _instance.env = AppEnvironments.stable;
        return _instance;

      case "prod":
        _instance.host = baseurl_prod;
        _instance.env = AppEnvironments.prod;
        return _instance;

      default:
        _instance.host = baseurl_dev;
        _instance.env = AppEnvironments.dev;
        return _instance;
    }
  }
}
