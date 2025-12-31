import 'package:purehisab/app/flavour/flavour_config.dart';

class FlavourManager {
  static FlavourConfig? _currentFlavour;

  static FlavourConfig get currentFlavour {
    _currentFlavour ??= DevelopmentFlavourConfig();
    return _currentFlavour!;
  }

  static void setFlavour(Flavour flavour) {
    switch (flavour) {
      case Flavour.development:
        _currentFlavour = DevelopmentFlavourConfig();
        break;
      case Flavour.staging:
        _currentFlavour = StagingFlavourConfig();
        break;
      case Flavour.production:
        _currentFlavour = ProductionFlavourConfig();
        break;
    }
  }

  static void setFlavourConfig(FlavourConfig config) {
    _currentFlavour = config;
  }

  static bool get isDevelopment =>
      currentFlavour.flavour == Flavour.development;
  static bool get isStaging => currentFlavour.flavour == Flavour.staging;
  static bool get isProduction => currentFlavour.flavour == Flavour.production;
}
