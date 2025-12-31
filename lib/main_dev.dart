import 'package:purehisab/app/flavour/flavour_config.dart';
import 'package:purehisab/app/flavour/flavour_manager.dart';
import 'package:purehisab/main.dart' as runner;

void main() async {
  FlavourManager.setFlavour(Flavour.development);
  await runner.main();
}
