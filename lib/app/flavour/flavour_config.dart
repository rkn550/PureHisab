enum Flavour { development, production, staging }

enum UrlType { http, https }

class FlavourConfig {
  final Flavour flavour;
  final UrlType urlType;
  final String appName;
  final String baseUrl;
  final String apiBaseUrl;
  final String dbName;
  final int dbVersion;

  FlavourConfig({
    required this.flavour,
    required this.urlType,
    required this.appName,
    required this.baseUrl,
    required this.apiBaseUrl,
    required this.dbName,
    required this.dbVersion,
  });

  String get fullApiUrl => '$urlType://$apiBaseUrl';
  String get fullBaseUrl => '$urlType://$baseUrl';
}

class DevelopmentFlavourConfig extends FlavourConfig {
  DevelopmentFlavourConfig()
    : super(
        flavour: Flavour.development,
        urlType: UrlType.https,
        appName: 'PureHisab Dev',
        baseUrl: 'dev.purehisab.com',
        apiBaseUrl: 'api.dev.purehisab.com',
        dbName: 'purehisab_dev.db',
        dbVersion: 2,
      );
}

class StagingFlavourConfig extends FlavourConfig {
  StagingFlavourConfig()
    : super(
        flavour: Flavour.staging,
        urlType: UrlType.https,
        appName: 'PureHisab Staging',
        baseUrl: 'staging.purehisab.com',
        apiBaseUrl: 'api.staging.purehisab.com',
        dbName: 'purehisab_staging.db',
        dbVersion: 2,
      );
}

class ProductionFlavourConfig extends FlavourConfig {
  ProductionFlavourConfig()
    : super(
        flavour: Flavour.production,
        urlType: UrlType.https,
        appName: 'PureHisab',
        baseUrl: 'purehisab.com',
        apiBaseUrl: 'api.purehisab.com',
        dbName: 'purehisab.db',
        dbVersion: 2,
      );
}
